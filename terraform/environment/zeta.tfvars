/**
 * Variable definitions for the Runnable sandboxes `zeta` environment. This
 * environment will be used to migrate from our old "by hand" infrastructure to
 * management by terraform.
 */

environment = "zeta"
key_name = "zeta"
provider.region = "us-west-2"
provider.access_key = "AKIAI2DRCDSEREBPTQDQ"
provider.secret_key = "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"

/**
 * VPC resource configuration.
 */
vpc.cidr_block = "10.248.0.0/16"

/**
 * Subnet configuration.
 */
public-subnet.cidr_block_a = "10.248.0.0/24"
public-subnet.cidr_block_b = "10.248.1.0/24"
public-subnet.cidr_block_c = "10.248.2.0/24"
public-subnet.cidr_block_reserved = "10.248.3.0/24"

private-subnet.cidr_block_a = "10.248.4.0/24"
private-subnet.cidr_block_b = "10.248.5.0/24"
private-subnet.cidr_block_c = "10.248.6.0/24"
private-subnet.cidr_block_reserved = "10.248.7.0/24"

/**
 * Instance level configuration.
 */
bastion.ssh_port = "22"
