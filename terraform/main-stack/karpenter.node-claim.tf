data "http" "node_claim_crd" {
  url = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v1.8.6/pkg/apis/crds/karpenter.sh_nodeclaims.yaml"
}

resource "kubernetes_manifest" "node_claim_crd" {
  count      = var.enable_karpenter ? 1 : 0
  manifest   = yamldecode(data.http.node_claim_crd.response_body)
  depends_on = [aws_eks_node_group.this]
}

resource "time_sleep" "wait_for_node_claim_crd" {
  count           = var.enable_karpenter ? 1 : 0
  create_duration = "45s"
  depends_on      = [kubernetes_manifest.node_claim_crd[0]]
}