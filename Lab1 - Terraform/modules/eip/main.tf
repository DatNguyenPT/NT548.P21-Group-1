resource "aws_eip" "this" {
  domain = "vpc"
  tags   = var.tags
}
