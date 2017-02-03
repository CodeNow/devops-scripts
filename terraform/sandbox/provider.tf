/*
 * Default provider for all Runnable AWS resources.
 * @see https://www.terraform.io/docs/providers/aws/index.html
 * @author Ryan Sandor Richards
 */
provider "aws" {
  region = "us-west-2"
  access_key = "${var.provider.access_key}"
  secret_key = "${var.provider.secret_key}"
}
