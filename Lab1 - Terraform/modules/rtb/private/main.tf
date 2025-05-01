# PRIVATE RTB
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.cidr_block
    nat_gateway_id = var.nat_gateway_id 
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_ids)
  subnet_id      = element(var.private_subnet_ids, count.index)
  route_table_id = aws_route_table.private.id
}