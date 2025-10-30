variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}
variable "username" {
  description = "Linux user to create on the instance"
  type        = string
  default     = "deploy"
}

variable "app_dir" {
  description = "Directory to create and give 775 permissions to"
  type        = string
  default     = "/opt/app"
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
