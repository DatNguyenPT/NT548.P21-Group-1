# PUBLIC RTB
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.cidr_block
    gateway_id = var.igw_id
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_ids)
  subnet_id      = element(var.public_subnet_ids, count.index)
  route_table_id = aws_route_table.public.id
}



