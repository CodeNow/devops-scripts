/**
 * Private subnet for the VPC bound to the first availability zone.
 * @param {string} environment Name of the environment.
 * @param {string} vpc.cidr_prefix Prefix for the CIDR of the VPC.
 * @param {string} provider.region Region for the provider (aws).
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
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
  }
}

/**
 * Maps the route table to the private-a subnet.
 */
resource "aws_route_table_association" "private-a" {
  subnet_id = "${aws_subnet.private-a.id}"
  route_table_id = "${aws_route_table.private-a.id}"
}
