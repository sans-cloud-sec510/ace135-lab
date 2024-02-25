variable "region" {
  description = "The region in which to deploy the ACE135 Chapter 2 workshop infrastructure and application."
  type        = string
  default     = "us-east-1"
}

variable "PastebinId" {
  description = "The ID of the Pastebin paste used for the ACE135 Chapter 2 workshop."
  type        = string
}
