data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-product-a-dev"
    key    = "product-a/dev/us-east-1/terraform.tfstate"
    region = "us-east-1"
  }
}
