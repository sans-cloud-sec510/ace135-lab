locals {
  region         = var.region
  account        = data.aws_caller_identity.current.account_id
  region_account = "${local.region}:${local.account}"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

data "aws_iam_policy_document" "lambda_s3" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.medical_documents.arn}/*"]
    effect    = "Allow"
  }
}

# Required for putting the Lambda in a custom VPC.
data "aws_iam_policy_document" "lambda_vpc" {
  statement {
    actions   = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

data "aws_iam_policy_document" "lambda_cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogGroup"
    ]

    resources = ["arn:aws:logs:${local.region_account}:*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${local.region_account}:log-group:/aws/lambda/*:*"
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role" "workshop" {
  name               = "ace135-workshop-chapter2"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_s3" {
  name   = "ace135-workshop-chapter2-lambda-s3"
  policy = data.aws_iam_policy_document.lambda_s3.json
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.workshop.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}

resource "aws_iam_policy" "lambda_vpc" {
  name   = "ace135-workshop-chapter2-lambda-vpc"
  policy = data.aws_iam_policy_document.lambda_vpc.json
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.workshop.name
  policy_arn = aws_iam_policy.lambda_vpc.arn
}

resource "aws_iam_policy" "lambda_cloudwatch" {
  name   = "ace135-workshop-chapter2-lambda-cloudwatch"
  policy = data.aws_iam_policy_document.lambda_cloudwatch.json
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch" {
  role       = aws_iam_role.workshop.name
  policy_arn = aws_iam_policy.lambda_cloudwatch.arn
}
