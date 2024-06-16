data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_iam" {
  name               = "${local.lambda_function_name}_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = local.tags
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${local.lambda_function_name}_policy"
  policy = data.aws_iam_policy_document.lambda_policies_document.json
}

data "aws_iam_policy_document" "lambda_policies_document" {
  statement {
    sid = "${local.sid_friendly_lambda_function_name}CloudwatchLogsPermissions"
    actions = [
      "logs:CreateLogGroup*",
      "logs:CreateLogStream*",
      "logs:PutLogEvents*"
    ]
    resources = ["${aws_cloudwatch_log_group.lambda_logs.arn}*"]
  }

  statement {
    sid     = "SSMParametersReadOnlyAccess"
    actions = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
    resources = [
      "arn:aws:ssm:${local.region}:${local.account_id}:parameter/${local.project_name_with_env}*"
    ]
  }

  statement {
    sid     = "SSMParameterDecryptionAccess"
    actions = ["kms:Decrypt"]
    resources = [
      data.aws_kms_key.aws_ssm.arn
    ]
  }

  statement {
    sid = "S3Permissions"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.email_staging.arn,
      "${aws_s3_bucket.email_staging.arn}/*"
    ]
  }

  statement {
    sid = "SESPermissions"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["arn:aws:ses:${local.region}:${local.account_id}:identity/${var.domain_name}"]
  }
}

resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.lambda_iam.id
  policy_arn = aws_iam_policy.lambda_policy.arn
}
