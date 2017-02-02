variable "env" {}
variable "dock_pool_launch_configuration_version" {}
variable "dock_pool_ami_version" {}
variable "dock_pool_asg_desired" {}
variable "dock_availability_zone" {}
variable "dock_ami_version" {}
variable "dock_pool_iam_profile" {}
variable "dock_instance_type" {}
variable "dock_ebs_block_device_snapshot" {}
variable "dock_subnet" {}
variable "dock_instance_sg" {}
variable "dock_pool_asg_name" {}
variable "dock_pool_lc" {}
variable "dock_pool_ami_name" {}
variable "aws_access_key" { default = "AKIAI2DRCDSEREBPTQDQ" }
variable "aws_secret_key" { default = "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" }
variable "region" { default = "us-west-2a" }

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

module "dock_pool" {
  source = "../../terraform"

  env = "${var.env}"
  dock_pool_launch_configuration_version = "${var.dock_pool_launch_configuration_version}"
  dock_pool_ami_version = "${var.dock_pool_ami_version}"
  dock_pool_asg_desired = "${var.dock_pool_asg_desired}"
  dock_availability_zone = "${var.dock_availability_zone}"
  dock_ami_version = "${var.dock_ami_version}"
  dock_pool_iam_profile = "${var.dock_pool_iam_profile}"
  dock_instance_type = "${var.dock_instance_type}"
  dock_ebs_block_device_snapshot = "${var.dock_ebs_block_device_snapshot}"
  dock_subnet = "${var.dock_subnet}"
  dock_instance_sg = "${var.dock_instance_sg}"
  dock_pool_asg_name = "${var.dock_pool_asg_name}"
  dock_pool_lc = "${var.dock_pool_lc}"
  dock_pool_ami_name = "${var.dock_pool_ami_name}"
  dock_pool_ami_id = "gamma-dock-2.0.11"
}
