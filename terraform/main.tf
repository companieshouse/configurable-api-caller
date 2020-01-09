provider "aws" {
  region = "eu-west-2"
}

module "lambda" {
  source        = "spring-media/lambda/aws"
  description   = "Provision a lambda with permissions and logging, referencing the configurable-api-caller S3 artefact"
  s3_bucket     = "configurable-api-caller"
  s3_key        = "configurable-api-caller.zip"
  handler       = "dist/index.handler"
  runtime       = "nodejs12.x"

  tags = {
    key = "value"
  }

  environment = {
    variables = {
      key = "value"
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.test_lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:eu-west-1:111122223333:rule/RunDaily"
  qualifier     = "${aws_lambda_alias.test_alias.name}"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "lambdatest.zip"
  function_name = "lambda_function_name"
  role          = "arn:aws:iam::169942020521:policy/GetParamRead"
  handler       = "dist/index.handler"
  runtime       = "nodejs12.x"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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