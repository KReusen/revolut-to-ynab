variable "ynab_access_token" {
  description = "YNAB personal access token"
  type        = string
}

variable "domain_name" {
  description = "Domain name the service runs on. Can contain subdomains. In case of import.example.com, mail will be accepted at ynab@import.example.com"
  type        = string
}

variable "allowed_senders" {
  description = "Comma seperated email addresses that are allowed to send emails to the service"
  type        = string
}

variable "ynab_budget_id" {
  description = "The YNAB budget id to import transactions into"
  type        = string
}

variable "ynab_account_id" {
  description = "The YNAB account id to import transactions into"
  type        = string
}

variable "env" {
  description = "The environment the service is deployed in"
  type        = string
}