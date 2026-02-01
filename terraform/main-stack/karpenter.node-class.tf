data "http" "node_class_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v1.8.6/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml"
}

resource "kubernetes_manifest" "node_class_crd" {
  count      = var.enable_karpenter ? 1 : 0
  manifest   = yamldecode(data.http.node_class_crd.response_body)
  depends_on = [aws_eks_node_group.this]
}

resource "time_sleep" "wait_for_node_class_crd" {
  count           = var.enable_karpenter ? 1 : 0
  create_duration = "45s"
  depends_on      = [kubernetes_manifest.node_class_crd[0]]
}

resource "local_file" "node_class_manifest" {
  count    = var.enable_karpenter ? 1 : 0
  filename = "${path.module}/.generated/karpenter.node-class.yml"
  content = templatefile("${path.module}/manifests/karpenter.node-class.yml", {
    node_group_role_name = aws_iam_role.eks_node_group.name
    cluster_name         = aws_eks_cluster.this.name
  })
  depends_on = [time_sleep.wait_for_node_class_crd[0]]
}

resource "null_resource" "apply_node_class" {
  count      = var.enable_karpenter ? 1 : 0
  depends_on = [local_file.node_class_manifest[0]]

  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.node_class_manifest[0].filename}"
  }
}