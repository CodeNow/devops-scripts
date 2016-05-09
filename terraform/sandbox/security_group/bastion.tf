/**
 * Bastion security group. This allows trusted external sources to talk to
 * machines within the packer VPCs private subnet.
 */
resource "aws_security_group" "packer_bastion" {
  name = "packer_bastion"
  description = "Ingress/Egress rules for packer bastion"
  tags {
    Name = "packer_bastion_security_group"
    Environment = "packer"
  }

  // Allow specific, non-defualt, port for SSH communication to the packer VPC
  // via the bastion server.
  ingress {
    // TODO Pick a good port??? ._.
    from_port = 60199
    to_port = 60199
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
