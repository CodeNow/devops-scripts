/**
 * NAT (network address translation) security group.
 */
resource "aws_security_group" "nat" {
  tags {
    Name = "nat"
    Environment = "${var.environment}"
  }

  vpc_id = "${aws_vpc.sandbox.id}"
  name = "nat"
  description = "Ingress/Egress rules for the NAT"
}

/**
 * Ingress rule to allow SSH from the bastion server.
 */
resource "aws_security_group_rule" "nat-bastion" {
  type = "ingress"
  security_group_id = "${aws_security_group.nat.id}"
  source_security_group_id = "${aws_security_group.bastion.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
}

/**
 * Ingress rule to allow ping from everywhere.
 * TODO Should we allow this from the entire internet?
 */
resource "aws_security_group_rule" "nat-ping" {
  type = "ingress"
  security_group_id = "${aws_security_group.nat.id}"
  from_port = -1
  to_port = -1
  protocol = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
}

/**
 * Ingress rule to allow all inbound from VPC.
 */
resource "aws_security_group_rule" "nat-vpc-all" {
  type = "ingress"
  security_group_id = "${aws_security_group.nat.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["${var.vpc.cidr_block}"]
}

/**
 * Egress rule to allow all outbound traffic on the NAT.
 */
resource "aws_security_group_rule" "nat-outbound" {
  type = "egress"
  security_group_id = "${aws_security_group.nat.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
