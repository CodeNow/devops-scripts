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
