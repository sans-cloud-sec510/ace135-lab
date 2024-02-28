resource "random_string" "random" {
  length  = 8
  lower   = true
  number  = true
  upper   = false
  special = false
}

resource "aws_s3_bucket" "medical_documents" {
  bucket = "medical-documents-${random_string.random.result}"
}
