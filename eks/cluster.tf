resource "aws_eks_cluster" "main_eks" {
  count    = 1
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    security_group_ids      = [aws_security_group.cluster_sg.id]
    subnet_ids              = element([var.private_subnet_id],count.index)
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
  ]
}

resource "aws_security_group" "cluster_sg" {
  name        = "cluster_sg"
  description = "EKS cluster security group."
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.cluster_name}-cluster_sg"
  }
}

resource "aws_security_group_rule" "cluster_ingress_from_bastion" {
  description       = "Allow traffic from bastion host"
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = var.worker_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_iam_role" "cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = file("${path.module}/json/cluster_role.json")
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_role.name
}
