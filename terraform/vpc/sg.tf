## sg.tf

# ----------------------------- SECURITY GROUPS ------------------------------ #
## Assign sg_public00 to LB
resource "aws_security_group" "sg_public00" {
  name        = "sg_public00"
  description = "sg_public00"
  vpc_id      = "${aws_vpc.vpc00.id}"
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
  depends_on  = ["aws_vpc.vpc00"]
  tags {
    Name        = "sg_public00",
    Environment = "Development",
    Demo        = "devops-am"
  }
}

## Assigns sg_internal00 to ASG instances
resource "aws_security_group" "sg_internal00" {
  name        = "sg_internal00"
  description = "sg_internal00"
  vpc_id      = "${aws_vpc.vpc00.id}"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sg_public00.id}"]
  }
  ingress {
    from_port       = 8
    to_port         = 0
    protocol        = "icmp"
    security_groups = ["${aws_security_group.sg_secure00.id}"]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sg_secure00.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_public}"]
  }
  depends_on  = ["aws_vpc.vpc00"]
  tags {
    Name        = "sg_internal00",
    Environment = "Development",
    Demo        = "devops-am"
  }
}

## Assign sg_secure00 to bastion host(s)
resource "aws_security_group" "sg_secure00" {
  name        = "sg_secure00"
  description = "sg_secure00"
  vpc_id      = "${aws_vpc.vpc00.id}"
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
  depends_on  = ["aws_vpc.vpc00"]
  tags {
    Name        = "sg_secure00",
    Environment = "Development",
    Demo        = "devops-am"
  }
}


# ----------------------------- OUTPUT VARIABLES ----------------------------- #
output "sg_public00_id" {
  value = "${aws_security_group.sg_public00.id}"
}

output "sg_internal00_id" {
  value = "${aws_security_group.sg_internal00.id}"
}

output "sg_secure00_id" {
  value = "${aws_security_group.sg_secure00.id}"
}
