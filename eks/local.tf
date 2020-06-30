locals {
  eks_node_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.main_eks[0].endpoint}' --b64-cluster-ca '${aws_eks_cluster.main_eks[0].certificate_authority.0.data}' '${var.cluster_name}'
USERDATA
}
