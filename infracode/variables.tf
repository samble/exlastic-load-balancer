variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
  default="~/.ssh/exlastic.pem"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "exlastic"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-east-1"
}

variable "instance_name" {
  description = "AWS instance name"
  default = "exlastic"
}

variable "instance_type" {
  description = "AWS instance type"
  default = "t2.micro"
}

# Ubuntu Precise 12.04 LTS (x64)
variable "aws_amis" {
  default = {
    us-east-1 = "ami-0021766a"
  }
}
