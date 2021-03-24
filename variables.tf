variable default_ingress {
  type = map(object({description = string, cidr_blocks = list(string)}))
  default = {
    22 = { description = "Inbound para SSH", cidr_blocks = [ "127.0.0.1/32" ]}
    80 = { description = "Inbound para HTTP", cidr_blocks = [ "127.0.0.1/32" ]}
  } 
}

variable "aws_lab_ami" {
  description = "def image ami in main.tf"
  default = "ami-01eb71e14cef400e2"
}

variable "tag_lab_vpc" {
  description = "def image ami in main.tf"
  default = "lab-vpc-name"
}

variable "tag_lab_subnet1" {
  description = "def image ami in main.tf"
  default = "lab-subnet1-name"
}

variable "aws_lab_instance_type" {
  description = "def instance type name in main.tf"
  default = "t2.micro"
}

variable "aws_lab_region" {
  description = "def region in main.tf"
  default= "sa-east-1"
}
