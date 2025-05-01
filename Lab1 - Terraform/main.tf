# Backend
module "pre-backend" {
  source = "./backend/pre-setup"
}

module "backend" {
  source = "./backend"
}

#####################################################################################################
# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "nhom1-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["us-east-1a"]
  private_subnets  = ["10.0.1.0/24"]
  public_subnets   = ["10.0.101.0/24"]

  # Enable NAT Gateway for private subnets
  enable_nat_gateway = false
  single_nat_gateway = false

  # Enable DNS hostnames and support
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Add VPC endpoints if needed
  enable_vpn_gateway = false

  # Tags
  tags = {
    Terraform   = "true"
    Environment = "development"
  }

  # Subnet tags
  public_subnet_tags = {
    Type = "Public"
  }

  private_subnet_tags = {
    Type = "Private"
  }
}

#####################################################################################################
# EIP
module "eip" {
  source = "./modules/eip"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#####################################################################################################
# IGW
module "igw" {
  source = "./modules/igw"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#####################################################################################################
# NAT Gateway
module "nat-gw" {
  source = "./modules/nat"
  allocation_id = module.eip.eip_id
  subnet_id = module.vpc.public_subnets[0]
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  depends_on = [module.igw]
}

#####################################################################################################
# Public RTB
module "public-rtb" {
  source = "./modules/rtb/public"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
  cidr_block = "0.0.0.0/0"
  igw_id = module.igw.igw_id
  route_table_name = "public-rtb"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Private RTB
module "private-rtb" {
  source = "./modules/rtb/private"
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = module.nat-gw.nat_gateway_id
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#####################################################################################################
#SG
module "public-sg" {
  source = "./modules/sg"

  name   = "public-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH from my IP"
      cidr_blocks = "192.168.101.0/24"
    }
  ]
}


module "private-sg" {
  source = "./modules/sg"

  name   = "private-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from public EC2"
      cidr_blocks              = null
      source_security_group_id = module.public-sg.security_group_id
    }
  ]
}




#####################################################################################################
# EC2
module "public-ec2" {
  source              = "./modules/ec2"
  vpc_id              = module.vpc.vpc_id
  ami_id              = "ami-05778ef68e10b91d7"
  instance_type       = "t2.small"
  key_name            = "instance-keypair"
  subnet_id           = module.vpc.public_subnets[0]
  security_group_id   = module.public-sg.security_group_id
  instance_name       = "nhom1-public-ec2"
  volume_size         = 10

  tags = {
    Environment = "dev"
  }
}

module "private-ec2" {
  source              = "./modules/ec2"
  vpc_id              = module.vpc.vpc_id
  ami_id              = "ami-05778ef68e10b91d7"
  instance_type       = "t2.small"
  key_name            = "instance-keypair"
  subnet_id           = module.vpc.private_subnets[0]
  security_group_id   = module.private-sg.security_group_id
  instance_name       = "nhom1-private-ec2"
  volume_size         = 10

  tags = {
    Environment = "dev"
  }
}

