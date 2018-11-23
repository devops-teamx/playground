terraform {
  backend "s3" {
    bucket = "terra-remote-state-bucket"
    key    = "tfstate"
    region = "us-west-2"
  }
}
