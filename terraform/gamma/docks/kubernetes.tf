output "cluster_name" {
  value = "kubernetes-dock.runnable-gamma.com"
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-kubernetes-dock-runnable-gamma-com.id}"]
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-kubernetes-dock-runnable-gamma-com.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.us-west-2a-kubernetes-dock-runnable-gamma-com.id}"]
}

output "region" {
  value = "us-west-2"
}

output "vpc_id" {
  value = "vpc-c53464a0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_autoscaling_group" "master-us-west-2a-masters-kubernetes-dock-runnable-gamma-com" {
  name                 = "master-us-west-2a.masters.kubernetes-dock.runnable-gamma.com"
  launch_configuration = "${aws_launch_configuration.master-us-west-2a-masters-kubernetes-dock-runnable-gamma-com.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.us-west-2a-kubernetes-dock-runnable-gamma-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "kubernetes-dock.runnable-gamma.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-west-2a.masters.kubernetes-dock.runnable-gamma.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-kubernetes-dock-runnable-gamma-com" {
  name                 = "nodes.kubernetes-dock.runnable-gamma.com"
  launch_configuration = "${aws_launch_configuration.nodes-kubernetes-dock-runnable-gamma-com.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${aws_subnet.us-west-2a-kubernetes-dock-runnable-gamma-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "kubernetes-dock.runnable-gamma.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.kubernetes-dock.runnable-gamma.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "a-etcd-events-kubernetes-dock-runnable-gamma-com" {
  availability_zone = "us-west-2a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "kubernetes-dock.runnable-gamma.com"
    Name                 = "a.etcd-events.kubernetes-dock.runnable-gamma.com"
    "k8s.io/etcd/events" = "a/a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "a-etcd-main-kubernetes-dock-runnable-gamma-com" {
  availability_zone = "us-west-2a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "kubernetes-dock.runnable-gamma.com"
    Name                 = "a.etcd-main.kubernetes-dock.runnable-gamma.com"
    "k8s.io/etcd/main"   = "a/a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_iam_instance_profile" "masters-kubernetes-dock-runnable-gamma-com" {
  name  = "masters.kubernetes-dock.runnable-gamma.com"
  roles = ["${aws_iam_role.masters-kubernetes-dock-runnable-gamma-com.name}"]
}

resource "aws_iam_instance_profile" "nodes-kubernetes-dock-runnable-gamma-com" {
  name  = "nodes.kubernetes-dock.runnable-gamma.com"
  roles = ["${aws_iam_role.nodes-kubernetes-dock-runnable-gamma-com.name}"]
}

resource "aws_iam_role" "masters-kubernetes-dock-runnable-gamma-com" {
  name               = "masters.kubernetes-dock.runnable-gamma.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.kubernetes-dock.runnable-gamma.com_policy")}"
}

resource "aws_iam_role" "nodes-kubernetes-dock-runnable-gamma-com" {
  name               = "nodes.kubernetes-dock.runnable-gamma.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.kubernetes-dock.runnable-gamma.com_policy")}"
}

resource "aws_iam_role_policy" "masters-kubernetes-dock-runnable-gamma-com" {
  name   = "masters.kubernetes-dock.runnable-gamma.com"
  role   = "${aws_iam_role.masters-kubernetes-dock-runnable-gamma-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.kubernetes-dock.runnable-gamma.com_policy")}"
}

resource "aws_iam_role_policy" "nodes-kubernetes-dock-runnable-gamma-com" {
  name   = "nodes.kubernetes-dock.runnable-gamma.com"
  role   = "${aws_iam_role.nodes-kubernetes-dock-runnable-gamma-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.kubernetes-dock.runnable-gamma.com_policy")}"
}

resource "aws_key_pair" "kubernetes-kubernetes-dock-runnable-gamma-com-4bca284b36f7e9c6fa81617b4808935f" {
  key_name   = "kubernetes.kubernetes-dock.runnable-gamma.com-4b:ca:28:4b:36:f7:e9:c6:fa:81:61:7b:48:08:93:5f"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.kubernetes-dock.runnable-gamma.com-4bca284b36f7e9c6fa81617b4808935f_public_key")}"
}

resource "aws_launch_configuration" "master-us-west-2a-masters-kubernetes-dock-runnable-gamma-com" {
  name_prefix                 = "master-us-west-2a.masters.kubernetes-dock.runnable-gamma.com-"
  image_id                    = "ami-aaf84aca"
  instance_type               = "m4.large"
  key_name                    = "${aws_key_pair.kubernetes-kubernetes-dock-runnable-gamma-com-4bca284b36f7e9c6fa81617b4808935f.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-kubernetes-dock-runnable-gamma-com.id}"
  security_groups             = ["${aws_security_group.masters-kubernetes-dock-runnable-gamma-com.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-west-2a.masters.kubernetes-dock.runnable-gamma.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 100
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "nodes-kubernetes-dock-runnable-gamma-com" {
  name_prefix                 = "nodes.kubernetes-dock.runnable-gamma.com-"
  image_id                    = "ami-aaf84aca"
  instance_type               = "m4.large"
  key_name                    = "${aws_key_pair.kubernetes-kubernetes-dock-runnable-gamma-com-4bca284b36f7e9c6fa81617b4808935f.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-kubernetes-dock-runnable-gamma-com.id}"
  security_groups             = ["${aws_security_group.nodes-kubernetes-dock-runnable-gamma-com.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.kubernetes-dock.runnable-gamma.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.kubernetes-dock-runnable-gamma-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "igw-75950610"
}

resource "aws_route_table" "kubernetes-dock-runnable-gamma-com" {
  vpc_id = "vpc-c53464a0"

  tags = {
    KubernetesCluster = "kubernetes-dock.runnable-gamma.com"
    Name              = "kubernetes-dock.runnable-gamma.com"
  }
}

resource "aws_route_table_association" "us-west-2a-kubernetes-dock-runnable-gamma-com" {
  subnet_id      = "${aws_subnet.us-west-2a-kubernetes-dock-runnable-gamma-com.id}"
  route_table_id = "${aws_route_table.kubernetes-dock-runnable-gamma-com.id}"
}

resource "aws_security_group" "masters-kubernetes-dock-runnable-gamma-com" {
  name        = "masters.kubernetes-dock.runnable-gamma.com"
  vpc_id      = "vpc-c53464a0"
  description = "Security group for masters"

  tags = {
    KubernetesCluster = "kubernetes-dock.runnable-gamma.com"
    Name              = "masters.kubernetes-dock.runnable-gamma.com"
  }
}

resource "aws_security_group" "nodes-kubernetes-dock-runnable-gamma-com" {
  name        = "nodes.kubernetes-dock.runnable-gamma.com"
  vpc_id      = "vpc-c53464a0"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster = "kubernetes-dock.runnable-gamma.com"
    Name              = "nodes.kubernetes-dock.runnable-gamma.com"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-dock-runnable-gamma-com.id}"
  source_security_group_id = "${aws_security_group.masters-kubernetes-dock-runnable-gamma-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-kubernetes-dock-runnable-gamma-com.id}"
  source_security_group_id = "${aws_security_group.masters-kubernetes-dock-runnable-gamma-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-kubernetes-dock-runnable-gamma-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-dock-runnable-gamma-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "https-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-kubernetes-dock-runnable-gamma-com.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-kubernetes-dock-runnable-gamma-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-kubernetes-dock-runnable-gamma-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-dock-runnable-gamma-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-dock-runnable-gamma-com.id}"
  from_port                = 1
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-dock-runnable-gamma-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-dock-runnable-gamma-com.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-dock-runnable-gamma-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-dock-runnable-gamma-com.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-kubernetes-dock-runnable-gamma-com.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-kubernetes-dock-runnable-gamma-com.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "us-west-2a-kubernetes-dock-runnable-gamma-com" {
  vpc_id            = "vpc-c53464a0"
  cidr_block        = "10.4.64.0/19"
  availability_zone = "us-west-2a"

  tags = {
    KubernetesCluster                                          = "kubernetes-dock.runnable-gamma.com"
    Name                                                       = "us-west-2a.kubernetes-dock.runnable-gamma.com"
    "kubernetes.io/cluster/kubernetes-dock.runnable-gamma.com" = "owned"
  }
}
