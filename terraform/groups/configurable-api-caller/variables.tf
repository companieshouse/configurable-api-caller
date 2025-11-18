variable "aws_profile" {
  type        = string
  description = "The AWS profile to use for deployment."
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "environment" {
  description = "The name of the environment this cluster is part of e.g. live, staging, dev. etc."
  type        = string
}

variable "timeout_seconds" {
  type        = string
  default     = "15"
  description = "The amount of time the Lambda function has to run in seconds."
}

variable "handler" {
  type        = string
  default     = "dist/index.handler"
  description = "The entrypoint in the Lambda function."
}

variable "lambda_runtime" {
  type        = string
  description = "The lambda runtime to run the application"
  default     = "nodejs22.x"
}

variable "release_bucket_name" {
  type        = string
  description = "The S3 release bucket location containing the function code."
}

variable "release_artifact_key" {
  type        = string
  description = "The release artifact key for the Lambda function"
}

# this was not specified in the original lambda - is 320 ok ?
variable "memory_megabytes" {
  type        = string
  default     = "320"
  description = "The amount of memory to allocate to the Lambda function"
}

# this was not specified in the original lambda - is 7 ok ?
variable "lambda_logs_retention_days" {
  type        = number
  description = "The number of days to retain Lambda logs in CloudWatch"
  default     = 7
}

variable open_lambda_environment_variables {
  type        = map(string)
  description = "Lambda environment variables that do not require encryption."
  default     = {}
}

variable "service" {
  description = "The name of the lambda function."
  type        = string
  default     = "configurable-api-caller"
}

variable "cron_account_validator_cleanup_submissions" {
  description = "The cron string for the account validator cleanup submission cloudwatch event rule."
  type        = string
}
