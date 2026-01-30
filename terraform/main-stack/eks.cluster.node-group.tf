resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.eks_node_group.name
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = aws_subnet.private[*].id
  capacity_type   = var.eks_node_group.capacity_type
  instance_types  = var.eks_node_group.instance_types

  scaling_config {
    desired_size = var.eks_node_group.scaling_config.desired_size
    max_size     = var.eks_node_group.scaling_config.max_size
    min_size     = var.eks_node_group.scaling_config.min_size
  }

  launch_template {
    id      = aws_launch_template.eks_node_group.id
    version = aws_launch_template.eks_node_group.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_launch_template" "eks_node_group" {
  name_prefix = "${var.eks_node_group.name}-lt-"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.eks_node_group.name}-instance"
    }
  }
}