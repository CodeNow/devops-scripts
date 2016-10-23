variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
  default = "us-west-2"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}
