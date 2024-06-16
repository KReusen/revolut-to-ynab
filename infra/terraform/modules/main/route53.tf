# SES
resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.ses_identity.verification_token]
}

resource "aws_route53_record" "amazonses_dkim_record" {
  count   = 3
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "${aws_ses_domain_dkim.dkim.dkim_tokens[count.index]}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.dkim.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "dmarc" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "_dmarc.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1; p=quarantine; pct=100; adkim=s; aspf=s"]
}

resource "aws_route53_record" "domain_mail" {
  zone_id = data.aws_route53_zone.hosted_zone.id
  name    = aws_ses_domain_identity.ses_identity.domain
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${local.region}.amazonaws.com"]
}

resource "aws_route53_record" "domain_mail_from_mx" {
  zone_id = data.aws_route53_zone.hosted_zone.id
  name    = aws_ses_domain_mail_from.mail_from.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${local.region}.amazonses.com"]
}

resource "aws_route53_record" "spf" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = aws_ses_domain_identity.ses_identity.id
  type    = "TXT"
  ttl     = "600"
  records = [
    "v=spf1 include:amazonses.com -all",
  ]
}

resource "aws_route53_record" "spf_mail_from" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = aws_ses_domain_mail_from.mail_from.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = [
    "v=spf1 include:amazonses.com -all",
  ]
}
