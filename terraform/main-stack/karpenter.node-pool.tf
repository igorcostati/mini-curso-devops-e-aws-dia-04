data "http" "node_pool_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v1.8.6/pkg/apis/crds/karpenter.sh_nodepools.yaml"
}

resource "kubernetes_manifest" "node_pool_crd" {
  count      = var.enable_karpenter ? 1 : 0
  manifest   = yamldecode(data.http.node_pool_crd.response_body)
  depends_on = [aws_eks_node_group.this]
}

resource "time_sleep" "wait_for_node_pool_crd" {
  count           = var.enable_karpenter ? 1 : 0
  create_duration = "45s"
  depends_on      = [kubernetes_manifest.node_pool_crd[0]]
}

resource "local_file" "node_pool_manifest" {
  count      = var.enable_karpenter ? 1 : 0
  filename   = "${path.module}/.generated/karpenter.node-pool.yml"
  content    = file("${path.module}/manifests/karpenter.node-pool.yml")
  depends_on = [time_sleep.wait_for_node_pool_crd[0]]
}

resource "null_resource" "apply_node_pool" {
  count      = var.enable_karpenter ? 1 : 0
  depends_on = [local_file.node_pool_manifest[0]]

  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.node_pool_manifest[0].filename}"
  }
}