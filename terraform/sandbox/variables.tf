variable "env" {
  type = "string"
  default = "staging-a"
  description = "Name of the environment to mutate via terraform"
}

variable "provider" {
  type = "map"
  default = {
    access_key = "undefined"
    secret_key = "undefined"
    region = "us-west-2"
  }
}

variable "vpc" {
  type = "map"
  default = {
    cidr_block = "10.invalid.0.0/16"
  }
}

variable "public-subnet" {
  type = "map"
  default = {
    cidr_block_a = "10.invalid.0.0/24"
    cidr_block_b = "10.invalid.1.0/24"
    cidr_block_c = "10.invalid.2.0/24"
    cidr_block_reserved = "10.invalid.3.0/24"
  }
}
