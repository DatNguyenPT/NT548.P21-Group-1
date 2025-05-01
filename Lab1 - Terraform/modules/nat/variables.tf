variable "allocation_id" {
  description = "The allocation ID of the EIP"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the NAT Gateway will be created"
  type        = string
}

variable "tags" {
  description = "Tags for NAT Gateway"
  type        = map(string)
}


variable "aws_internet_gateway" {
  description = "The internet gateway to attach to the NAT Gateway"
  type        = string
  default     = null
}