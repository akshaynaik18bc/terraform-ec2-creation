provider "aws" {
    region = "us-east-1"
}
// variables 
variable "application_name" {
    type    = string
}
variable "region" {
    type    = string
}
variable "instance_type" {
    type    = string
}
variable "ami" {
    type    = string
}
variable "ssh_key" {
    type    = string
}
variable "ssh_ip" {
    type    = list(string)
}
// Security Group
resource "aws_security_group" "instance_security_group" {
    name = "${var.application_name}_instance_security_group_tf"
    ingress {
        protocol = "TCP"
        from_port = 443
        to_port = 443
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        protocol = "TCP"
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        protocol = "TCP"
        from_port = 22
        to_port = 22
        cidr_blocks = var.ssh_ip
    }

    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}
// end 

// instance 
resource "aws_instance" "phpinstance" {
    tags = {
        Name = "${var.application_name}_phpinstance"
    }
    instance_type = var.instance_type
    key_name = var.ssh_key
    ami = var.ami
    security_groups = [ aws_security_group.instance_security_group.name ]
    user_data = <<-EOF
            #!/bin/bash
            sudo apt-get update
            sudo apt-get -y install wget
            sudo apt-get -y install ruby
            wget https://aws-codedeploy-us-east-2.s3.amazonaws.com/latest/install -O install
            chmod +x ./install
            sudo ./install auto
            EOF
}
// end 

// elastic ip
resource "aws_eip" "tf_instance_elastic_ip" {
    instance = aws_instance.phpinstance.id
}


output "public_dns_of_instance" {
  value = aws_instance.phpinstance.public_dns
}