terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  #define the remote backend
  backend "s3" {
    bucket = "terraform-backend-amandine"
    key    = "./terraform.tfstate"
    region = "us-east-1"
  }
}

#configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "security_group" {
  source = "../module/security_group"

  sg_tag = {
    Name = "sg_ubuntu_app_amandine"
  }

}

#include ec2 module
module "ec2_ubuntu_bionic" {
  source = "../module/ec2_ubuntu_bionic"

  #define the variables
  sg_name       = module.security_group.sg_name
  instance_type = "t2.micro"
  ec2_tag = {
    Name = "ec2_ubuntu_app_amandine"
  }
  key_name = "devops-amandine"
  key_path = "./devops-amandine.pem"
}


module "ip_lb" {
  source = "../module/ip_lb"

  ip_lb_tag = {
    Name = "ip_lb_ubuntu_app_amandine"
  }

}

module "ebs" {
  source = "../module/ebs"

  ebs_tag = {
    Name = "ebs_ubuntu_app_amandine"
  }
  ebs_availability_zone = "us-east-1a"
  ebs_size              = 10


}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.ec2_ubuntu_bionic.instance_id
  allocation_id = module.ip_lb.id
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs_amandine.volume_id
  instance_id   = module.ec2_ubuntu_bionic.instance_id
}