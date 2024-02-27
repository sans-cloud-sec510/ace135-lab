resource "random_string" "random" {
  length  = 8
  lower   = true
  number  = true
  upper   = false
  special = false
}

resource "aws_s3_bucket" "workshop" {
  bucket = "ace135-workshop-chapter2-${random_string.random.result}"
}

resource "aws_s3_object" "workshop" {
  bucket  = aws_s3_bucket.workshop.bucket
  key     = "test"
  content = "Test"
}
