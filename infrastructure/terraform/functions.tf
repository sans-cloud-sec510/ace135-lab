data "archive_file" "upload_medical_document_function_build" {
  type        = "zip"
  source_dir  = "${path.module}/../functions/upload-medical-document"
  output_path = "/tmp/workshop.zip"
}

resource "aws_lambda_function" "upload_medical_documents" {
  function_name    = "upload-medical-documents"
  description      = "Lambda Function used to process and store medical documents"
  runtime          = "nodejs18.x"
  handler          = "index.handler"
  role             = aws_iam_role.workshop.arn
  memory_size      = 1024
  filename         = data.archive_file.upload_medical_document_function_build.output_path
  source_code_hash = data.archive_file.upload_medical_document_function_build.output_base64sha256

  environment {
    variables = {
      MEDICAL_DOCUMENTS_BUCKET_NAME = aws_s3_bucket.medical_documents.bucket
    }
  }
}

resource "aws_lambda_function_url" "upload_medical_document" {
  function_name      = aws_lambda_function.upload_medical_documents.function_name
  authorization_type = "NONE"
}
