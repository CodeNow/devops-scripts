/**
 * Internet gateway for the sanbox infrastructure.
 * @param {string} environment Name of the environment.
 */
resource "aws_internet_gateway" "sandbox" {
  tags {
    Name = "gateway"
    Environment = "${var.environment}"
  }

  vpc_id = "${aws_vpc.sandbox.id}"
}
