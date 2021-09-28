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
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "event_target_api_caller" {
  target_id = aws_cloudwatch_event_rule.call_api_caller_lambda.id
  rule      = aws_cloudwatch_event_rule.call_api_caller_lambda.name
  arn       = aws_lambda_function.configurable_api_lambda.arn
  input     = file("profiles/${var.aws_profile}/input.json")
}

resource "aws_cloudwatch_event_rule" "call_api_caller_lambda_dissolutions" {
  name                = "call_api_caller_lambda_dissolutions"
  description         = "Cloudwatch event to call ${aws_lambda_function.configurable_api_lambda.function_name} lambda routinely"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "event_target_api_caller_dissolutions" {
  target_id = aws_cloudwatch_event_rule.call_api_caller_lambda_dissolutions.id
  rule      = aws_cloudwatch_event_rule.call_api_caller_lambda_dissolutions.name
  arn       = aws_lambda_function.configurable_api_lambda.arn
  input     = file("profiles/${var.aws_profile}/dissolutions_submit.json")
}

resource "aws_lambda_permission" "allow_cloudwatch_dissolutions" {
  statement_id  = "AllowExecutionFromCloudWatchDissolutions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.configurable_api_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.call_api_caller_lambda_dissolutions.arn
}

//
// Workaround code to get multiple environments supported in development account.
// Ideally we would loop over a data structure providing vars for terraform resorces and template the json file,
// but this would require migrations of terraform state in staging and live. If this needs to be extended further
// migrating to a more extensible pattern should be considered.
//
resource "aws_cloudwatch_event_rule" "call_api_caller_lambda_dissolutions_rebel1" {
  count               = var.deploy_to == "development" ? 1 : 0
  name                = "call_api_caller_lambda_dissolutions_rebel1"
  description         = "Cloudwatch event to call ${aws_lambda_function.configurable_api_lambda.function_name} lambda routinely"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "event_target_api_caller_dissolutions_rebel1" {
  count     = var.deploy_to == "development" ? 1 : 0
  target_id = aws_cloudwatch_event_rule.call_api_caller_lambda_dissolutions_rebel1[0].id
  rule      = aws_cloudwatch_event_rule.call_api_caller_lambda_dissolutions_rebel1[0].name
  arn       = aws_lambda_function.configurable_api_lambda.arn
  input     = file("profiles/${var.aws_profile}/dissolutions_submit_rebel1.json")
}

resource "aws_lambda_permission" "allow_cloudwatch_dissolutions_rebel1" {
  count         = var.deploy_to == "development" ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatchDissolutionsRebel1"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.configurable_api_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.call_api_caller_lambda_dissolutions_rebel1[0].arn
}

resource "aws_cloudwatch_event_rule" "call_api_caller_lambda_efs_handle_delayed_submission_sameday" {
  name                = "call_api_caller_lambda_efs_handle_delayed_submission_sameday"
  description         = "Cloudwatch event to call ${aws_lambda_function.configurable_api_lambda.function_name} lambda routinely, which calls EFS API to check for any delayed same day submissions"
  schedule_expression = "cron(0/15 7-17 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "event_target_api_caller_efs_handle_delayed_submission_sameday" {
  target_id = aws_cloudwatch_event_rule.call_api_caller_lambda_efs_handle_delayed_submission_sameday.id
  rule      = aws_cloudwatch_event_rule.call_api_caller_lambda_efs_handle_delayed_submission_sameday.name
  arn       = aws_lambda_function.configurable_api_lambda.arn
  input     = file("profiles/${var.aws_profile}/efs_handle_delayed_submission_sameday.json")
}

resource "aws_lambda_permission" "allow_cloudwatch_efs_handle_delayed_submission_sameday" {
  statement_id  = "AllowExecutionFromCloudWatchEFSDelayedSubmission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.configurable_api_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.call_api_caller_lambda_efs_handle_delayed_submission_sameday.arn
}

resource "aws_cloudwatch_event_rule" "efs_queue_files" {
  name                = "efs_queue_files"
  description         = "Uses ${aws_lambda_function.configurable_api_lambda.function_name} lambda to call EFS Submission API to queue files in EFS document processor"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "event_target_efs_queue_files" {
  target_id = aws_cloudwatch_event_rule.efs_queue_files.id
  rule      = aws_cloudwatch_event_rule.efs_queue_files.name
  arn       = aws_lambda_function.configurable_api_lambda.arn
  input     = file("profiles/${var.aws_profile}/efs_queue_files.json")
}

resource "aws_lambda_permission" "allow_cloudwatch_efs_queue_files" {
  statement_id  = "AllowExecutionFromCloudWatchEFSQueue"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.configurable_api_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.efs_queue_files.arn
}

resource "aws_cloudwatch_event_rule" "efs_submit_files_to_fes" {
  name                = "efs_submit_files_to_fes"
  description         = "Uses ${aws_lambda_function.configurable_api_lambda.function_name} lambda to call EFS Submission API to submit files to FES"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "event_target_efs_submit_files_to_fes" {
  target_id = aws_cloudwatch_event_rule.efs_submit_files_to_fes.id
  rule      = aws_cloudwatch_event_rule.efs_submit_files_to_fes.name
  arn       = aws_lambda_function.configurable_api_lambda.arn
  input     = file("profiles/${var.aws_profile}/efs_submit_files_to_fes.json")
}

resource "aws_lambda_permission" "allow_cloudwatch_efs_submit_files_to_fes" {
  statement_id  = "AllowExecutionFromCloudWatchEFSSubmitToFES"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.configurable_api_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.efs_submit_files_to_fes.arn
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
