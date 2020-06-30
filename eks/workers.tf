resource "aws_autoscaling_group" "eks_cluster_asg" {
  count                     = 1
  name                      = var.asg_name
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  desired_capacity          = var.asg_desired_capacity
  force_delete              = var.force_delete
  vpc_zone_identifier       = element([var.private_subnet_id],count.index)
  launch_template {
    id      = aws_launch_template.worker_launch_template.id
  }
  depends_on = [
    aws_eks_cluster.main_eks
  ]
  tag {
    key   = "Name"
    value = "${var.tags}-eks_asg"
    propagate_at_launch = true
  }

  tag {
    key   = "kubernetes.io/cluster/${var.cluster_name}"
    value = "owned"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "worker_launch_template" {
  image_id             = var.image_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  user_data            = base64encode(local.eks_node_userdata)
  ebs_optimized        = var.ebs_optimized

  monitoring {
    enabled = var.enable_monitoring
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = var.delete_on_termination
    security_groups             = [var.worker_security_group_id]
  }

  #block_device_mappings {
    #device_name = var.device_name
    #ebs {
      #delete_on_termination = lookup(block_device_mappings.value, "root_delete_on_termination", null)
      #encrypted             = lookup(block_device_mappings.value, "root_encrypted", null)
      #iops                  = lookup(block_device_mappings.value, "root_iops", null)
      #kms_key_id            = lookup(block_device_mappings.value, "root_kms_key_id", null)
      #volume_size           = lookup(block_device_mappings.value, "root_volume_size", null)
      #volume_type           = lookup(block_device_mappings.value, "root_volume_type", null)
    #}
  #}

  tag_specifications {
    resource_type = "instance"

    tags = map(
      "Name", "${var.tags}-eks_worker_instance",
      "kubernetes.io/cluster/${var.cluster_name}", "owned"
    )
  }
}

resource "aws_iam_instance_profile" "node_profile" {
  name = "node_profile"
  role = aws_iam_role.node_group_role.name
}

resource "aws_security_group" "workers_sg" {
  name        = "workers_sg"
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id
  tags = map(
    "Name", "${var.tags}-workers_sg",
    "kubernetes.io/cluster/${var.cluster_name}", "owned"
  )
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.workers_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = aws_security_group.workers_sg.id
  source_security_group_id = aws_security_group.workers_sg.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers_sg.id
  source_security_group_id = var.cluster_security_group_id
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  description              = "Allow workers Kubelets to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers_sg.id
  source_security_group_id = var.cluster_security_group_id
  from_port                = 10250
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers_sg.id
  source_security_group_id = var.cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_iam_role" "node_group_role" {
  name = "eks-node-group-role"
  assume_role_policy = file("${path.module}/json/node_group_role.json")
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}
