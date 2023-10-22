# AWS account information
data "aws_caller_identity" "current" {}

# AWS region information
data "aws_region" "current" {}

# Creates the zip file for the Lambda function
data "archive_file" "status_checker_code" {
  type        = "zip"
  source_dir  = "${path.module}/functions/check-fsx-status/"
  output_path = "${path.module}/out/check-fsx-status.zip"
}
