## vpc module variables

# -------------------------------- VARIABLES --------------------------------- #
variable "cidr_vpc" {
  default = "10.99.0.0/16"
}

variable "cidr_subpub" {
  default = [
    "10.99.0.0/24",
    "10.99.1.0/24",
    "10.99.2.0/24"
  ]
}

variable "cidr_subpriv" {
  default = [
    "10.99.3.0/24",
    "10.99.4.0/24",
    "10.99.5.0/24"
  ]
}

variable "cidr_public" {
  default = "0.0.0.0/0"
}

variable "az" {
  default = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c"
  ]
}

#### REPLACE WITH AUTHORIZED PUBLIC IPS (IN CIDR) FOR ADMINISTRATIVE ACCESS ####
variable "cidr_secure" {
  default = [
    "0.0.0.0/0"
  ]
}
