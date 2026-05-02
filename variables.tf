variable "vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Amazon Linux 2023)"
  type        = string
  default     = "ami-0ea87431b78a82070"
}

variable "instance_type" {
  description = "EC2 instance type for the ASG"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the existing EC2 Key Pair for SSH access"
  type        = string
  default     = "NorthVirginia"
}

variable "certificate_arn" {
  description = "ARN of the ACM SSL certificate for the HTTPS listener"
  type        = string
}
