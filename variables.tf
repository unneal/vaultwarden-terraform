variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3a.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "admin_token" {
  description = "Vaultwarden admin token"
  type        = string
  sensitive   = true
}
