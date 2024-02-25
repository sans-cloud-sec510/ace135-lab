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

data "aws_iam_policy_document" "secrets" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.workshop.arn]
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

resource "aws_iam_policy" "secrets" {
  name   = "ace135-workshop-chapter2-secrets"
  policy = data.aws_iam_policy_document.secrets.json
}

resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.workshop.name
  policy_arn = aws_iam_policy.secrets.arn
}

resource "aws_iam_policy" "lambda_cloudwatch" {
  name   = "ace135-workshop-chapter2-lambda-cloudwatch"
  policy = data.aws_iam_policy_document.lambda_cloudwatch.json
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch" {
  role       = aws_iam_role.workshop.name
  policy_arn = aws_iam_policy.lambda_cloudwatch.arn
}
