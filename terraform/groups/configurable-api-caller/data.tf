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
    resources = ["*"]
  }
}

data "local_file" "input" {
  filename = "profiles/${var.aws_account}/common-${var.aws_region}/input.json"
}

data "local_file" "dissolutions_submit" {
  filename = "profiles/${var.aws_account}/common-${var.aws_region}/dissolutions_submit.json"
}

data "local_file" "efs_handle_delayed_submission_sameday" {
  filename = "profiles/${var.aws_account}/common-${var.aws_region}/efs_handle_delayed_submission_sameday.json"
}

data "local_file" "efs_queue_files" {
  filename = "profiles/${var.aws_account}/common-${var.aws_region}/efs_queue_files.json"
}

data "local_file" "efs_submit_files_to_fes" {
  filename = "profiles/${var.aws_account}/common-${var.aws_region}/efs_submit_files_to_fes.json"
}

data "local_file" "process_pending_refunds" {
  filename = "profiles/${var.aws_account}/common-${var.aws_region}/process_pending_refunds.json"
}

data "local_file" "payments_status_check" {
  filename = "profiles/${var.aws_account}/common-${var.aws_region}/payments_status_check.json"
}

data "local_file" "account_validator_cleanup_submissions" {
  filename = "profiles/${var.aws_account}/common-${var.aws_region}/account_validator_cleanup_submissions.json"
}

data "local_file" "dissolutions_submit_rebel1" {
  filename = "profiles/${var.aws_account}/common-${var.aws_region}/dissolutions_submit_rebel1.json"
}

data "local_file" "dissolutions_submit_phoenix1" {
  filename = "profiles/${var.aws_account}/common-${var.aws_region}/dissolutions_submit_phoenix1.json"
}
