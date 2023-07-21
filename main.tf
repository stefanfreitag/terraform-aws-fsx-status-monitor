# A random identifiert used for naming resources
resource "random_id" "id" {
  byte_length = 8
}

# sns topic
resource "aws_sns_topic" "fsx-health-sns-topic" {
  name = "fsx-health-topic-${random_id.id.hex}"
  kms_master_key_id = "alias/aws/sns"
}

# sns subscription
resource "aws_sns_topic_subscription" "fsx-health-sns-topic-email-target" {
  topic_arn = aws_sns_topic.fsx-health-sns-topic.arn
  protocol  = "email"
  endpoint  = "${var.email}"
}

# iam policy for lambda role
resource "aws_iam_policy" "fsx-health-lambda-role-policy" {
  name        = "fsx-health-lambda-role-policy-${random_id.id.hex}"
  path        = "/"
  description = "IAM policy for fsx health solution lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
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
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

# iam role
resource "aws_iam_role" "fsx-health-lambda-role" {
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

}

# iam role attachment
resource "aws_iam_role_policy_attachment" "fsx-health-permissions" {
  role       = aws_iam_role.fsx-health-lambda-role.name
  policy_arn = aws_iam_policy.fsx-health-lambda-role-policy.arn

  depends_on = [aws_iam_policy.fsx-health-lambda-role-policy,
  aws_iam_role.fsx-health-lambda-role]
}

# lambda function
resource "aws_lambda_function" "fsx-health-lambda" {
  filename      = "${path.module}/fsx-lambda.zip"
  function_name = "fsx-health-lambda-function-${random_id.id.hex}"
  description = "Monitor the FSx lifecycle status"
  role          = aws_iam_role.fsx-health-lambda-role.arn
  handler       = "fsx-health.lambda_handler"
  runtime       = "python3.8"

    environment {
    variables = {
      LambdaSNSTopic = aws_sns_topic.fsx-health-sns-topic.arn
    }
  }
}

# eventbridge rule
resource "aws_cloudwatch_event_rule" "fsx-health-lambda-schedule" {
  name = "fsx-health-eventbridge-rule-${random_id.id.hex}"
  description = "retry scheduled every 60 min"
  schedule_expression = "rate(60 minutes)"
  is_enabled = true
}

resource "aws_cloudwatch_event_target" "fsx-health-lambda-target" {
  arn = aws_lambda_function.fsx-health-lambda.arn
  rule = aws_cloudwatch_event_rule.fsx-health-lambda-schedule.name
}

resource "aws_lambda_permission" "allow-cw-call-lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fsx-health-lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.fsx-health-lambda-schedule.arn
}
