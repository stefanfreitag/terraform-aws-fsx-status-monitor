# AWS account information
data "aws_caller_identity" "current" {}

# AWS region information
data "aws_region" "current" {}
