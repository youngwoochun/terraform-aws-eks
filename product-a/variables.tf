variable "region" {
  type = string
}
variable "tags" {
  type = string
}

variable "cluster_name" {
  type = string
}
variable "cluster_endpoint_public_access" {
  type = bool
}
variable "cluster_endpoint_private_access" {
  type = bool
}
variable "cluster_endpoint_public_access_cidrs" {
  type = list(string)
}
variable "worker_group_defaults" {
  type = map(any)
}
