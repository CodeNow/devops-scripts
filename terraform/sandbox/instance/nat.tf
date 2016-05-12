/**
 * NAT Server for the VPC. Allows private subnet instances to talk to the
 * internet.
 * @param {string} environment Name of the environment.
 * @param {string} nat.ami Id of the AMI to use for the server.
 * @param {string} nat.instance_type EC2 instance type for the server.
 */
resource "aws_instance" "nat" {
  tags {
    Name = "nat"
    Environment = "${var.environment}"
  }

  ami = "${var.nat.ami}"
  associate_public_ip_address = true
  instance_type = "${var.nat.instance_type}"
  key_name = "${var.key_name}"
  security_groups = [
    "${aws_security_group.nat.id}"
  ]
  subnet_id = "${aws_subnet.public-a.id}"
}

/**
 * Elastic IP for the NAT instance.
 */
resource "aws_eip" "nat" {
  instance = "${aws_instance.nat.id}"
  vpc = true
}
