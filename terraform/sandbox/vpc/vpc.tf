/*
 * VPC Resource for the sandbox product infrastructure.
 */
resource "aws_vpc" "sandbox" {
  tags {
    Name = "vpc"
    Environment = "${var.environment}"
  }
  
  cidr_block = "${var.vpc.cidr_block}"
}
