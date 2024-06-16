data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_kms_key" "aws_ssm" {
  key_id = "alias/aws/ssm"
}

data "aws_route53_zone" "hosted_zone" {
  name = local.domain_with_tld
}

data "aws_ses_active_receipt_rule_set" "rule_set" {}