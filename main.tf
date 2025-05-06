provider "aws" {
  region = "us-west-2"
}

variable "vpc_cidr_block" {}
variable "env_prefix" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "region" {}
variable "instance_type" {}
variable "my_ip" {}
variable "docker_user" {}
variable "docker_pass" {}
variable "keypair_name" {}

resource "aws_vpc" "morefix-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "moreflix-subnet" {
  vpc_id            = aws_vpc.morefix-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name : "${var.env_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "moreflix_igw" {
  vpc_id = aws_vpc.morefix-vpc.id
  tags = {
    Name : "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "moreflix_rt" {
  vpc_id = aws_vpc.morefix-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.moreflix_igw.id
  }

  tags = {
    Name : "${var.env_prefix}-rtb"
  }
}

resource "aws_route_table_association" "a-rtb" {
  subnet_id      = aws_subnet.moreflix-subnet.id
  route_table_id = aws_route_table.moreflix_rt.id
}

resource "aws_security_group" "moreflix_sg" {
  name   = "${var.env_prefix}-sg"
  vpc_id = aws_vpc.morefix-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "TCP"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
}

data "aws_ami" "latest-ubuntu-linux-image" {
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

resource "aws_instance" "moreflix-server" {
  ami           = data.aws_ami.latest-ubuntu-linux-image.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.moreflix-subnet.id
  vpc_security_group_ids = [aws_security_group.moreflix_sg.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true

  key_name                    = var.keypair_name

  user_data_replace_on_change = true

  user_data = file("${path.module}/bootup-script.sh")

  tags = {
    Name = "${var.env_prefix}-server"
  }
}

output "ec2_public_ip" {
  value = aws_instance.moreflix-server.public_ip
}