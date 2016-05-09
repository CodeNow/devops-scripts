/**
 * NAT (network address translation) security group.
 */
resource "aws_security_group" "packer_nat" {
  name = "packer_nat"
  description = "Ingress/Egress rules for packer NAT"
  tags {
    Name = "packer_nat_security_group"
    Environment = "packer"
  }

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

  // Allow all inbound from packer VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.254.0.0/16"]
  }

  // Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
