variable "access_key" {
  description = "AWS ACCEE_KEY"
}

variable "secret_key" {
  description = "AWS SECRETE_KEY"
}

variable "aws_region" {
  description = "AWS region to launch servers."
}

variable "domain_name" {
  description = "domain name for amazon provided dns in VPC"
  type = "map"
  default = {
    us-west-2 = "us-west-2.compute.internal"
    us-east-1  = "ec2.internal"
    eu-west-1 = "eu-west-1.compute.internal"
  }
}


variable "cidr_block" {
  description = "CIDR for the whole VPC"

  default = {
    prod = "10.10.0.0/16"
    dev  = "10.20.0.0/16"
    preprod = "10.30.0.0/16"
  }
}

variable "eks_cluster_name" {
  description = "cluster name"
  default     = "terra"
}

variable "instance_type" {
  description = "Instance type for the eks worker nodes"

  default = {
    prod = "m4.large"
    dev  = "t2.medium"
    preprod = "m3.medium"
  }
}

variable "max_size" {
  description = "Instance type for the eks worker nodes"

  default = {
    prod = "3"
    dev  = "1"
    preprod = "2"
  }
}

variable "desired_capacity" {
  description = "Instance type for the eks worker nodes"

  default = {
    prod = "3"
    dev  = "1"
    preprod = "2"
  }
}

variable "min_size" {
  description = "Instance type for the eks worker nodes"

  default = {
    prod = "1"
    dev  = "1"
    preprod = "1"
  }
}
