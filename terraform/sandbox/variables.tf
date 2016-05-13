/**
 * Defines the environment for which to build the infrastructure. This allows
 * us to change the basic environment labels for all resources in AWS to easily
 * differentiate between VPCs in oregon (us-west-2)
 * @type {string}
 */
variable "environment" {
  type = "string"
  default = "undefined"
}

/**
 * AWS key name to use for instances in the VPC.
 * @type {string}
 */
variable "key_name" {
  type = "string"
  default = "undefined"
}

/**
 * Details for the AWS provider. Includes region, access keys, etc.
 * @type {map}
 */
variable "provider" {
  type = "map"
  default = {
    access_key = "undefined"
    secret_key = "undefined"
    region = "undefined"
  }
}

/**
 * VPC specific configuration.
 * @type {map}
 */
variable "vpc" {
  type = "map"
  default = {
    cidr_block = "10.undefined.0.0/16"
  }
}

/**
 * Defines options for changing details about public subnets in the VPC.
 * @type {map}
 */
variable "public-subnet" {
  type = "map"
  default = {
    cidr_block_a = "10.undefined.0.0/24"
    cidr_block_b = "10.undefined.1.0/24"
    cidr_block_c = "10.undefined.2.0/24"
    cidr_block_reserved = "10.undefined.3.0/24"
  }
}

/**
 * Defines options for changing details about private subnets in the VPC.
 * @type {map}
 */
variable "private-subnet" {
  type = "map"
  default = {
    cidr_block_a = "10.undefined.0.0/24"
    cidr_block_b = "10.undefined.1.0/24"
    cidr_block_c = "10.undefined.2.0/24"
    cidr_block_reserved = "10.undefined.3.0/24"
  }
}

/**
 * Bastion options for the VPC.
 * @type {map}
 */
variable "bastion" {
  type = "map"
  default = {
    ami = "ami-9abea4fb" # Ubuntu Server 14.04 LTS (HVM), SSD Volume Type
    instance_type = "t2.micro"
    ssh_port = -1
  }
}

/**
 * Options for the NAT.
 * @type {map}
 */
variable "nat" {
  type = "map"
  default = {
    ami = "ami-290f4119" # amzn-ami-vpc-nat-hvm-2014.09.1.x86_64-gp2
    instance_type = "t2.micro"
  }
}
