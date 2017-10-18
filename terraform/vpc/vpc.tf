## vpc.tf

# ---------------------------------- VPCS ------------------------------------ #
resource "aws_vpc" "vpc00" {
  cidr_block  = "${var.cidr_vpc}"
  tags {
    Name        = "vpc00",
    Environment = "Development",
    Demo        = "devops-am"
  }
}


# --------------------------------- SUBNETS ---------------------------------- #
resource "aws_subnet" "subpub00" {
  vpc_id			            = "${aws_vpc.vpc00.id}"
  cidr_block			        = "${var.cidr_subpub[0]}"
  availability_zone		    = "${var.az[0]}"
  map_public_ip_on_launch = true
  tags {
    Name        = "subpub00",
    Environment = "Development",
    Demo        = "devops-am"
  }
}

resource "aws_subnet" "subpub11" {
  vpc_id			            = "${aws_vpc.vpc00.id}"
  cidr_block			        = "${var.cidr_subpub[1]}"
  availability_zone		    = "${var.az[1]}"
  map_public_ip_on_launch	= true
  tags {
    Name        = "subpub11",
    Environment = "Development",
    Demo        = "devops-am"
  }
}

resource "aws_subnet" "subpub22" {
  vpc_id			            = "${aws_vpc.vpc00.id}"
  cidr_block			        = "${var.cidr_subpub[2]}"
  availability_zone		    = "${var.az[2]}"
  map_public_ip_on_launch	= true
  tags {
    Name        = "subpub22",
    Environment = "Development",
    Demo        = "devops-am"
  }
}

resource "aws_subnet" "subpriv00" {
  vpc_id			            = "${aws_vpc.vpc00.id}"
  cidr_block			        = "${var.cidr_subpriv[0]}"
  availability_zone       = "${var.az[0]}"
  map_public_ip_on_launch = false
  tags {
    Name        = "subpriv00",
    Environment = "Development",
    Demo        = "devops-am"
  }
}

resource "aws_subnet" "subpriv11" {
  vpc_id			            = "${aws_vpc.vpc00.id}"
  cidr_block			        = "${var.cidr_subpriv[1]}"
  availability_zone       = "${var.az[1]}"
  map_public_ip_on_launch = false
  tags {
    Name        = "subpriv11",
    Environment = "Development",
    Demo        = "devops-am"
  }
}

resource "aws_subnet" "subpriv22" {
  vpc_id			            = "${aws_vpc.vpc00.id}"
  cidr_block			        = "${var.cidr_subpriv[2]}"
  availability_zone       = "${var.az[2]}"
  map_public_ip_on_launch = false
  tags {
    Name        = "subpriv22",
    Environment = "Development",
    Demo        = "devops-am"
  }
}


# ------------------------------- ROUTE TABLES ------------------------------- #
resource "aws_main_route_table_association" "rt_default" {
  vpc_id          = "${aws_vpc.vpc00.id}"
  route_table_id	= "${aws_route_table.rt00.id}"
}

resource "aws_route_table" "rt00" {
  vpc_id        = "${aws_vpc.vpc00.id}"
  route {
    cidr_block  = "${var.cidr_public}"
    gateway_id  = "${aws_internet_gateway.igw00.id}"
  }
  tags {
    Name        = "rt00",
    Environment = "Development",
    Demo        = "devops-am"
  }
}

resource "aws_route_table" "rt11" {
  vpc_id  = "${aws_vpc.vpc00.id}"
  route {
    cidr_block      = "${var.cidr_public}"
    nat_gateway_id  = "${aws_nat_gateway.natgw00.id}"
  }
  tags {
    Name        = "rt11",
    Environment = "Development",
    Demo        = "devops-am"
  }
}


resource "aws_route_table_association" "rt00_subpub00" {
  subnet_id       = "${aws_subnet.subpub00.id}"
  route_table_id	= "${aws_route_table.rt00.id}"
}

resource "aws_route_table_association" "rt00_subpub11" {
  subnet_id       = "${aws_subnet.subpub11.id}"
  route_table_id  = "${aws_route_table.rt00.id}"
}

resource "aws_route_table_association" "rt00_subpub22" {
  subnet_id       = "${aws_subnet.subpub22.id}"
  route_table_id  = "${aws_route_table.rt00.id}"
}

resource "aws_route_table_association" "rt11_subpriv00" {
  subnet_id       = "${aws_subnet.subpriv00.id}"
  route_table_id	= "${aws_route_table.rt11.id}"

}

resource "aws_route_table_association" "rt11_subpriv11" {
  subnet_id       = "${aws_subnet.subpriv11.id}"
  route_table_id  = "${aws_route_table.rt11.id}"
}

resource "aws_route_table_association" "rt11_subpriv22" {
  subnet_id       = "${aws_subnet.subpriv22.id}"
  route_table_id  = "${aws_route_table.rt11.id}"
}


# --------------------------- INTERNET GATEWAYS ------------------------------ #
resource "aws_internet_gateway" "igw00" {
  vpc_id  = "${aws_vpc.vpc00.id}"
  tags {
    Name        = "igw00",
    Environment = "Development",
    Demo        = "devops-am"
  }
}


# ------------------------------- NAT GATEWAYS ------------------------------- #
resource "aws_nat_gateway" "natgw00" {
  allocation_id = "${aws_eip.eip_nat.id}"
  subnet_id     = "${aws_subnet.subpub00.id}"
  tags {
    Name        = "natgw00",
    Environment = "Development",
    Demo        = "devops-am"
  }
}


# ------------------------------- ELASTIC IPS -------------------------------- #
resource "aws_eip" "eip_nat" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}


# ----------------------------- OUTPUT VARIABLES ----------------------------- #
output "subpub00_id" {
  value = "${aws_subnet.subpub00.id}"
}

output "subpub11_id" {
  value = "${aws_subnet.subpub11.id}"
}

output "subpub22_id" {
  value = "${aws_subnet.subpub22.id}"
}

output "subpriv00_id" {
  value = "${aws_subnet.subpriv00.id}"
}

output "subpriv11_id" {
  value = "${aws_subnet.subpriv11.id}"
}

output "subpriv22_id" {
  value = "${aws_subnet.subpriv22.id}"
}
