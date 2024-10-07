variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "release_bucket_name" {
  type = string
}

variable "s3_key" {
  type = string
}

variable "remote_state_bucket" {
  description = "The bucket used to store the remote state files"
}

variable "state_prefix" {
  type = string
}

variable "deploy_to" {
  type = string
}