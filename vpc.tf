# Create The VPC
resource "aws_vpc" "MainVpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "MainVPC"
    Env  = "Production"
  }
}

# Create Internet Gateway for the VPC
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.MainVpc.id
  tags = {
    Name = "MainIGW"
    Env  = "Production"
  }
}

# Create Public Subnet 1 — AZ index 0
resource "aws_subnet" "PublicSubnet1" {
  vpc_id                  = aws_vpc.MainVpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "Public Subnet1"
    Env  = "Production"
  }
}

# Create Public Subnet 2 — AZ index 1
resource "aws_subnet" "PublicSubnet2" {
  vpc_id                  = aws_vpc.MainVpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "Public Subnet2"
    Env  = "Production"
  }
}

# Create Private Subnet 1 — same AZ as PublicSubnet1
resource "aws_subnet" "PrivatSubnet1" {
  vpc_id            = aws_vpc.MainVpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "Private Subnet1"
    Env  = "Production"
  }
}

# Create Private Subnet 2 — same AZ as PublicSubnet2
resource "aws_subnet" "PrivatSubnet2" {
  vpc_id            = aws_vpc.MainVpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "Private Subnet2"
    Env  = "Production"
  }
}

# Create Route Table for Public Subnets
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.MainVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Public-RouteTable"
    Env  = "Production"
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "EIP-NAT" {
  domain = "vpc"
  tags = {
    Name = "NAT-EIP"
    Env  = "Production"
  }
}

# Create NAT Gateway in PublicSubnet1
resource "aws_nat_gateway" "NATGW" {
  allocation_id = aws_eip.EIP-NAT.id
  subnet_id     = aws_subnet.PublicSubnet1.id
  depends_on    = [aws_internet_gateway.IGW]
  tags = {
    Name = "Terraform-NAT"
    Env  = "Production"
  }
}

# Create Route Table for Private Subnets
resource "aws_route_table" "PrivateRT" {
  vpc_id = aws_vpc.MainVpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATGW.id
  }

  tags = {
    Name = "Private-RouteTable"
    Env  = "Production"
  }
}

# Route Table Association — Private Subnet 1
resource "aws_route_table_association" "PrivateRTAssoc1" {
  subnet_id      = aws_subnet.PrivatSubnet1.id
  route_table_id = aws_route_table.PrivateRT.id
}

# Route Table Association — Private Subnet 2
resource "aws_route_table_association" "PrivateRTAssoc2" {
  subnet_id      = aws_subnet.PrivatSubnet2.id
  route_table_id = aws_route_table.PrivateRT.id
}

# Route Table Association — Public Subnet 1
resource "aws_route_table_association" "RouteTableAssoc1" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.RT.id
}

# Route Table Association — Public Subnet 2
resource "aws_route_table_association" "RouteTableAssoc2" {
  subnet_id      = aws_subnet.PublicSubnet2.id
  route_table_id = aws_route_table.RT.id
}
