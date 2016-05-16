/*
 * VPC Resource for the sandbox product infrastructure.
 */
resource "aws_vpc" "sandbox" {
  cidr_block = "${var.vpc.cidr_block}"
  tags {
    Name = "vpc"
    Environment = "${var.environment}"
  }
}
