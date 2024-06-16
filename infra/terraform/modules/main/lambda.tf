data "archive_file" "zipped_lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../../../src/"
  output_path = "${path.module}/../../../../.dist/packaged_lambda.zip"
}

resource "aws_lambda_function" "handler" {
  description      = "Accept emails with revolut CSVs and imports them to YNAB"
  filename         = data.archive_file.zipped_lambda_code.output_path
  function_name    = local.lambda_function_name
  role             = aws_iam_role.lambda_iam.arn
  handler          = "handler.handler"
  source_code_hash = data.archive_file.zipped_lambda_code.output_base64sha256
  runtime          = "python3.12"
  memory_size      = 128
  timeout          = 10
  architectures    = ["arm64"]

  environment {
    variables = {
      LOG_LEVEL             = "INFO"
      ENVIRONMENT           = var.env
      PROJECT_NAME_WITH_ENV = local.project_name_with_env
      ALLOWED_SENDERS       = var.allowed_senders
      DOMAIN_NAME           = var.domain_name
    }
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 14

  tags = local.tags
}

resource "aws_lambda_permission" "allow_s3_to_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.email_staging.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.email_staging.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.handler.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_to_invoke]
}
