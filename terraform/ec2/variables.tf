## ec2 module variables

# -------------------------------- VARIABLES --------------------------------- #
variable "ami" {
  default = "ami-ea87a78f"
}

variable "instance_type" {
  default = "t2.nano"
}

variable "key_name" {
  default = "devops-am"
}

variable "prov_conn_type" {
  default = "ssh"
}

variable "prov_conn_user" {
  default = "ec2-user"
}

variable "prov_conn_key_path" {
  default = "~/devops-am/ansible"
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
variable "sg_secure00_id" {}
variable "aws_region" {}
variable "aws_profile" {}
