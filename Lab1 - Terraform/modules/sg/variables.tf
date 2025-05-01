variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where SG will be created"
  type        = string
}


variable "ingress_with_cidr_blocks" {
  description = "List of ingress rules with cidr_blocks or source_security_group_id"
  type = list(object({
    from_port                  = number
    to_port                    = number
    protocol                   = string
    description                = string
    cidr_blocks                = optional(string) 
    source_security_group_id   = optional(string) 
  }))
}
