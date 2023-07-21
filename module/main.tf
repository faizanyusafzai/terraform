provider "aws" {
  region = var.region
}

# Creating VPC
resource "aws_vpc" "mine_it_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "Mine-IT-VPC"
  }
}

# Creating an Internet Gateway
resource "aws_internet_gateway" "mine_it_igw" {
  vpc_id = aws_vpc.mine_it_vpc.id

  tags = {
    Name = "Mine-IT-IGW"
  }
}

# Creating subnets in different availability zones
resource "aws_subnet" "mine_it_public_subnets" {
  count           = length(var.availability_zones)
  vpc_id          = aws_vpc.mine_it_vpc.id
  cidr_block      = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Mine-IT-Public-Subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "mine_it_private_subnets" {
  count           = length(var.availability_zones)
  vpc_id          = aws_vpc.mine_it_vpc.id
  cidr_block      = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "Mine-IT-Private-Subnet-${count.index + 1}"
  }
}

# Creating a public route table and associate it with the public subnets
resource "aws_route_table" "mine_it_public_route_table" {
  vpc_id = aws_vpc.mine_it_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mine_it_igw.id
  }

  tags = {
    Name = "Mine-IT-Public-Route-Table"
  }
}

resource "aws_route_table_association" "mine_it_public_subnet_associations" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.mine_it_public_subnets[count.index].id
  route_table_id = aws_route_table.mine_it_public_route_table.id
}

# Creating a NAT Gateway and Elastic IP for each private subnet
resource "aws_eip" "mine_it_nat_gateway_ips" {
  count = length(var.availability_zones)

  vpc = true
}

resource "aws_nat_gateway" "mine_it_nat_gateways" {
  count = length(var.availability_zones)

  subnet_id     = aws_subnet.mine_it_public_subnets[count.index].id
  allocation_id = aws_eip.mine_it_nat_gateway_ips[count.index].id

  tags = {
    Name = "Mine-IT-NAT-Gateway-${count.index + 1}"
  }
}

# Creating a private route table for each private subnet and associate it with the NAT Gateway
resource "aws_route_table" "mine_it_private_route_tables" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.mine_it_vpc.id

  tags = {
    Name = "Mine-IT-Private-Route-Table-${count.index + 1}"
  }
}

resource "aws_route" "mine_it_private_subnet_nat_routes" {
  count          = length(var.availability_zones)
  route_table_id = aws_route_table.mine_it_private_route_tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.mine_it_nat_gateways[count.index].id
}

# Creating S3 bucket
resource "aws_s3_bucket" "mine_it_s3_bucket" {
  bucket = var.s3_bucket_name

  acl    = "private"

  tags = {
    Name = "Mine-IT-S3-Bucket"
  }
}

# Creating EC2 instances in different subnets across availability zones
resource "aws_instance" "mine_it_ec2_instance" {
  count         = length(var.availability_zones)
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.mine_it_private_subnets[count.index].id

  tags = {
    Name = "Mine-IT-EC2-Instance-${count.index + 1}"
  }
}

resource "aws_ebs_volume" "mine_it_ebs_volume" {
  count            = length(var.availability_zones)
  availability_zone = aws_subnet.mine_it_private_subnets[count.index].availability_zone
  size              = var.volume_size_gb
  type              = "gp2"

  tags = {
    Name = "Mine-IT-EBS-Volume-${count.index + 1}"
  }
}

resource "aws_volume_attachment" "mine_it_ebs_attachment" {
  count       = length(var.availability_zones)
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.mine_it_ebs_volume[count.index].id
  instance_id = aws_instance.mine_it_ec2_instance[count.index].id
}
