
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

  ami_name                    = "unir-luis-aws-packer-activity"
  instance_type               = "t2.micro"
  region                      = "eu-west-1"
  vpc_id                      = "${var.vpc_id}"
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = true
  security_group_ids = ["${var.security_group_id_1}"]
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


  post-processor "manifest" {

  }

  post-processor "shell-local" {
    inline = [
      "SECURITY_GROUP_ID='${var.security_group_id_1}'",
      "SUBNET_ID='${var.subnet_id}'",
      "AMI_ID=$(jq -r '.builds[-1].artifact_id' packer-manifest.json | cut -d \":\" -f2)",
      "echo $AMI_ID",
      "echo 'Network Interfaces SECURITY GROUP: $SECURITY_GROUP_ID SUBNET: $SUBNET_ID'",
      "aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --key-name actividadpacker --security-group-ids $SECURITY_GROUP_ID --subnet-id $SUBNET_ID --region \"eu-west-1\""
    ]
  }


}

