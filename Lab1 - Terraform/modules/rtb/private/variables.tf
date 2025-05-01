variable "igw_id" {
  description = "ID for the Internet Gateway"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID where the IGW and Route Table will be created"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to associate with the route table"
  type        = list(string)
  default     = []
  
}

variable "route_table_name" {
  description = "Name tag for the Public Route Table"
  type        = string
  default     = "Public Route Table"
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    Name        = "datnguyen-igw"
  }
}

variable "nat_gateway_id" {
  description = "ID for the NAT Gateway"
  type        = string
  default     = ""
}

variable "cidr_block" {
  description = "CIDR block for the NAT Gateway"
  type        = string
  default     = ""
}