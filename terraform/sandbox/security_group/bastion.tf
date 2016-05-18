/**
 * Bastion security group. This allows trusted external sources to talk to
 * machines within the packer VPCs private subnet.
 */
resource "aws_security_group" "bastion" {
  tags {
    Name = "bastion"
    Environment = "${var.environment}"
  }

  vpc_id = "${aws_vpc.sandbox.id}"
  name = "bastion"
  description = "Ingress/Egress rules for the VPC bastion server"
}

/**
 * Allows inbound SSH connections from the internet to the bastion server.
 */
resource "aws_security_group_rule" "bastion-ingress-ssh" {
  type = "ingress"
  security_group_id = "${aws_security_group.bastion.id}"
  from_port = "${var.bastion.ssh_port}"
  to_port = "${var.bastion.ssh_port}"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

/**
 * Allows all outbound traffic from the bastion server.
 */
resource "aws_security_group_rule" "bastion-egress-all" {
  type = "egress"
  security_group_id = "${aws_security_group.bastion.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
