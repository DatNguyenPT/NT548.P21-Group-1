resource "aws_security_group" "this" {
  name        = var.name
  description = "Security Group managed by Terraform"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_with_cidr_blocks != null ? var.ingress_with_cidr_blocks : []
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      description = ingress.value.description
      cidr_blocks = ingress.value.cidr_blocks != null ? [ingress.value.cidr_blocks] : []
      security_groups = ingress.value.source_security_group_id != null ? [ingress.value.source_security_group_id] : []
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}
