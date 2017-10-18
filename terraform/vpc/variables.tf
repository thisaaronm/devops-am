## VPC module variables

# -------------------------------- VARIABLES --------------------------------- #
variable "cidr_vpc" {
  default = "10.20.0.0/16"
}

variable "cidr_subpub" {
  default = [
    "10.20.0.0/24",
    "10.20.1.0/24",
    "10.20.2.0/24"
  ]
}

variable "az" {
  default = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c"
  ]
}

variable "cidr_public" {
  default = "0.0.0.0/0"
}

## REPLACE WITH AUTHORIZED PUBLIC IPS IN CIDR FOR ADMINISTRATIVE ACCESS
variable "cidr_secure" {
  default = [
    "0.0.0.0/0"
  ]
}
