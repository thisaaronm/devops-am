## main.tf variables

# -------------------------------- VARIABLES --------------------------------- #
variable "aws_region" {
  default = "us-east-2"
}

variable "aws_cred" {
  default = "~/.aws/credentials"
}

## change AWS credentials profile as necessary
variable "aws_profile" {
  default = "default"
}
