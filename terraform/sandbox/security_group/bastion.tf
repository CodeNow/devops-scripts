/**
 * Bastion security group. This allows trusted external sources to talk to
 * machines within the packer VPCs private subnet.
 * @param {string} environment Name of the environment.
 * @param {integer} bastion.ssh_port The port on which bastion should allow
 *   ssh connections.
 */
resource "aws_security_group" "bastion" {
  tags {
    Name = "bastion"
    Environment = "${var.environment}"
  }

  vpc_id = "${aws_vpc.sandbox.id}"
  name = "bastion"
  description = "Ingress/Egress rules for the VPC bastion server"

  // Allow a specific, non-defualt, port for SSH communication to the VPC
  ingress {
    from_port = "${var.bastion.ssh_port}"
    to_port = "${var.bastion.ssh_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
