# The various ${var.foo} come from variables.tf

# Specify the provider and access details
provider "aws" {
    region = "${var.aws_region}"
    profile = "samble"
}


resource "aws_instance" "web" {

  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The path to your keyfile
    key_file = "${var.key_path}"
  }

  # subnet ID for our VPC
  #subnet_id = "${var.subnet_id}"

  # the instance type we want, comes from rundeck
  instance_type = "${var.instance_type}"

  # must be true to enable cloudwatch metrics
  monitoring = true

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair you've created and downloaded
  # from the AWS console.
  #
  # https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:
  #
  key_name = "${var.key_name}"


  # We set the name as a tag
  tags {
    "Name" = "${var.instance_name}"
  }

}

resource "aws_security_group" "allow_all" {
    name = "allow_all"
    description = "Allow all inbound traffic"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
