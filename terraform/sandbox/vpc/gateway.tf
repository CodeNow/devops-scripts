/**
 * Internet gateway for the sanbox infrastructure.
 */
resource "aws_internet_gateway" "gateway" {
  tags {
    Name = "gateway"
    Environment = "${var.environment}"
  }

  vpc_id = "${aws_vpc.sandbox.id}"
}
