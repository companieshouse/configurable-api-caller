provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}
}

// Lambda
resource "aws_lambda_function" "configurable_api_lambda" {
  function_name = "configurable-api-caller"
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/index.handler"
  runtime       = "nodejs12.x"
  timeout       = 15
  vpc_config {
    security_group_ids = [aws_security_group.allow_calls_to_api_caller.id]
    subnet_ids = split(",", data.terraform_remote_state.applications_vpc.outputs.application_ids)
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.configurable_api_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.call_api_caller_lambda.arn
}

// Role

resource "aws_iam_role" "lambda_role" {
  name = "allow-lambda-role"
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

// Policies

resource "aws_iam_policy" "get_param_policy" {
  name        = "get_param_read"
  description = "Definition for Get Param Store, Systems Manager policy"
  policy      = file("profiles/${var.aws_profile}/param_policy.json")
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "param_read" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.get_param_policy.arn
}

// Cloudwatch rule event
// Add further resources here to add new service calls

resource "aws_cloudwatch_event_rule" "call_api_caller_lambda" {
  name                = "call_api_caller_lambda"
  description         = "Cloudwatch event to call ${aws_lambda_function.configurable_api_lambda.function_name} lambda routinely"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "event_target_api_caller" {
  target_id = aws_cloudwatch_event_rule.call_api_caller_lambda.id
  rule      = aws_cloudwatch_event_rule.call_api_caller_lambda.name
  arn       = aws_lambda_function.configurable_api_lambda.arn
  input     = file("profiles/${var.aws_profile}/input.json")
}

// VPC

data "terraform_remote_state" "applications_vpc" {
  backend = "s3"
  config = {
    bucket = "${var.remote_state_bucket}"
    key    = "${var.state_prefix}/${var.deploy_to}/${var.deploy_to}.tfstate"
    region = "${var.aws_region}"
  }
}

// Security group

resource "aws_security_group" "allow_calls_to_api_caller" {
  name        = "allow_calls_to_api_caller"
  description = "Allow TLS calls to and from the configurable-api-caller"
  vpc_id      = data.terraform_remote_state.applications_vpc.outputs.vpc_id

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = split(",", data.terraform_remote_state.applications_vpc.outputs.application_cidrs)
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
