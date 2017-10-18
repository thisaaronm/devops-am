## main.tf

# -------------------------------- PROVIDERS --------------------------------- #
provider "aws" {
  region                    = "${var.aws_region}"
  shared_credentials_file   = "${var.aws_cred}"
  profile                   = "${var.aws_profile}"
}


# --------------------------------- MODULES ---------------------------------- #
module "vpc" {
  source      = "./vpc"
}

module "ec2" {
  source           = "./ec2"
  subpub00_id      = "${module.vpc.subpub00_id}"
  subpub11_id      = "${module.vpc.subpub11_id}"
  subpub22_id      = "${module.vpc.subpub22_id}"
  subpriv00_id     = "${module.vpc.subpriv00_id}"
  subpriv11_id     = "${module.vpc.subpriv11_id}"
  subpriv22_id     = "${module.vpc.subpriv22_id}"
  sg_public00_id   = "${module.vpc.sg_public00_id}"
  sg_internal00_id = "${module.vpc.sg_internal00_id}"
  aws_region       = "${var.aws_region}"
  aws_profile      = "${var.aws_profile}"
}
