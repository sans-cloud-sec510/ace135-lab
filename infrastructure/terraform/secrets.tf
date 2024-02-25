resource "aws_secretsmanager_secret" "workshop" {
  name = "ace135-workshop-chapter2-secret"
}

resource "aws_secretsmanager_secret_version" "workshop" {
  secret_id     = aws_secretsmanager_secret.workshop.id
  secret_string = "Test"
}
