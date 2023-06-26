# Route 53 and sub-domain name setup

resource "aws_route53_zone" "socks-domain-name" {
  name = "eniola.link"
}

# Get the zone_id for the load balancer

data "aws_elb_hosted_zone_id" "elb_zone_id" {
  depends_on = [
     kubernetes_service.kube-service-socks
  ]
}


# DNS record for socks

resource "aws_route53_record" "socks-record" {
  zone_id = aws_route53_zone.socks-domain-name.zone_id
  name    = "eniola.link"
  type    = "A"

  alias {
    name                   = kubernetes_service.kube-service-socks.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.elb_zone_id.id
    evaluate_target_health = true
  }
}
