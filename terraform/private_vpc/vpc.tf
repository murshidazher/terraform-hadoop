resource "aws_vpc" "main" {
  cidr_block           = "10.118.8.0/22"
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-openvpn-hadoop-stage"
  }
}

resource "aws_subnet" "external-01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.118.8.0/25"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "openvpn-hadoop-external-01"
  }

}
resource "aws_subnet" "external-02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.118.9.0/25"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "openvpn-hadoop-external-02"
  }

}

#internet gateway
resource "aws_internet_gateway" "stage-internet-gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "stage-internet-gw"
  }
}

# route table
resource "aws_route_table" "rt-table-public-ig" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.stage-internet-gw.id
  }

  tags = {
    Name = "rt-stage-external"
  }
}

# route table associtation to public subnets...
resource "aws_route_table_association" "rt-external-association" {
  subnet_id      = aws_subnet.external-01.id
  route_table_id = aws_route_table.rt-table-public-ig.id
}

resource "aws_route_table_association" "rt-external-02-association" {
  subnet_id      = aws_subnet.external-02.id
  route_table_id = aws_route_table.rt-table-public-ig.id
}

# elastic ip which will not be deleted after the resource is destroyed
resource "aws_eip" "nat" {
  vpc = true
}
