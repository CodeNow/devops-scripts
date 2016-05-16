/**
 * Private subnet for the VPC bound to the first availability zone.
 */
resource "aws_subnet" "private-a" {
  tags {
    Name = "private-subnet-a"
    Environment = "${var.environment}"
  }

  vpc_id = "${aws_vpc.sandbox.id}"
  cidr_block = "${var.private-subnet.cidr_block_a}"
  availability_zone = "${var.provider.region}a"
  map_public_ip_on_launch = false
}

/**
 * Route table for the sanbox private-a subnet.
 */
resource "aws_route_table" "private-a" {
  tags {
    Name = "private-subnet-a-route-table"
    Environment = "${var.environment}"
  }

  vpc_id = "${aws_vpc.sandbox.id}"
}

/**
 * Routes all outbound traffic from the private-a subnet to the NAT.
 */
resource "aws_route" "private-a-to-nat" {
  route_table_id = "${aws_route_table.private-a.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.nat.id}"
  depends_on = ["aws_route_table.private-a"]
}

/**
 * Maps the route table to the private-a subnet.
 */
resource "aws_route_table_association" "private-a" {
  subnet_id = "${aws_subnet.private-a.id}"
  route_table_id = "${aws_route_table.private-a.id}"
}
