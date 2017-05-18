/**
 * Bastion server for the VPC. The bastion server allows those with credentials
 * (e.g. a signed pem file) to SSH through it and into the private subnet.
 */
resource "aws_instance" "bastion" {
  tags {
    Name = "bastion"
    Environment = "${var.environment}"
  }

  ami = "${var.bastion.ami}"
  associate_public_ip_address = true
  instance_type = "${var.bastion.instance_type}"
  key_name = "${var.key_name}"
  security_groups = [
    "${aws_security_group.bastion.id}"
  ]
  subnet_id = "${aws_subnet.public-a.id}"
}