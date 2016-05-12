/**
 * NAT (network address translation) security group.
 * @param {string} environment Name of the environment.
 * @param {string} vpc.cidr_block CIDR block for the VPC.
 */
resource "aws_security_group" "nat" {
  tags {
    Name = "nat"
    Environment = "${var.environment}"
  }

  vpc_id = "${aws_vpc.sandbox.id}"
  name = "nat"
  description = "Ingress/Egress rules for the NAT"

  // Allow inbound SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow inbound PING (ICMP)
  ingress {
    from_port = 0
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow all inbound from the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["${var.vpc.cidr_block}"]
  }

  // Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
