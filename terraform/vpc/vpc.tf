## vpc.tf

# ---------------------------------- VPCS ------------------------------------ #
resource "aws_vpc" "vpc0" {
  cidr_block			= "${var.cidr_vpc}"
  tags {
    Name          = "vpc0",
    Environment   = "Development"
  }
}


# --------------------------------- SUBNETS ---------------------------------- #
resource "aws_subnet" "subpub0" {
  vpc_id			            = "${aws_vpc.vpc0.id}"
  cidr_block			        = "${var.cidr_subpub[0]}"
  availability_zone		    = "${var.az[0]}"
  map_public_ip_on_launch	= true
  tags {
    Name        = "subpub0",
    Environment = "Development"
  }
}

resource "aws_subnet" "subpub1" {
  vpc_id			            = "${aws_vpc.vpc0.id}"
  cidr_block			        = "${var.cidr_subpub[1]}"
  availability_zone		    = "${var.az[1]}"
  map_public_ip_on_launch	= true
  tags {
    Name        = "subpub1",
    Environment = "Development"
  }
}

resource "aws_subnet" "subpub2" {
  vpc_id			            = "${aws_vpc.vpc0.id}"
  cidr_block			        = "${var.cidr_subpub[2]}"
  availability_zone		    = "${var.az[2]}"
  map_public_ip_on_launch	= true
  tags {
    Name        = "subpub2",
    Environment = "Development"
  }
}


# ------------------------------- ROUTE TABLES ------------------------------- #
resource "aws_main_route_table_association" "rt_default" {
  vpc_id          = "${aws_vpc.vpc0.id}"
  route_table_id	= "${aws_route_table.rt0.id}"
}

resource "aws_route_table" "rt0" {
  vpc_id  = "${aws_vpc.vpc0.id}"
  route {
    cidr_block  = "${var.cidr_public}"
    gateway_id  = "${aws_internet_gateway.igw0.id}"
  }
  tags {
    Name        = "rt0",
    Environment = "Development"
  }
}

resource "aws_route_table_association" "rt0_subpub0" {
  subnet_id       = "${aws_subnet.subpub0.id}"
  route_table_id  = "${aws_route_table.rt0.id}"
}

resource "aws_route_table_association" "rt0_subpub1" {
  subnet_id       = "${aws_subnet.subpub1.id}"
  route_table_id  = "${aws_route_table.rt0.id}"
}

resource "aws_route_table_association" "rt0_subpub2" {
  subnet_id       = "${aws_subnet.subpub2.id}"
  route_table_id  = "${aws_route_table.rt0.id}"
}


# --------------------------- INTERNET GATEWAYS ------------------------------ #
resource "aws_internet_gateway" "igw0" {
  vpc_id  = "${aws_vpc.vpc0.id}"
  tags {
    Name        = "igw0",
    Environment = "Development"
  }
}


# ----------------------------- OUTPUT VARIABLES ----------------------------- #
output "subpub0_id" {
  value = "${aws_subnet.subpub0.id}"
}

output "subpub1_id" {
  value = "${aws_subnet.subpub1.id}"
}

output "subpub2_id" {
  value = "${aws_subnet.subpub2.id}"
}
