output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main_eks[0].endpoint
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.main_eks[0].certificate_authority
}

output "eks_cluster_name" {
  description = "Kubernetes Cluster Name"
  value = aws_eks_cluster.main_eks[0].name
}

output "cluster_id" {
  description = "Kubernetes Cluster ID"
  value = aws_eks_cluster.main_eks[0].id
}

output "cluster_sg_id" {
  value = aws_security_group.cluster_sg.id
}

output "workers_sg_id" {
  value = aws_security_group.workers_sg.id
}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "kubeconfig" {
  value = local.kubeconfig
}
