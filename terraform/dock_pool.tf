
variable "name" { default = "dock_pool" }
variable "env" {}
variable "dock_pool_launch_configuration_version" {}
variable "dock_pool_ami_version" {}
variable "dock_pool_asg_min_size" { default = 1 }
variable "dock_pool_asg_max_size" { default = 10 }
variable "dock_pool_asg_desired" { default = 1 }
variable "dock_availability_zone" { default = "us-west-2a" }
variable "dock_ebs_block_device_size" { default = "120" }
variable "dock_ami_version" {}
variable "dock_pool_iam_profile" {}
variable "dock_instance_type" { default = "t2.medium" }
variable "dock_root_block_device_size" { defaullt = "8" }
variable "dock_ebs_block_device_snapshot" {}
variable "dock_subnet" {}
variable "dock_instance_sg" {}
variable "dock_pool_asg_name" {}
variable "dock_pool_lc" {}
variable "dock_pool_ami_name" {}
variable "dock_pool_ami_id" {}

data "aws_ami" "dock_pool_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.dock_pool_ami_name}"]
  }
}

resource "aws_launch_configuration" "dock_pool" {
  name                 = "${var.dock_pool_ami_name}"
  image_id             = "${var.dock_pool_ami_id}"
  instance_type        = "${var.dock_instance_type}"
  iam_instance_profile = "${var.dock_pool_iam_profile}"
  user_datak_pool_lc   = "${ file("dock-pool-user-data.sh") }"

  security_groups = ["${var.dock_instance_sg}"]
  key_name        = "${var.env}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "${var.dock_root_block_device_size}"
    delete_on_termination = true
  }

  ebs_block_device {
    volume_type           = "gp2"
    volume_size           = "${var.dock_ebs_block_device_size}"
    delete_on_termination = true
    snapshot_id           = "${var.dock_ebs_block_device_snapshot}"
    device_name           = "/dev/sdb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "dock_pool" {
  name                      = "${var.dock_pool_asg_name}"
  launch_configuration      = "${var.dock_pool_lc}"
  max_size                  = "${var.dock_pool_asg_max_size}"
  min_size                  = "${var.dock_pool_asg_max_size}"
  health_check_grace_period = 0
  health_check_type         = "EC2"
  availability_zones        = ["${var.dock_availability_zone}"]
  vpc_zone_identifier       = ["${var.dock_subnet}"]
  default_cooldown          = 0
  desired_capacity          = "${var.dock_pool_asg_desired}"
  force_delete              = true
  enabled_metrics           = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]

  tag {
    key                 = "role"
    value               = "dock"
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = "production-${var.env}"
    propagate_at_launch = true
  }
}
