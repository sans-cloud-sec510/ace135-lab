output "lambda_url" {
  description = "The Lambda URL endpoint"
  value       = aws_lambda_function_url.upload_medical_document.function_url
}
