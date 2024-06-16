resource "aws_ssm_parameter" "ynab_access_token" {
  name  = "/${local.project_name_with_env}/ynab_access_token"
  type  = "SecureString"
  value = var.ynab_access_token
}

resource "aws_ssm_parameter" "ynab_budget_id" {
  name  = "/${local.project_name_with_env}/ynab_budget_id"
  type  = "SecureString"
  value = var.ynab_budget_id
}

resource "aws_ssm_parameter" "ynab_account_id" {
  name  = "/${local.project_name_with_env}/ynab_account_id"
  type  = "SecureString"
  value = var.ynab_account_id
}