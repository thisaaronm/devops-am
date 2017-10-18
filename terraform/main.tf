## main.tf

# -------------------------------- PROVIDERS --------------------------------- #
provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "${var.aws_cred}"
  profile                 = "${var.aws_profile}"
}


# --------------------------------- MODULES ---------------------------------- #
module "vpc" {
  source  = "./vpc"
}

module "ec2" {
  source           = "./ec2"
  subpub0_id       = "${module.vpc.subpub0_id}"
  subpub1_id       = "${module.vpc.subpub1_id}"
  subpub2_id       = "${module.vpc.subpub2_id}"
  sg_public0_id    = "${module.vpc.sg_public0_id}"
  sg_internal0_id  = "${module.vpc.sg_internal0_id}"
  aws_region       = "${var.aws_region}"
  aws_profile      = "${var.aws_profile}"
}
