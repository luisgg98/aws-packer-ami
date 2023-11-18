
##################
##
##  Universidad Internacional de la Rioja
##  Luis Garcia Garces
##
##################
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.7"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


source "amazon-ebs" "ubuntu" {

  ami_name                    = "unir-luis-aws-packer-activity-1"
  instance_type               = "t2.micro"
  region                      = "eu-west-1"
  vpc_id ="vpc-0a60677de1be17332"
  subnet_id                   = "subnet-0f7196f3559d61d10"
  associate_public_ip_address = true
  security_group_ids = ["sg-08084adb365fa1a54","sg-0bb50ef687b7e2aec"]
  temporary_key_pair_type= "ed25519"
  ssh_timeout = "45m"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"

}

build {
  name    = "learn-packer"
  sources = ["source.amazon-ebs.ubuntu"]


  provisioner "file" {
    destination = "/tmp/server.js"
    source      = "server.js"
  }

  provisioner "file" {
    destination = "/tmp/default.conf"
    source      = "default.conf"
  }

  provisioner "shell" {
    script       = "install.sh"
  }

}

