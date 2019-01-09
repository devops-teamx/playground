data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-1.11-*"]
  }
  most_recent = true
}

data "aws_region" "current" {}


locals {
  node-userdata = <<USERDATA
#!/bin/bash -xe


CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
mkdir -p $CA_CERTIFICATE_DIRECTORY
echo "${var.eks_certificate_authority}" | base64 -d >  $CA_CERTIFICATE_FILE_PATH
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i s,MASTER_ENDPOINT,"${var.eks_endpoint}",g /var/lib/kubelet/kubeconfig
sed -i s,CLUSTER_NAME,"${var.eks_cluster_name}"-"${terraform.workspace}",g /var/lib/kubelet/kubeconfig
sed -i s,REGION,"${data.aws_region.current.name}",g /etc/systemd/system/kubelet.service
sed -i s,MAX_PODS,20,g /etc/systemd/system/kubelet.service
sed -i s,MASTER_ENDPOINT,"${var.eks_endpoint}",g /etc/systemd/system/kubelet.service
sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service
DNS_CLUSTER_IP=10.100.0.10
if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi
sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service
systemctl daemon-reload
systemctl restart kubelet
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
  user_data_base64            = "${base64encode(local.node-userdata)}"
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
