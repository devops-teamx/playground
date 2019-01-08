data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }
  most_recent = true
}

data "aws_region" "current" {}


locals {
  demo-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_endpoint}' --b64-cluster-ca '${var.eks_certificate_authority}' '${var.eks_cluster_name}}'
USERDATA
}

resource "aws_launch_configuration" "terra" {
  associate_public_ip_address = true
  iam_instance_profile        = "${var.iam_instance_profile}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type = "${var.instance_type[terraform.workspace]}"
  name_prefix                 = "terraform-${terraform.workspace}-eks"
  key_name                    = "test_access"
  security_groups             = ["${var.security_group_node}"]
  user_data_base64            = "${base64encode(local.demo-node-userdata)}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "terra" {
  desired_capacity     = "${var.desired_capacity[terraform.workspace]}"
  launch_configuration = "${aws_launch_configuration.terra.id}"
  max_size             = "${var.max_size[terraform.workspace]}"
  min_size             = "${var.min_size[terraform.workspace]}"
  name                 = "terraform-${terraform.workspace}-eks"
  vpc_zone_identifier  = ["${var.subnets}"]

  tag {
    key                 = "Name"
    value               = "terraform-${terraform.workspace}-eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster_name}-${terraform.workspace}"
    value               = "owned"
    propagate_at_launch = true
  }
}
