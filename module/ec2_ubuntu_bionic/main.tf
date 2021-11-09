data "aws_ami" "ami_ubuntu_bionic" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

#create ec2
resource "aws_instance" "web_ec2" {
  ami             = data.aws_ami.ami_ubuntu_bionic.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [var.sg_name]
  
  tags = var.ec2_tag

#provisioner local: creer file and copy public_ip
provisioner "local-exec" {
    command = "echo ${aws_instance.web_ec2.public_ip} >> ip_ec2.txt"
  }

#provisioner remote(distant):install and start nginx after creating our vm
  provisioner "remote-exec" {
    inline = [
      "sudo apt install -y nginx",
      "sudo systemctl start nginx",
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.key_path)
    host        = self.public_ip
    timeout     = "30s"
  }

  root_block_device {
    delete_on_termination = true
  }
}
