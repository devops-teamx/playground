variable "eks_cluster_name" {
  description = "cluster name"
}

variable "eks_certificate_authority" {
  description = "eks certificate authority"
}

variable "eks_endpoint" {
  description = "eks cluster endpoint"
}

variable "iam_instance_profile" {
  description = "eks instance profile name"
}

variable "security_group_node" {
  description = "eks security group name"
}

variable "subnets" {
  type = "list"
}

variable "instance_type" {
  type = "map"
}

variable "max_size" {
  type = "map"
}

variable "min_size" {
  type = "map"
}

variable "desired_capacity" {
  type = "map"
}
