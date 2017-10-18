## ec2 module variables

# -------------------------------- VARIABLES --------------------------------- #
variable "lc_name_prefix" {
  default = "lc0-"
}

variable "ami" {
  default = "ami-ea87a78f"
}

variable "instance_type" {
  default = "t2.nano"
}

variable "key_name" {
  default = "devops-am"
}

variable "elb_name_prefix" {
  default = "elb0-"
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
variable "subpub0_id" {}
variable "subpub1_id" {}
variable "subpub2_id" {}
variable "sg_public0_id" {}
variable "sg_internal0_id" {}
variable "aws_region" {}
variable "aws_profile" {}
