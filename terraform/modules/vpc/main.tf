# VPC module - create VPC, subnets, internet gateway, NAT gateway and route tables

# create VPC
resource "aws_vpc" "ly_vpc" {
  cidr_block = var.vpc_cidr           # IP ranges for VPC
  enable_dns_support   = true         # Enable DNS 
  enable_dns_hostnames = true         # Enable DNS hostnames for instances
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.ly_vpc.id          # on the created VPC
  cidr_block              = var.public_subnet_cidr     # IP ranges
  availability_zone       = var.public_subnet_az       # AZ for subnet
  map_public_ip_on_launch = true                      # assign public IP
  
  tags = {
    Name = "Public Subnet"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.ly_vpc.id          # Attach to created VPC
}

# Create route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ly_vpc.id          # Attached to created VPC

  route {
    cidr_block = "0.0.0.0/0"          # Route all external traffic
    gateway_id = aws_internet_gateway.main_igw.id  # via the igw
  }
}

# join public subnet with public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id    # Public subnet
  route_table_id = aws_route_table.public_rt.id   # Public route table
}

# Create NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"                       # Allocate EIP in VPC domain
}






# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.ly_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.private_subnet_az

  tags = {
    Name = "Private Subnet"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# Create route table for private subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.ly_vpc.id          # on the created  VPC

  route {
    cidr_block     = "0.0.0.0/0"      # Route all external traffic
    nat_gateway_id = aws_nat_gateway.main.id  # via the NAT gateway
  }
}

# join private subnet with private route table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id   # Private subnet
  route_table_id = aws_route_table.private_rt.id  # Private route table
}

# Create NAT Gateway for private subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id                  # Use allocated EIP
  subnet_id     = aws_subnet.public_subnet.id     # Place in public subnet
  depends_on    = [aws_internet_gateway.main_igw] # make sure IGW is established
}
