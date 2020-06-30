##############
### Cluster ##
##############
variable "cluster_name" {
  type    = string
}
variable "private_subnet_id" {
  type     = list(string)
  default = []
}
variable "cluster_security_group_id" {
  description = "Security group of the eks cluster"
  type        = string
  default     = ""
}
variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = false
}
variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}
variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks. Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
  default     = ""
}
###########
### ASG ###
###########
variable "asg_name" {
  type = string
}
variable "asg_max_size" {
  type = number
}
variable "asg_min_size" {
  type = number
}
variable "health_check_grace_period" {
  type = number
}
variable "health_check_type" {
  type = string
}
variable "asg_desired_capacity" {
  type = number
}
variable "force_delete" {
  type = bool
}

#######################
### Launch Template ###
#######################
variable "image_id" {
  description = "ID of AMI to use for the instance"
  type        = string
}
variable "instance_type" {
  description = "The type of instance to start"
  type        = string
}
variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
  default     = ""
}
variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  type        = string
  default     = null
}
variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = false
}
variable "enable_monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}
variable "iam_instance_profile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  type        = string
  default     = ""
}
variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  type        = bool
  default     = null
}
variable "delete_on_termination" {
  description = "Whether the ENI should be destroyed on instance termination"
  type        = bool
  default     = null
}
variable "device_name" {
  description = "Name of the root block device"
  type        = string
  default     = ""
}
#variable "block_device_mappings" {
  #description = "Values for the EBS block device being attached to the instance"
  #type        = list(map(string))
  #default     = []
#}
variable "worker_security_group_id" {
  description = "Security group of the worker nodes "
  type        = string
}
variable "tags" {
  description = "Tags to assign to the resource"
  type        = string
  default     = ""
}
