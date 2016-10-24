data "aws_ami" "dock_pool_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${ lookup(var.dock_pool_ami_name, var.env) }"]
  }
}

resource "aws_launch_configuration" "lc_dock_pool" {
  name                 = "${ lookup(var.dock_pool_ami_name, var.env) }"
  image_id             = "${ data.aws_ami.dock_pool_ami.id }"
  instance_type        = "${ lookup(var.dock_instance_type, var.env) }"
  iam_instance_profile = "${ lookup(var.dock_pool_iam_profile, var.env) }"
  user_data            = "${ file("dock-pool-user-data.sh") }"

  security_groups = ["${ lookup(var.dock_instance_sg, var.env) }"]
  key_name        = "${ var.env }"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "${ lookup(var.dock_root_block_device_size, var.env) }"
    delete_on_termination = true
  }

  ebs_block_device {
    volume_type           = "gp2"
    volume_size           = "${ lookup(var.dock_ebs_block_device_size, var.env) }"
    delete_on_termination = true
    snapshot_id           = "${ lookup(var.dock_ebs_block_device_snapshot, var.env) }"
    device_name           = "/dev/sdb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_dock_pool" {
  name                      = "${ lookup(var.dock_pool_asg_name, var.env) }"
  launch_configuration      = "${ aws_launch_configuration.lc_dock_pool.name }"
  max_size                  = "${ lookup(var.dock_pool_asg_max_size, var.env) }"
  min_size                  = "${ lookup(var.dock_pool_asg_min_size, var.env) }"
  health_check_grace_period = 0
  health_check_type         = "EC2"
  availability_zones        = ["${ lookup(var.dock_availability_zone, var.env) }"]
  vpc_zone_identifier       = ["${ lookup(var.dock_subnet, var.env) }"]
  default_cooldown          = 0
  desired_capacity          = 1
  force_delete              = true
  enabled_metrics           = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]

  tag {
    key                 = "role"
    value               = "dock"
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = "production-${ var.env }"
    propagate_at_launch = true
  }
}
