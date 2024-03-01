resource "random_string" "random" {
  length  = 8
  lower   = true
  numeric = true
  upper   = false
  special = false
}

resource "aws_s3_bucket" "medical_documents" {
  bucket = "medical-documents-${random_string.random.result}"
}

# App deployment. Reference: https://pfertyk.me/2023/01/creating-a-static-website-with-terraform-and-aws/

locals {
  content_types = {
    ".html" : "text/html",
    ".css" : "text/css",
    ".js" : "text/javascript"
  }
}

resource "aws_s3_bucket" "app" {
  bucket = "medical-documents-app-${random_string.random.result}"
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "app" {
  depends_on = [aws_s3_bucket_public_access_block.app]

  bucket = aws_s3_bucket.app.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.app.id}/*"
        }
      ]
    }
  )
}

resource "aws_s3_object" "files" {
  for_each     = fileset("${path.module}/../../app/build", "**/*")
  bucket       = aws_s3_bucket.app.id
  key          = replace(each.value, "${path.module}/../../app/build", "")
  source       = "${path.module}/../../app/build/${each.value}"
  content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), null)
  etag         = filemd5("${path.module}/../../app/build/${each.value}")
}

resource "aws_s3_object" "lambda_url" {
  bucket       = aws_s3_bucket.app.id
  key          = "lambda-url.txt"
  content      = aws_lambda_function_url.upload_medical_document.function_url
  etag         = md5(aws_lambda_function_url.upload_medical_document.function_url)
}

resource "aws_s3_bucket_website_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  index_document {
    suffix = "index.html"
  }
}
