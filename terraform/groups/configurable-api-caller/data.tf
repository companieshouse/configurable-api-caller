data "vault_generic_secret" "stack_secrets" {
  path = "applications/${var.aws_account}/${var.environment}/${local.stack_name}-stack"
}

data "vault_generic_secret" "service_secrets" {
  path = "applications/${var.aws_account}/${var.environment}/${local.stack_name}-stack/${var.service}"
}

data "aws_kms_key" "kms_key" {
  key_id = local.kms_alias
}

data "aws_caller_identity" "aws_identity" {}

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
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.aws_identity.account_id}:parameter/api-caller/*"
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

data "local_file" "efs_call_finance_payment_reports_endpoint" {
  filename = "${local.json_folder}/efs_call_finance_payment_reports_endpoint.json"
}

data "local_file" "efs_call_scotland_payment_report_endpoint" {
  filename = "${local.json_folder}/efs_call_scotland_payment_report_endpoint.json"
}

data "local_file" "efs_delayed_submission_call" {
  filename = "${local.json_folder}/efs_delayed_submission_call.json"
}

data "local_file" "dissolutions_submit_rebel1" {
  count = var.aws_account == "development-eu-west-2" ? 1 : 0

  filename = "${local.json_folder}/dissolutions_submit_rebel1.json"
}

data "local_file" "dissolutions_submit_phoenix1" {
  count = var.aws_account == "development-eu-west-2" ? 1 : 0

  filename = "${local.json_folder}/dissolutions_submit_phoenix1.json"
}
