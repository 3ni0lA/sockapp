  # Provider block for region 
provider "aws" {
  region = "eu-west-2"
}
  # Creating a Lifecycle Configuration for a bucket with versioning

 resource "aws_s3_bucket" "statefile-bucket" {
  bucket = "sockapp-bucket"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
 }
 # Create Dynamo DB table for backend statefile locking

resource "aws_dynamodb_table" "terraform-state-lock" {
  name             = "terraform-state-lock"
  hash_key         = "LockID"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}


# # resource "aws_s3_bucket_acl" "bucket_acl" {
# #   bucket = aws_s3_bucket.statefile-bucket.id
# #   acl    = "private"
# # }

# resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
#   bucket = aws_s3_bucket.statefile-bucket.id

#   rule {
#     id = "log"

#     expiration {
#       days = 90
#     }

#     filter {
#       and {
#         prefix = "log/"

#         tags = {
#           rule      = "log"
#           autoclean = "true"
#         }
#       }
#     }

#     status = "Enabled"

#     transition {
#       days          = 30
#       storage_class = "STANDARD_IA"
#     }

#     transition {
#       days          = 60
#       storage_class = "GLACIER"
#     }
#   }

#   rule {
#     id = "tmp"

#     filter {
#       prefix = "tmp/"
#     }

#     expiration {
#       date = "2023-08-20T01:00:00+01:00"
#     }

#     status = "Enabled"
#   }
# }
# # 

# resource "aws_s3_bucket" "versioning_bucket" {
#   bucket = "sockapp-version-bucket"
# }

# # resource "aws_s3_bucket_acl" "versioning_bucket_acl" {
# #   bucket = aws_s3_bucket.versioning_bucket.id
# #   acl    = "private"
# # }

# resource "aws_s3_bucket_versioning" "versioning" {
#   bucket = aws_s3_bucket.versioning_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_lifecycle_configuration" "versioning-bucket-config" {
#   # Must have bucket versioning enabled first
#   depends_on = [aws_s3_bucket_versioning.versioning]

#   bucket = aws_s3_bucket.versioning_bucket.id

#   rule {
#     id = "config"

#     filter {
#       prefix = "config/"
#     }

#     noncurrent_version_expiration {
#       noncurrent_days = 90
#     }

#     noncurrent_version_transition {
#       noncurrent_days = 30
#       storage_class   = "STANDARD_IA"
#     }

#     noncurrent_version_transition {
#       noncurrent_days = 60
#       storage_class   = "GLACIER"
#     }

#     status = "Enabled"
#   }
# }
# # Provides a S3 bucket server-side encryption configuration resource.
# resource "aws_kms_key" "mykey" {
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 30
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "server-config" {
#   bucket = aws_s3_bucket.statefile-bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.mykey.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

#  tags = {
  #   Name        = "Mysockappbucket"
  #   Environment = "Dev"
  # }

