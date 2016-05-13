/**
 * Security group for the private-example server.
 */
resource "aws_security_group" "private-example" {
  tags {
    Name = "private-example"
    Environment = "${var.environment}"
  }

  vpc_id = "${aws_vpc.sandbox.id}"
  name = "private-example"
  description = "Example private subnet security group"
}

/**
 * Allows SSH (port 22) traffic inbound to private-example security group via
 * the bastion security group.
 */
resource "aws_security_group_rule" "private-example-bastion" {
  type = "ingress"
  security_group_id = "${aws_security_group.private-example.id}"
  source_security_group_id = "${aws_security_group.bastion.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
}

/**
 * Allows all outbound on the private-example security group.
 */
resource "aws_security_group_rule" "private-example-outbound" {
  type = "egress"
  security_group_id = "${aws_security_group.private-example.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
