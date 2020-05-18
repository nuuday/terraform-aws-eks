locals {
  # Latest as of time of writing.
  # Found on: https://github.com/aws/eks-charts/tree/master/stable/aws-node-termination-handler
  aws_node_termination_handler_version = "0.7.5"
}

resource "helm_release" "node_termination_handler" {
  count = var.node_termination_handler_enable ? 1 : 0

  name       = "aws-node-termination-handler"
  chart      = "aws-node-termination-handler"
  version    = local.aws_node_termination_handler_version
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"

  # Ensure the pods only run on Linux nodes,
  # in case we have Windows nodes in our cluster too.
  set {
    name  = "nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }
}

