output "site_url" {
  description = "The URL to the application"
  value       = "http://${aws_s3_bucket_website_configuration.app.website_endpoint}"
}
