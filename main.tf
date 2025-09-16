# Get the latest Ubuntu 22.04 LTS AMI from Canonical (owner ID is Canonical)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 1) Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "tf-vpc"
  }
}

# 2) Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "tf-igw" }
}

# 3) Create Custom Route Table (public route to IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "tf-public-rt" }
}

# 4) Create Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = false   # we will use an EIP on an ENI instead of automatic public IP
  tags = { Name = "tf-public-subnet" }
}

# 5) Associate subnet with Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 6) Create Security Group to allow ports 22, 80, 443
resource "aws_security_group" "ssh_http_https" {
  name        = "tf-ssh-http-https"
  description = "Allow SSH, HTTP, HTTPS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "tf-sg-ssh-http-https" }
}

# 7) Create a network interface with an IP in the subnet created above
# We'll pick a deterministic host IP inside the subnet using cidrhost(..., 10)
resource "aws_network_interface" "eni" {
  subnet_id       = aws_subnet.public.id
  private_ips     = [cidrhost(aws_subnet.public.cidr_block, 10)]
  description     = "tf-eni-for-web"
  security_groups = [aws_security_group.ssh_http_https.id]
  tags = { Name = "tf-eni" }
}


# 8) Assign an Elastic IP to the network interface
resource "aws_eip" "eip" {  
  network_interface = aws_network_interface.eni.id
  tags = { Name = "tf-eip" }
}


# 9) Create Ubuntu Server with Apache
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh_http_https.id]

  associate_public_ip_address = true  # <-- public IP directly assigned

  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt-get update -y
              DEBIAN_FRONTEND=noninteractive apt-get install -y apache2
              systemctl enable apache2
              systemctl start apache2
              EOF

  tags = { Name = "tf-ubuntu-apache" }
}
