/**
 * Public subnet for the VPC bound to the first availability zone.
 * @param {string} environment Name of the environment.
 * @param {string} vpc.cidr_prefix Prefix for the CIDR of the VPC.
 * @param {string} provider.region Region for the provider (aws).
 */
resource "aws_subnet" "public-a" {
  vpc_id = "${aws_vpc.sandbox.id}"
  cidr_block = "${var.public-subnet.cidr_block_a}"
  availability_zone = "${var.provider.region}a"
  map_public_ip_on_launch = false
  tags {
    Name = "public-subnet-a"
    Environment = "${var.environment}"
  }
}

/**
 * Route table for the sanbox public-a subnet.
 *
 */
resource "aws_route_table" "public-a" {
  vpc_id = "${aws_vpc.sandbox.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.sandbox.id}"
  }
  tags {
    Name = "public-subnet-a-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.public-a.id}"
}
