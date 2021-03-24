locals {
//  vpc_id           = "vpc-0548d408bf3549ca0"
//  subnet_id        = "subnet-060a1ae52cf0a73d6"
  ssh_user         = "ubuntu"
  key_name         = "lab-tf-key"
  private_key_path = "~/lab-tf-key.pem"
}

provider "aws" {
  region = var.aws_lab_region
}

## Create VPC ##
resource "aws_vpc" "vpc-lab" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  name                 = "vpc-lab"
    tags = {
    Name = var.tag_lab_vpc
  }
}

## Create Subnets ##
resource "aws_subnet" "subnet_1-lab" {
  vpc_id            = aws_vpc.vpc-lab.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "sa-east-1a"
  name              = "subnet1-lab"
    tags = {
    Name = var.tag_lab_subnet1
  }
}

resource "aws_security_group" "nginx" {
  description = "Allow limited inbound external traffic"
  name   = "nginx_access"
  vpc_id = aws_vpc.vpc-lab.id

  dynamic "ingress" {
  for_each = var.default_ingress
    content {
      description = ingress.value["description"]
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
}

resource "aws_instance" "nginx" {
  ami                         = var.aws_lab_ami
  subnet_id                   = aws_subnet.subnet_1-lab.id
  instance_type               = var.aws_lab_instance_type
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.nginx.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} nginx.yaml"
  }
}

output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}
