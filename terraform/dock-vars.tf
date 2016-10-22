variable "dock_instance_type" {
  type = "map"
  default = {
    delta = "m4.large"
    gamma = "t2.medium"
    epsilon = "t2.medium"
  }
}

variable "dock_instance_sg" {
  type = "map"
  default = {
    delta = "XXXXXX"
    gamma = "sg-577a0d33"
    epsilon = "XXXXXX"
  }
}

variable "dock_root_block_device_size" {
  type = "map"
  default = {
    delta = "8"
    gamma = "8"
    epsilon = "8"
  }
}

variable "dock_ebs_block_device_size" {
  type = "map"
  default = {
    delta = "120"
    gamma = "120"
    epsilon = "120"
  }
}

variable "dock_ebs_block_device_snapshot" {
  type = "map"
  default = {
    delta = "XXXXXXX"
    gamma = "snap-1abeb7e0"
    epsilon = "XXXXXXX"
  }
}

variable "dock_availability_zone" {
  type = "map"
  default = {
    delta = "XXXXXXX"
    gamma = "us-west-2a"
    epsilon = "XXXXXXX"
  }
}

variable "dock_subnet" {
  type = "map"
  default = {
    delta = "XXXXXXX"
    gamma = "subnet-9cb197f9"
    epsilon = "XXXXXXX"
  }
}
