locals {

  stack_name                   = "utility"
  lambda_env_vars              = merge(local.service_secrets, var.open_lambda_environment_variables)
  lambda_vpc_access_subnet_ids = data.aws_subnets.application.ids
  json_folder                  = "profiles/${var.aws_account}/common-${var.aws_region}"
  application_subnet_pattern   = local.stack_secrets["application_subnet_pattern"]
  vpc_name                     = local.stack_secrets["vpc_name"]

  stack_secrets   = data.vault_generic_secret.stack_secrets.data
  service_secrets = data.vault_generic_secret.service_secrets.data

  additional_iam_policies_json = [data.aws_iam_policy_document.get_param_store_systems_manager_policy.json]

  cloudwatch_event_rules_permanent = [
    {
      name                = "call-api-caller-lambda"
      description         = "Call ${module.lambda.lambda_function_name} lambda routinely"
      schedule_expression = "rate(5 minutes)"
      input               = data.local_file.input.content
    },
    {
      name                = "call-api-caller-lambda-dissolutions"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda routinely"
      schedule_expression = "rate(1 minute)"
      input               = data.local_file.dissolutions_submit.content
    },
    {
      name                = "call-api-caller-lambda-efs-handle-delayed-submission-sameday"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda routinely, which calls EFS API to check for any delayed same day submissions"
      schedule_expression = "cron(0/15 7-17 ? * MON-FRI *)"
      input               = data.local_file.efs_handle_delayed_submission_sameday.content
    },
    {
      name                = "efs-queue-files"
      description         = "Uses ${module.lambda.lambda_function_name} lambda to call EFS Submission API to queue files in EFS document processor"
      schedule_expression = "rate(1 minute)"
      input               = data.local_file.efs_queue_files.content
    },
    {
      name                = "efs-submit-files-to-fes"
      description         = "Uses ${module.lambda.lambda_function_name} lambda to call EFS Submission API to submit files to FES"
      schedule_expression = "rate(1 minute)"
      input               = data.local_file.efs_submit_files_to_fes.content
    },
    {
      name                = "call-api-caller-lambda-process-pending-refunds"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda routinely"
      schedule_expression = "rate(5 minutes)"
      input               = data.local_file.process_pending_refunds.content
    },
    {
      name                = "call-api-caller-lambda-payments-status-check"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda routinely"
      schedule_expression = "rate(10 minutes)"
      input               = data.local_file.payments_status_check.content
    },
    {
      name                = "call-api-caller-lambda-account-validator-cleanup-submissions"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda at 2am everyday (7pm in dev environments)"
      schedule_expression = var.cron_account_validator_cleanup_submissions
      input               = data.local_file.account_validator_cleanup_submissions.content
    }
  ]

  cloudwatch_event_rules_development_only = var.environment == "cidev" ? [
    {
      name                = "call-api-caller-lambda-dissolutions-rebel1"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda routinely"
      schedule_expression = "rate(1 minute)"
      input               = data.local_file.dissolutions_submit_rebel1.content
    },
    {
      name                = "call-api-caller-lambda-dissolutions-phoenix1"
      description         = "Cloudwatch event to call ${module.lambda.lambda_function_name} lambda routinely"
      schedule_expression = "rate(1 minute)"
      input               = data.local_file.dissolutions_submit_phoenix1.content
    }
  ] : []
}
