terraform {
  backend "s3" {
    profile = "bar"
    bucket = "waiiit.com.tf"
    key = "waiiit"
    region = "eu-west-2"
  }
}

provider "aws" {
  profile = "bar"
  region = "us-east-1"
}

variable "project" {
  type = string
  default = "waiiit"
}

variable "root_domain" {
  type = string
  default = "waiiit.com"
}

variable "zone" {
  type = string
  default = "waiiit.com"
}

locals {
  site_bucket = "site.${var.root_domain}"
  origin = "origin.${var.root_domain}"
}

output "ci_access_key" {
  value = aws_iam_access_key.ci.id
}

output "ci_secret_access_key" {
  value = aws_iam_access_key.ci.secret
  sensitive = true
}

output "bucket_arn" {
  value = aws_s3_bucket.site.arn
}

output "cdn_arn" {
  value = aws_cloudfront_distribution.site.arn
}

output "cdn_id" {
  value = aws_cloudfront_distribution.site.id
}
