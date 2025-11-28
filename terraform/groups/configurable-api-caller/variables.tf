variable "aws_account" {
  description = "The AWS account to deploy in to"
  type        = string
}

variable "aws_region" {
  default     = "eu-west-2"
  description = "The AWS region that resources will be created within"
  type        = string
}

variable "service" {
  default     = "configurable-api-caller"
  description = "The name of service being deployed"
  type        = string
}

variable "environment" {
  description = "The name of the specific environment being deployed"
  type        = string
}

variable "timeout_seconds" {
  default     = 15
  description = "The amount of time the Lambda function has to run in seconds."
  type        = number
}

variable "handler" {
  default     = "dist/index.handler"
  description = "The entrypoint in the Lambda function."
  type        = string
}

variable "lambda_runtime" {
  default     = "nodejs22.x"
  description = "The lambda runtime to run the application"
  type        = string
}

variable "release_bucket_name" {
  description = "The S3 release bucket location containing the function code."
  type        = string
}

variable "release_artifact_key" {
  description = "The release artifact key for the Lambda function"
  type        = string
}

variable "memory_megabytes" {
  default     = 320
  description = "The amount of memory to allocate to the Lambda function"
  type        = number
}

variable "lambda_logs_retention_days" {
  default     = 7
  description = "The number of days to retain Lambda logs in CloudWatch"
  type        = number
}

variable "cron_account_validator_cleanup_submissions" {
  description = "The cron string for the account validator cleanup submission cloudwatch event rule."
  type        = string
}
