## ec2 module variables

# -------------------------------- VARIABLES --------------------------------- #
variable "ami" {
  default = "ami-c5062ba0"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "devops-am"
}

## CHANGE TO YOUR OWN BUCKET NAME
variable "s3_bucket" {
  default = "devops-am"
}

variable "lb_port" {
  default = 80
}

variable "lb_protocol" {
  default = "http"
}

variable "instance_port" {
  default = 80
}

variable "instance_protocol" {
  default = "http"
}


## Undefined variables used by the ec2 module (defined in main.tf)
variable "subpub00_id" {}
variable "subpub11_id" {}
variable "subpub22_id" {}
variable "subpriv00_id" {}
variable "subpriv11_id" {}
variable "subpriv22_id" {}
variable "sg_public00_id" {}
variable "sg_internal00_id" {}
variable "aws_region" {}
variable "aws_profile" {}
