locals {
  project_name          = "revolut-to-ynab"
  project_name_with_env = "${local.project_name}-${var.env}"
  tags = {
    Project     = local.project_name
    Environment = var.env
  }

  lambda_function_name              = "${local.project_name}_${var.env}"
  sid_friendly_lambda_function_name = replace(title(replace(local.lambda_function_name, "-", "")), "_", "")
  domain_parts                      = split(".", var.domain_name)
  domain_with_tld                   = join(".", slice(local.domain_parts, length(local.domain_parts) - 2, length(local.domain_parts)))
  ses_ynab_rule_name                = "process_ynab"

  region     = data.aws_region.current.id
  account_id = data.aws_caller_identity.current.account_id
}