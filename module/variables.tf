variable "region" {
  type        = string
  description = "The AWS region in which to Creating the resources."
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones in the selected region."
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks for the public subnets."
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks for the private subnets."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
}

variable "volume_size_gb" {
  type        = number
  description = "Size of the EBS volume in GB."
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the S3 bucket to Creating."
}

variable "ami_id" {
  type        = string
  description = "ID of the AMI to use for EC2 instances."
}
