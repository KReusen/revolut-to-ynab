module "main" {
  source            = "../modules/main"
  env               = "prd"
  domain_name       = var.domain_name
  allowed_senders   = var.allowed_senders
  ynab_access_token = var.ynab_access_token
  ynab_budget_id    = var.ynab_budget_id
  ynab_account_id   = var.ynab_account_id
}