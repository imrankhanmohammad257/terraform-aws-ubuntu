variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "az" {
  description = "Availability zone for subnet (optional)"
  type        = string
  default     = "us-east-1a"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing AWS Key Pair to allow SSH (optional). If null, login via SSH won't be available until you import/attach a key."
  type        = string
  default     = "first_server1"
}
