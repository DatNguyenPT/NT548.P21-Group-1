variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = ["us-east-1a"]  
}

variable "region" {
  type        = string
  description = "AWS Default Region"
  default     = "us-east-1"
}


variable "tags" {
  description = "Tags to be applied to the EIP"
  type        = map(string)
}


variable "vpc_id" {
  description = "VPC ID where the IGW and Route Table will be created"
  type        = string
}

variable "name" {
  description = "VPC Name"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR"
  type        = string
}




