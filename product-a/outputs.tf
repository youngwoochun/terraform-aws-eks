output "kubeconfig" {
  value       = module.eks.kubeconfig
  description = "EKS Kubeconfig"
}

output "config-map" {
  value       = module.eks.config_map_aws_auth
  description = "K8S config map to authorize"
}
