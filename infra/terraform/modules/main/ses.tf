resource "aws_ses_domain_identity" "ses_identity" {
  domain = var.domain_name
}

resource "aws_ses_domain_identity_verification" "verification" {
  domain     = aws_ses_domain_identity.ses_identity.id
  depends_on = [aws_route53_record.amazonses_verification_record]
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = aws_ses_domain_identity.ses_identity.id
}

resource "aws_ses_email_identity" "ynab" {
  email = "ynab@${var.domain_name}"
}

resource "aws_ses_domain_mail_from" "mail_from" {
  domain           = aws_ses_domain_identity.ses_identity.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.ses_identity.domain}"
}

resource "aws_ses_receipt_rule" "process_ynab" {
  name          = local.ses_ynab_rule_name
  rule_set_name = data.aws_ses_active_receipt_rule_set.rule_set.rule_set_name
  recipients    = ["ynab@${var.domain_name}"]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name = aws_s3_bucket.email_staging.bucket
    position    = 1
  }

  depends_on = [aws_s3_bucket_policy.ses_bucket_policy]
}