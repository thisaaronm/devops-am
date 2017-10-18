## elb.tf

# --------------------------- ELASTIC LOAD BALANCERS ------------------------- #
resource "aws_elb" "elb0" {
  name_prefix     = "${var.elb_name_prefix}"
  subnets         = ["${var.subpub0_id}","${var.subpub1_id}","${var.subpub2_id}"]
  security_groups = ["${var.sg_public0_id}"]
  listener = {
    lb_port           = "${var.lb_port}"
    lb_protocol       = "${var.lb_protocol}"
    instance_port     = "${var.instance_port}"
    instance_protocol = "${var.instance_protocol}"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/up"
    interval            = 30
  }
}
