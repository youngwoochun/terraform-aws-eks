provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "main_eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "main_eks" {
  name = module.eks.cluster_id
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-product-a"
    key    = "dev/us-east-1/landing-zone"
    region = "us-east-1"
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.main_eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main_eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.main_eks.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks" {
  source                      = "../eks/"

  cluster_name                         = var.cluster_name
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  vpc_id                               = data.terraform_remote_state.network.outputs.vpc_id
  cluster_security_group_id            = module.eks.cluster_sg_id

  asg_name                             = var.worker_group_defaults["asg_name"]
  asg_max_size                         = var.worker_group_defaults["asg_max_size"]
  asg_min_size                         = var.worker_group_defaults["asg_min_size"]
  health_check_grace_period            = var.worker_group_defaults["health_check_grace_period"]
  health_check_type                    = var.worker_group_defaults["health_check_type"]
  asg_desired_capacity                 = var.worker_group_defaults["asg_desired_capacity"]
  force_delete                         = var.worker_group_defaults["force_delete"]
  private_subnet_id                    = ["subnet-04e45f0cb72f9feb7", "subnet-062cf50d11fd5a7f5"]

  image_id                             = var.worker_group_defaults["image_id"]
  instance_type                        = var.worker_group_defaults["instance_type"]
  key_name                             = var.worker_group_defaults["key_name"]
  user_data                            = var.worker_group_defaults["user_data"]
  ebs_optimized                        = var.worker_group_defaults["ebs_optimized"]
  enable_monitoring                    = var.worker_group_defaults["enable_monitoring"]
  iam_instance_profile                 = var.worker_group_defaults["iam_instance_profile"]
  associate_public_ip_address          = var.worker_group_defaults["associate_public_ip_address"]
  delete_on_termination                = var.worker_group_defaults["delete_on_termination"]
  worker_security_group_id             = module.eks.workers_sg_id
  tags                                 = var.tags
  #device_name                 = var.worker_group_defaults["device_name"]
  #block_device_mappings = [
    #{
  	  #delete_on_termination = var.worker_group_defaults["ebs_delete_on_termination"]
  		#encrypted             = var.worker_group_defaults["encrypted"]
  		#volume_size           = var.worker_group_defaults["volume_size"]
  	  #volume_type           = var.worker_group_defaults["volume_type"]
  	#}
  #]
}
