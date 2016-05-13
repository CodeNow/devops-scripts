/**
 * NAT for the VPC. Allows private subnet instances to talk to the internet
 * through the vpc gateway.
 */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public-a.id}"
  depends_on = ["aws_internet_gateway.gateway"]
}

/**
 * Elastic IP for the NAT.
 */
resource "aws_eip" "nat" {
  vpc = true
}
