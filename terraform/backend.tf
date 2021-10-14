# resource "aws_s3_bucket" "terraform_state"{
#   bucket = "terraform-state-ghostblog"

#   lifecycle{
#      prevent_destroy = true
#   }

#   versioning {
#     enabled = true

#   }

#   server_side_encryption_configuration {
#     rule {
#         apply_server_side_encryption_by_default {
#           sse_algorithm = "AES256"
#       }
#     }
#   }
# }

resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-state-locking"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }
}

  terraform {
  backend "s3" {
    encrypt = true
    bucket  = "terraform-state-ghostblog"
    key     = "global/s3/terraform.tfstate"
    region  = "eu-west-1"
    dynamodb_table = "terraform-state-locking"
  }
}