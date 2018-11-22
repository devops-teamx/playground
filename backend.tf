terraform {
  backend "s3" {
    bucket = "terra-state-eks-bucket"
    key    = "tfstate"
    region = "us-west-2"
  }
}
