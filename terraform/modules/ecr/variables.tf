# Input Variables for ECR Module

variable "repository_name" {
  type        = string
  description = "Name of the ECR repository"
  default     = "ly-flask-app-repo"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

variable "image_scan_on_push" {
  type        = bool
  description = "enable auto vulnerability scanning when images pushed. (for security best practices)."
  default     = true
}

