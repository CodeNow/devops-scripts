/**
 * Private example server. This is to test whether or not bastion is working
 * correctly in the vpc.
 */
resource "aws_instance" "private-example" {
  tags {
    Name = "private-example"
    Environment = "${var.environment}"
  }

  ami = "ami-9abea4fb"
  associate_public_ip_address = false
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  security_groups = [
    "${aws_security_group.private-example.id}"
  ]
  subnet_id = "${aws_subnet.private-a.id}"
}
