variable "aws_access_key_id" {
  type        = string
  description = "AWS access key ID"
  sensitive   = true
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the secrets"
  default     = {}
}