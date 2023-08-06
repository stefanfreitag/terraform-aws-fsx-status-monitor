# A random identifier used for naming resources
resource "random_id" "id" {
  byte_length = 8
}

# The SNS topic to send notifications to
resource "aws_sns_topic" "fsx_health_sns_topic" {
  name              = "fsx-health-topic-${random_id.id.hex}"
  kms_master_key_id = "alias/aws/sns"
  tags              = var.tags
}

# SNS subscriptions
resource "aws_sns_topic_subscription" "fsx_health_sns_topic_email_target" {
  for_each  = toset(var.email)
  topic_arn = aws_sns_topic.fsx_health_sns_topic.arn
  protocol  = "email"
  endpoint  = each.value
}

# iam policy for lambda role
resource "aws_iam_policy" "fsx_health_lambda_role_policy" {
  name        = "fsx-health-lambda-role-policy-${random_id.id.hex}"
  path        = "/"
  description = "IAM policy for fsx health solution lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:log-group:/aws/lambda/*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "fsx:DescribeFileSystems"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "sns:Publish"
            ],
            "Resource": "${aws_sns_topic.fsx_health_sns_topic.arn}",
            "Effect": "Allow"
        }
    ]
}
EOF
  tags   = var.tags
}

# Log group for the Lambda function
resource "aws_cloudwatch_log_group" "fsx_health_lambda_log_groups" {
  name              = "/aws/lambda/fsx-health-lambda-function-${random_id.id.hex}"
  retention_in_days = var.log_retion_period_in_days
  tags              = var.tags
}

# IAM role
resource "aws_iam_role" "fsx_health_lambda_role" {
  name = "fsx-health-lambda-role-${random_id.id.hex}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags               = var.tags
}

# IAM role attachment
resource "aws_iam_role_policy_attachment" "fsx_health_permissions" {
  role       = aws_iam_role.fsx_health_lambda_role.name
  policy_arn = aws_iam_policy.fsx_health_lambda_role_policy.arn

  depends_on = [aws_iam_policy.fsx_health_lambda_role_policy,
  aws_iam_role.fsx_health_lambda_role]
}

# Lambda function
resource "aws_lambda_function" "fsx_health_lambda" {
  filename                       = "${path.module}/fsx-lambda.zip"
  function_name                  = "fsx-health-lambda-function-${random_id.id.hex}"
  description                    = "Monitor the FSx lifecycle status"
  role                           = aws_iam_role.fsx_health_lambda_role.arn
  handler                        = "fsx-health.lambda_handler"
  runtime                        = "python3.8"
  reserved_concurrent_executions = 1
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      LambdaSNSTopic = aws_sns_topic.fsx_health_sns_topic.arn
    }
  }
  tags = var.tags
}

# eventbridge rule
resource "aws_cloudwatch_event_rule" "fsx_health_lambda_schedule" {
  name                = "fsx-health-eventbridge-rule-${random_id.id.hex}"
  description         = "Scheduled execution of the FSx monitor"
  schedule_expression = var.schedule_expression
  is_enabled          = true
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "fsx_health_lambda_target" {
  arn  = aws_lambda_function.fsx_health_lambda.arn
  rule = aws_cloudwatch_event_rule.fsx_health_lambda_schedule.name
}

resource "aws_lambda_permission" "allow_cw_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fsx_health_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.fsx_health_lambda_schedule.arn
}
