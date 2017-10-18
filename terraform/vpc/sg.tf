## sg.tf

# ----------------------------- SECURITY GROUPS ------------------------------ #
## Assign sg_public0 to LB
resource "aws_security_group" "sg_public0" {
  name        = "sg_public0"
  description = "sg_public0"
  vpc_id      = "${aws_vpc.vpc0.id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_public}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_public}"]
  }
  depends_on  = ["aws_vpc.vpc0"]
  tags {
    Name        = "sg_public0",
    Environment = "Development"
  }
}

## Assign sg_internal0 to ASG instances
resource "aws_security_group" "sg_internal0" {
  name        = "sg_internal0"
  description = "sg_internal0"
  vpc_id      = "${aws_vpc.vpc0.id}"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sg_public0.id}"]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${var.cidr_secure}"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_secure}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_public}"]
  }
  depends_on  = ["aws_vpc.vpc0"]
  tags {
    Name        = "sg_internal0",
    Environment = "Development"
  }
}


# ----------------------------- OUTPUT VARIABLES ----------------------------- #
output "sg_public0_id" {
  value = "${aws_security_group.sg_public0.id}"
}

output "sg_internal0_id" {
  value = "${aws_security_group.sg_internal0.id}"
}
