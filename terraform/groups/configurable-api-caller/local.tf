locals {

  stack_name                   = "utility-stack"
  lambda_env_vars              = merge(local.service_secrets, var.open_lambda_environment_variables)
  lambda_vpc_access_subnet_ids = data.aws_subnets.application.ids
  application_subnet_pattern   = local.stack_secrets["application_subnet_pattern"]
  vpc_name                     = local.stack_secrets["vpc_name"]

  stack_secrets   = data.vault_generic_secret.stack_secrets.data
  service_secrets = data.vault_generic_secret.service_secrets.data

  additional_iam_policies_json = [data.aws_iam_policy_document.get_param_read_policy.json]

  cloudwatch_event_rules_permanent = [
    {
      name                = "call_api_caller_lambda"
      description         = "Call ${module.lambda.lambda_function_name} lambda routinely"
      schedule_expression = "rate(5 minutes)"
      target              = file("profiles/${var.aws_profile}/common-${var.aws_region}/input.json")
    },
    {
      name                = "call_api_caller_lambda_dissolutions"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda routinely"
      schedule_expression = "rate(1 minute)"
      target              = file("profiles/${var.aws_profile}/common-${var.aws_region}/dissolutions_submit.json")
    },
    {
      name                = "call_api_caller_lambda_efs_handle_delayed_submission_sameday"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda routinely, which calls EFS API to check for any delayed same day submissions"
      schedule_expression = "cron(0/15 7-17 ? * MON-FRI *)"
      target              = file("profiles/${var.aws_profile}/common-${var.aws_region}/efs_handle_delayed_submission_sameday.json")
    },
    {
      name                = "efs_queue_files"
      description         = "Uses ${module.lambda.lambda_function_name} lambda to call EFS Submission API to queue files in EFS document processor"
      schedule_expression = "rate(1 minute)"
      target              = file("profiles/${var.aws_profile}/common-${var.aws_region}/efs_queue_files.json")
    },
    {
      name                = "efs_submit_files_to_fes"
      description         = "Uses ${module.lambda.lambda_function_name} lambda to call EFS Submission API to submit files to FES"
      schedule_expression = "rate(1 minute)"
      target              = file("profiles/${var.aws_profile}/common-${var.aws_region}/efs_submit_files_to_fes.json")
    },
    {
      name                = "call_api_caller_lambda_process_pending_refunds"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda routinely"
      schedule_expression = "rate(5 minutes)"
      target              = file("profiles/${var.aws_profile}/common-${var.aws_region}/process_pending_refunds.json")
    },
    {
      name                = "call_api_caller_lambda_payments_status_check"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda routinely"
      schedule_expression = "rate(10 minutes)"
      target              = file("profiles/${var.aws_profile}/common-${var.aws_region}/payments_status_check.json")
    },
    {
      name                = "call_api_caller_lambda_account_validator_cleanup_submissions"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda at 2am everyday (7pm in dev environments)"
      schedule_expression = var.cron_account_validator_cleanup_submissions
      target              = file("profiles/${var.aws_profile}/common-${var.aws_region}/account_validator_cleanup_submissions.json")
    }
  ]

  cloudwatch_event_rules_development_only = var.environment == "development" ? [
    {
      name                = "call_api_caller_lambda_dissolutions_rebel1"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda routinely"
      schedule_expression = "rate(1 minute)"
      input               = file("profiles/${var.aws_profile}/common-${var.aws_region}/dissolutions_submit_rebel1.json")
    },
    {
      name                = "call_api_caller_lambda_dissolutions_phoenix1"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda routinely"
      schedule_expression = "rate(1 minute)"
      input               = file("profiles/${var.aws_profile}/common-${var.aws_region}/dissolutions_submit_phoenix1.json")
    }
  ] : []

  lambda_permissions_permanent = [
    {
      statement_id = "AllowExecutionFromCloudWatchDissolutions"
      source_arn   = module.lambda.event_rule_arn_map["call_api_caller_lambda_dissolutions"]
    },
    {
      statement_id  = "AllowExecutionFromCloudWatchEFSDelayedSubmission"
      source_arn    = module.lambda.event_rule_arn_map["call_api_caller_lambda_efs_handle_delayed_submission_sameday"]
    },
    {
      statement_id  = "AllowExecutionFromCloudWatchEFSQueue"
      source_arn    = module.lambda.event_rule_arn_map["efs_queue_files"]
    },
    {
      statement_id  = "AllowExecutionFromCloudWatchProcessPendingRefunds"
      source_arn    = module.lambda.event_rule_arn_map["call_api_caller_lambda_process_pending_refunds"]
    },
    {
      statement_id  = "AllowExecutionFromCloudWatchPaymentsStatusCheck"
      source_arn    = module.lambda.event_rule_arn_map["call_api_caller_lambda_payments_status_check"]
    },
    {
      statement_id  = "AllowExecutionFromCloudWatchEFSSubmitToFES"
      source_arn    = module.lambda.event_rule_arn_map["aws_cloudwatch_event_rule.efs_submit_files_to_fes"]
    },
    {
      statement_id  = "AllowExecutionFromCloudWatchAccountValidatorCleanupSubmissions"
      source_arn    = module.lambda.event_rule_arn_map["call_api_caller_lambda_account_validator_cleanup_submissions"]
    }
  ]

  lambda_permissions_development_only = var.environment == "development" ? [
      {
        statement_id  = "AllowExecutionFromCloudWatchDissolutionsRebel1"
        source_arn    = module.lambda.event_rule_arn_map["call_api_caller_lambda_dissolutions"]
      },
      {
        statement_id  = "AllowExecutionFromCloudWatchDissolutionsPhoenix1"
        source_arn    = module.lambda.event_rule_arn_map["call_api_caller_lambda_dissolutions_phoenix1"]
      }
    ] : []
}
