variable "aws_profile" {
  type = "string"
  default = "default"
}

variable "aws_region" {
  type = "string"
  default = "us-east-1"
}

variable "public_keypair" {
  type = "string"
  default = "ssh-rsa xxxxx"
}

variable "notify_email" {
  type = "string"
}

variable "environment" {
  type = "string"
}

variable "create_bastion" {
  type = "string"
}

variable "pocket_instancetype" {
  type = "string"
  default = "t3.small"
}

variable "geth_instancetype" {
  type = "string"
  default = "t3.large"
}
