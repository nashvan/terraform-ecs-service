
# terraform {
#   backend "s3" {
#     region = "ap-southeast-2"
#     key    = "state"
#   }
# }

data "aws_caller_identity" "current" {}

provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}
