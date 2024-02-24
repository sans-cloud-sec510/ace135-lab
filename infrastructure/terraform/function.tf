data "archive_file" "workshop_function_build" {
  type        = "zip"
  source_dir  = "${path.module}/../functions/workshop"
  output_path = "/tmp/workshop-${var.runtime}-aws.zip"
}

resource "aws_lambda_function" "workshop" {
  function_name    = "ace135-workshop-chapter2"
  description      = "Function for the ACE135 Workshop Chapter 2"
  runtime          = "nodejs18.x"
  handler          = "index.handler"
  role             = aws_iam_role.workshop.arn
  filename         = data.archive_file.workshop_function_build.output_path
  source_code_hash = data.archive_file.workshop_function_build.output_base64sha256

  environment {
    variables = {
      PASTEBIN_ID = var.PastebinId
    }
  }
}

resource "aws_lambda_function_url" "workshop" {
  function_name      = aws_lambda_function.workshop.function_name
  authorization_type = "NONE"
}
