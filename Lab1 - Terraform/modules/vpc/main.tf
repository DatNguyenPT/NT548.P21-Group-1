resource "aws_vpc" "this" {
  cidr_block           = var.cidr


  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[0]
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.name}-public-subnet"
    },
    var.tags
  )
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[0]
  availability_zone = var.azs[0]

  tags = merge(
    {
      Name = "${var.name}-private-subnet"
    },
    var.tags
  )
}

