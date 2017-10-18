## elb.tf

# --------------------------- ELASTIC LOAD BALANCERS ------------------------- #
resource "aws_elb" "elb00" {
  name_prefix  = "elb00-"
  subnets = [
    "${var.subpub00_id}",
    "${var.subpub11_id}",
    "${var.subpub22_id}"
  ]
  security_groups = ["${var.sg_public00_id}"]
  listener  = {
    lb_port           = "${var.lb_port}"
    lb_protocol       = "${var.lb_protocol}"
    instance_port     = "${var.instance_port}"
    instance_protocol = "${var.instance_protocol}"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/up"
    interval            = 60
  }
}
