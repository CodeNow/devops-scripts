variable "dock_pool_ami_name" {
  type = "map"

  default = {
    delta   = "delta-dock-2.0.5"
    gamma   = "gamma-dock-2.0.5"
    epsilon = "epsilon-dock-2.0.5"
  }
}

variable "dock_pool_lc_name" {
  type = "map"

  default = {
    delta   = "delta-lc-dock-pool"
    gamma   = "gamma-lc-dock-pool"
    epsilon = "epsilon-lc-dock-pool"
  }
}

variable "dock_pool_iam_profile" {
  type = "map"

  default = {
    delta   = "delta-dock-pool"
    gamma   = "gamma-dock-pool"
    epsilon = "epsilon-dock-pool"
  }
}

variable "dock_pool_asg_name" {
  type = "map"

  default = {
    delta   = "delta-asg-dock-pool"
    gamma   = "gamma-asg-dock-pool"
    epsilon = "epsilon-asg-dock-pool"
  }
}

variable "dock_pool_asg_max_size" {
  type = "map"

  default = {
    delta   = 10
    gamma   = 10
    epsilon = 10
  }
}

variable "dock_pool_asg_min_size" {
  type = "map"

  default = {
    delta   = 3
    gamma   = 1
    epsilon = 1
  }
}

variable "dock_pool_asg_desired" {
  type = "map"

  default = {
    delta   = 3
    gamma   = 1
    epsilon = 1
  }
}
