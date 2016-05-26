/**
 * Public subnet for the VPC bound to the first availability zone.
 */
resource "aws_subnet" "public-a" {
  tags {
    Name = "public-subnet-a"
    Environment = "${var.environment}"
  }

  vpc_id = "${aws_vpc.sandbox.id}"
  cidr_block = "${var.public-subnet.cidr_block_a}"
  availability_zone = "${var.provider.region}a"
  map_public_ip_on_launch = false
}

/**
 * Route table for the sanbox public-a subnet.
 */
resource "aws_route_table" "public-a" {
  tags {
    Name = "public-subnet-a-route-table"
    Environment = "${var.environment}"
  }

  vpc_id = "${aws_vpc.sandbox.id}"
}

/**
 * Routes all traffic from the public-a subnet through the internet gateway.
 */
resource "aws_route" "public-a-to-internet-gateway" {
  route_table_id = "${aws_route_table.public-a.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gateway.id}"
}

/**
 * Maps the route table to the public-a subnet.
 */
resource "aws_route_table_association" "public-a" {
  subnet_id = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.public-a.id}"
}