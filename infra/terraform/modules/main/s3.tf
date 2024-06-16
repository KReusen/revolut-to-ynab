resource "aws_s3_bucket" "email_staging" {
  bucket = "${local.project_name_with_env}-email-staging"

  tags = local.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "email_staging" {
  bucket = aws_s3_bucket.email_staging.id

  rule {
    id     = "expire-emails"
    status = "Enabled"

    expiration {
      days = 14
    }
  }
}

resource "aws_s3_bucket_policy" "ses_bucket_policy" {
  bucket = aws_s3_bucket.email_staging.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ses.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.email_staging.arn}/*",
        Condition = {
          StringEquals = {
            "aws:Referer" = local.account_id
          }
        }
      }
    ]
  })
}
