variable "runtime" {
  description = "The runtime of the functions to use. Must have associated function code."
  type        = string
  default     = "nodejs"

  validation {
    condition     = contains(["nodejs"], var.runtime)
    error_message = "The runtime must be 'nodejs'."
  }
}

variable "PastebinId" {
  description = "The ID of the Pastebin paste used for the ACE135 Chapter 2 workshop."
  type        = string
}
