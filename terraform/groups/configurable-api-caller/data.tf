data "vault_generic_secret" "stack_secrets" {
  path = "applications/${var.aws_account}/${var.environment}/${local.stack_name}-stack"
}

data "vault_generic_secret" "service_secrets" {
  path = "applications/${var.aws_account}/${var.environment}/${local.stack_name}-stack/${var.service}"
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnets" "application" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = [local.application_subnet_pattern]
  }
}

data "aws_iam_policy_document" "get_param_store_systems_manager_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:169942020521:parameter/configurable-api-caller/*"
    ]
  }
}

data "local_file" "input" {
  filename = "${local.json_folder}/input.json"
}

data "local_file" "dissolutions_submit" {
  filename = "${local.json_folder}/dissolutions_submit.json"
}

data "local_file" "efs_handle_delayed_submission_sameday" {
  filename = "${local.json_folder}/efs_handle_delayed_submission_sameday.json"
}

data "local_file" "efs_queue_files" {
  filename = "${local.json_folder}/efs_queue_files.json"
}

data "local_file" "efs_submit_files_to_fes" {
  filename = "${local.json_folder}/efs_submit_files_to_fes.json"
}

data "local_file" "process_pending_refunds" {
  filename = "${local.json_folder}/process_pending_refunds.json"
}

data "local_file" "payments_status_check" {
  filename = "${local.json_folder}/payments_status_check.json"
}

data "local_file" "account_validator_cleanup_submissions" {
  filename = "${local.json_folder}/account_validator_cleanup_submissions.json"
}

data "local_file" "dissolutions_submit_rebel1" {
  filename = "${local.json_folder}/dissolutions_submit_rebel1.json"
}

data "local_file" "dissolutions_submit_phoenix1" {
  filename = "${local.json_folder}/dissolutions_submit_phoenix1.json"
}
