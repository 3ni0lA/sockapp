# Capstone Project for Group 20 (Cloud Engineering)
> This is the implementation plan for our cloud/DevOps team. 
## Project Idea
The [Sock Shop](https://github.com/microservices-demo/microservices-demo) is a microservice-based application designed to manage and facilitate the distribution, inventory, and tracking of socks within an organization or e-commerce platform. It leverages a set of independent and loosely coupled services to handle various sock-related functionalities, providing a scalable and modular solution for sock management. 

>Use Case: Let us consider an example of an e-commerce platform that specializes in selling socks. The platform's inventory consists of different types, sizes, and colors of socks from various manufacturers. The Sock Shop can be developed to streamline and optimize the processes involved in managing the sock inventory.

## Tools, Services, and Technologies
The following are tools, services, and technologies chosen by the DevOps team for the deployment of the Sock Shop app.


## Architecture Diagram 

<img width="1024" alt="Architecture Diagram" src="https://github.com/3ni0lA/sockapp/assets/101342958/762bd804-da1c-4c2b-ba93-ea5febcb8ad3">

### Cloud Service Provider
The cloud service provider chosen for this project is ***Amazon Web Services (AWS)***. This is because it has all of the services needed for a successful deployment of the app, most of which have free-tier usage which will reduce infrastructure costs for the company, which is a startup, with no tangible means of funding.
 By using its tools, such as auto-scaling and elastic load balancing, elastic Kubernetes service (EKS), the application can be scaled up or down based on demand. AWS is backed by Amazon’s massive infrastructure, so we have access to compute and storage resources when needed. Further details on the infrastructure requirements and setup are given under the subsequent headings.



### Infrastructure
The infrastructure setup will be carried out in two phases.
#### Phase 1 
##### Containerization.
To enhance the portability of the application and its dependencies, the application will be containerized using ***Docker***. This containerization will also help in scalability by allowing the leverage of container orchestration tools like Kubernetes to easily scale the application horizontally by running multiple instances of the container across a cluster of machines. This enables the app to handle increased traffic and demand, ensuring optimal performance and availability. 
The major points/steps involved in the containerization of the app are given as follows;
- A docker file will be prepared. This gives instructions on how the application should be packaged or containerized. The basic instructions in the docker file will include the base image to use, the working directory for subsequent commands, instructions to copy the contents of the local directory to the working directory, installation of required dependencies, port to expose, and startup command.
- Once the docker file is prepared, the image will be built using the docker build command. This will create an image of the application.
The next step involves testing and running the built image using the docker run command to ensure the application is containerized properly.
- Once the image is running confirming the application was containerized successfully, the next step involves pushing the built image to a container registry such as docker hub. This will allow the image to be available in a secure container registry and allow the pulling of the image onto any environment when needed.
- Note that this process will be done on an AWS EC2 instance on an Ubuntu OS and a tier-small instance type.
- Clone the repository of the app: ```
git clone https://github.com/microservices-demo/microservices-demo```
- After cloning into the app, get into the app directory using `cd sockshop`
Then change the directory in the docker file `workdir` to the current working directory you cloned your application.
- Create the image using this command `docker build -t example/sockapp.latest`. 
(The tag can be anything, but always make sure to tag the image to your username on docker hub. For example, `damola/exampleapp`. 
- Don't forget the dot (.). It informs Docker to build the app on the same directory you are in.
- Check if the image has been successfully built with the command `docker image ls`
- After the image is successfully built we can now create the container for the app using this command `docker run -d -p 80:3000 example/sockapp:1.0`
- We use `docker ps` to check if our container is up and running.
- Copy the IP address of the instance (don't forget to pass the port imputed earlier).
- On the browser, you should see your application!
- After this has been done successfully, login to your Docker account using `docker login`
and push your image to Docker hub using `docker push image name`
- We plan to persist data using PV persistent volume or persistent volumes claim, which is going to configure our database pod to utilize it and then have it backed up on a storage solution. (Amazon Elastic Block Store EBS or EFS).


#### Phase 2
##### Infrastructure as Code (IaC) 
To ensure automation and consistency, we adopted an Infrastructure as Code (IaC) tool, ***Terraform***, to define and create the required infrastructure. This will also ensure the reproducibility of the infrastructure across different environments and this will all help to minimize inconsistencies between different environments and reduce the risk of deployment-related issues.
IaC tools like Terraform also provide powerful capabilities for scaling the infrastructure by allowing the definition of templates or modules that allow scaling resources up or down based on demand or workload requirements. Another vital reason for adopting Terraform was for auditing and compliance. Infrastructure changes can be logged, tracked and audited, providing a clear history of modifications and ensuring compliance with organizational policies and regulatory requirements.

##### Elastic Kubernetes Service (EKS)
Due to its ability to scale the application horizontally, we adopted the AWS-managed Kubernetes service, EKS, for the deployment of the Sock Shop application. This scalability allows the application to handle increased traffic and demand without sacrificing performance or availability. 
Elastic Kubernetes Service also provides built-in load balancing mechanisms to distribute traffic evenly across the pods. It also ensures high availability as it can automatically detect and recover from failures, replacing unhealthy pods with new ones.
 
##### Creating an EKS Cluster Using Terraform
- Basic things needed for this implementation include;
- An active AWS account
- An Ubuntu Machine
- Terraform installed on the machine
- AWS CLI
- Route 53 domain
- Docker image
- S3 bucket 

- Create a main.tf file  (This file will contain a provider block that allows Terraform to interact with cloud providers and other APIs.) We will define our provider (AWS) in this file with our region, with the other required providers (route 53, acme, kubectl, Kubernetes).

- Create a VPC, subnets, and internet gateway in a file (vpc.tf). The VPC enables us to launch resources into a virtual network that will be defined with the benefits of using the scalable infrastructure of AWS. The internet gateway enables resources in your public subnets (such as EC2 instances) to connect to the internet if they have a public IPv4 or IPv6 address. We will create two subnets in the VPC, public and private, and two availability zones will be attached to them.(and a cidr_block of “10.0.0.0/16”.)
- Create a NAT gateway. The next step is to create a NAT gateway and an elastic IP. The elastic IP will be attached to the NAT gateway and also connected to a public subnet.

- Create the route tables. A route table contains a set of rules, called routes, that determine the direction of network traffic from your subnet or gateway. We will create a routing table for both the public and private subnets.

- Creating EKS clusters with roles: Amazon EKS uses the service-linked role named AWSServiceRoleForAmazonEKS. The role allows Amazon EKS to manage clusters in your account. The attached policies allow the role to manage the following resources: network interfaces, security groups, logs, and VPCs. (port range of 443,80 and 22 on all ports 0.0.0.0/0)

- Create a variable file. This file will contain secrets and defined variables for the EKS name.
- Create a worker node group. This node group will need to be attached to three role policies (AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_PolicY,  AmazonEKSWorkerNodePolicy).

- Create a kubectl manifest file. This to be used for calling the namespace, deployment, and service file used to call and create the image of the app for the EKS cluster.

- Create the deployment, namespace, and service.yaml files (the deployment file manages the creation and scaling of application instances, called pods, on the EKS cluster, while the service
    
- Create an s3.tf file. This file is going to contain the terraform state file(s3 bucket backend).

- Create a certificate.tf file. This allows web browsers to identify and establish encrypted network connections to websites using the SSL/TLS protocol. We are specifically using Lets Encrypt Certificate because it saves cost, is easy to use and it's compatible with any website, with a Route 53 domain.
 - After all these have been created properly, check if your cluster is created successfully. When this is confirmed, connect to your cluster.
 

### Configuration Management
Our team has a unique deployment process tailored specifically to our application's requirements. The deployment process already satisfies our needs and provides the necessary flexibility and control, so therefore a configuration management tool is not necessary.

### Cost Savings Plan (FinOps)
Effective cost management for DevOps teams is a crucial point, especially for startups with no source of funding. This is what the team has come up with. All costs are to be managed with the ***AWS Calculator***.

It is a cloud cost estimation tool built by AWS that helps DevOps teams understand the cost impact of infrastructure changes before they are deployed. It integrates with Terraform and other infrastructure as code tools to provide cost estimates in real-time.

This calculator is essential for our team and this project because it helps DevOps teams to optimize cloud costs, plan for capacity, and stay within budget while reducing the risk of unplanned costs.

For funding, because there is no credible source of funding from the startup, the DevOps team has decided to sponsor the financial requirements for the successful deployment and hosting of the app.

This is a pictorial summary of the costs likely to be incurred while deploying the Sock Shop app on AWS.
<img width="428" alt="FinOps total summary" src="https://github.com/3ni0lA/sockapp/assets/101342958/06b96f3e-feee-467e-8c59-99eaad9f5d0e">


Most of the tools here are infrastructure-based, the sole reason being that other tools, services and technologies to be used are free to use.

NB: It is important to note that while the costs might seem a bit overrated for a startup, the team also considered how long the services would be needed, which would not exceed a month, hence the team’s choice of these services. 

### Site Reliability Engineering (SRE)
#### Monitoring
Monitoring a cluster is crucial for maintaining its health, performance, and stability. This documentation provides an overview of tools commonly used for cluster monitoring, their configuration steps, and the key metrics to monitor, along with their significance.
##### 1. Tools for Cluster Monitoring:
There are several excellent tools available for cluster monitoring. Here are a few widely used options:
a. ***Prometheus***: An open-source monitoring system that collects metrics from monitored targets, stores them, and provides a flexible querying language (PromQL) for analysis and alerting.
b. ***Grafana***: A popular open-source visualization and monitoring tool that integrates seamlessly with Prometheus and other data sources. Grafana allows you to create customizable dashboards and alerts.
##### 2. Configuration Steps:
The specific configuration steps may vary depending on the monitoring tool and cluster setup. However, the general steps typically involve:
a. ***Install and configure the monitoring tool***: Follow the official documentation to install and configure the selected monitoring tool on your cluster. This usually involves deploying specific components or agents on the cluster nodes.
b. ***Define monitoring targets***: Identify the resources you want to monitor, such as nodes, pods, containers, services, or specific metrics. Configure the monitoring tool to scrape and collect metrics from these targets.
c. ***Set up data retention and storage***: Define how long the collected metrics should be retained and determine the appropriate storage mechanism. This could involve configuring local storage, cloud-based storage, or using a time-series database.
d. ***Create dashboards and alerts***: Use the monitoring tool's interface to create dashboards that visualize the collected metrics and set up alerts to receive notifications when certain thresholds are breached.
##### 3. Key Metrics to Monitor and Significance:
When monitoring a cluster, it's essential to focus on relevant metrics that reflect the cluster's health, performance, and resource utilization. Here are some key metrics to consider:
a. ***CPU and Memory Usage***: Monitor the CPU and memory consumption at the cluster, node, and pod levels. High resource utilization can impact overall performance and may indicate the need for scaling resources.
b. ***Network Traffic***: Track network traffic to identify any bottlenecks, latency issues, or abnormal patterns. Monitoring network metrics helps ensure smooth communication between cluster components.
c. ***Disk I/O and Storage Usage***: Keep an eye on disk I/O operations and storage utilization. Excessive disk I/O or running out of storage space can lead to performance degradation or application failures.
d. ***Pod and Container Health***: Monitor the status, restart count, and resource usage of individual pods and containers. This allows you to identify any failing or misbehaving components.
e. ***Cluster Events and Logs***: Collect and analyze cluster events and logs to gain insights into system behavior, error conditions, and potential issues. Monitoring logs helps with troubleshooting and identifying anomalies.
f. ***Application-specific Metrics***: Consider application-specific metrics that are critical to your specific use case. These could include request latency, error rates, database connections, or any other custom metrics that reflect the application's health and performance.

### Security Plan
This is a detailed security plan for the infrastructure the team is to set up for the app deployment. Here’s a breakdown of measures that will be ensured for maximum security of the whole infrastructure:
#### Network Security
1. We will implement AWS Security Groups to control inbound and outbound traffic to the EKS cluster and restrict access to only necessary ports and IP ranges.
2. We will also implement network segmentation using subnets and network access control lists (ACLs) to enforce stricter traffic control.
3. We will consider using a Network Firewall or Web Application Firewall (WAF) to add an additional layer of protection against malicious traffic.

#### Container Security
1. We will employ a secure container registry, such as Amazon Elastic Container Registry (ECR), instead of DockerHub. This ensures better control over image storage and access.
2. We will regularly scan container images for vulnerabilities using tools like AWS Container Image Scanning or third-party security scanners and fix any identified vulnerabilities before deployment.
3. We will implement Kubernetes security best practices, such as using RBAC (Role-Based Access Control) to control access to Kubernetes resources and namespaces.

#### Authentication and Authorization
1. We will utilize AWS Identity and Access Management (IAM) to manage user access and permissions to AWS resources and follow the principle of least privilege.
2. We will enable Multi-Factor Authentication (MFA) for IAM users and enforce strong password policies.
3. We will leverage AWS IAM roles for service accounts and applications running within the EKS cluster, rather than using long-term access keys.
#### Secrets Management
1. We will avoid hardcoding sensitive information like credentials or API keys in your code or configuration files and utilize AWS Secrets Manager or HashiCorp Vault to securely store and manage secrets. 
#### Logging and Auditing
1. We will enable AWS CloudTrail to capture API calls and create trails for auditing and monitoring.
2. We will also centralize and aggregate logs from your EKS cluster, applications, and related services using AWS CloudWatch Logs or a dedicated log management solution.
3. We will implement log retention policies and regularly review logs for security analysis and incident response.
#### Regular Updates and Patching
1. We will stay up to date with the latest security patches for your EKS cluster, worker nodes, and underlying AWS services.
2. We will enable automatic updates for managed services like EKS, or implement a regular patching schedule for self-managed components.
#### Security Monitoring and Incident Response
1. We will set up security monitoring and alerting using AWS CloudWatch Events, AWS Config Rules, or a dedicated security information and event management (SIEM) system.
2. We will establish an incident response plan to promptly address security incidents or breaches. Conduct regular security assessments and penetration testing.
#### Ongoing Security Audits and Compliance
1. We will regularly perform security audits and vulnerability assessments on the infrastructure, including both the EKS cluster and supporting AWS services.
2. We will ensure compliance with relevant security standards and regulations, such as the AWS Well-Architected Framework, CIS Benchmarks, or industry-specific compliance requirements.
### CI/CD Pipeline
The team chose [CircleCI](https://circleci.com/) to ensure continuous delivery and integration. It was chosen because it is a cloud-based CI/CD platform that offers a free tier for small teams. It provides seamless integration with popular version control systems like GitHub and BitBucket and supports deployment to Kubernetes clusters created using Terraform.

The CI/CD pipeline will be responsible for the following:
#### Source Code Management
Clone the Sockapp repository from the source code management system (e.g., GitHub) to the CI/CD environment (CircleCI).
Pull the latest changes from the repository to ensure the pipeline operates on the most up-to-date code.
#### Code Quality and Linting
Run code linting tools (e.g., ESLint) to enforce coding standards and best practices.
Perform static code analysis to identify potential bugs, security vulnerabilities, or code smells.
#### Unit Testing
Execute unit tests to verify the functionality and correctness of individual components or modules.
Generate test coverage reports to measure the code coverage by the unit tests.
#### Security Scanning
Conduct security scans on the codebase to identify vulnerabilities, insecure dependencies, or potential security risks.
Utilize security scanning tools (e.g., Snyk, SonarQube) to detect common security issues and provide remediation guidance.
#### Containerization
Build a Docker image of the Sockapp application using the Dockerfile.
Tag the Docker image with a version or unique identifier.
Push the Docker image to a container registry (e.g., DockerHub, Amazon ECR) for storage and easy access.
#### Infrastructure Provisioning
Use Terraform to provision the AWS EKS infrastructure, including VPC, subnets, security groups, and EKS cluster configuration.
Define and manage infrastructure-as-code to ensure consistency and reproducibility.
#### Deployment to EKS Cluster
Deploy the Sockapp application to the EKS cluster using Kubernetes deployment manifests or other deployment methods.
Handle rolling updates or canary deployments to ensure seamless updates and minimal downtime.
Apply Kubernetes best practices for managing secrets, environment variables, and configuration.
#### Monitoring and Observability
Deploy monitoring infrastructure (e.g., Prometheus, Grafana) alongside the Catchapp application to collect metrics and logs.
Configure alerting rules and thresholds to notify relevant parties of critical incidents or performance issues.
Integrate with centralized logging solutions (e.g., AWS CloudWatch Logs) for easy access and analysis of application logs.
#### Post-Deployment Testing:
Perform integration tests or end-to-end tests to validate the functionality of the deployed application.
Conduct smoke tests or health checks to ensure the application is responsive and functioning properly.
#### Rollback and Recovery
Implement rollback mechanisms in case of deployment failures or critical issues.
Utilize Kubernetes features (e.g., rollout history, rollback commands) to revert to a previously known stable state.
#### Notifications and Reporting
Send notifications or status updates to relevant stakeholders or team members upon pipeline stages completion, deployment success, or failure.
Generate reports or documentation detailing the pipeline execution, test results, and deployment history.
#### Orchestration and Pipeline Workflow
Define the pipeline workflow using CircleCI's configuration file or visual pipeline editor.
Manage dependencies between stages and parallelize tasks for efficient execution.
Implement conditions or approvals for manual intervention in specific stages, such as production deployments.
By automating these tasks within the CI/CD pipeline, we can achieve continuous integration, delivery, and deployment for the Catchapp web application, reducing manual effort and ensuring consistent and reliable releases.
                                        








 

 
 
 


 

 

 
