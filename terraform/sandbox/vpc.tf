/*
 * VPC Resource for the sanbox product infrastructure.
 * @param {string} environment Name of the environment.
 * @param {string} vpc.cidr_block CIDR block for the VPC.
 */
resource "aws_vpc" "sandbox" {
  cidr_block = "${var.vpc.cidr_block}"
  tags {
    Name = "vpc"
    Environment = "${var.environment}"
  }
}

/**
 * Internet gateway for the sanbox infrastructure.
 * @param {string} environment Name of the environment.
 */
resource "aws_internet_gateway" "sandbox" {
  vpc_id = "${aws_vpc.sandbox.id}"
  tags {
    Name = "gateway"
    Environment = "${var.environment}"
  }
}
