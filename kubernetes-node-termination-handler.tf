locals {
  aws_node_termination_handler_release_name = "aws-node-termination-handler"
  aws_node_termination_handler_chart_name = "aws-node-termination-handler"
  aws_node_termination_handler_namespace = "kube-system"
  aws_node_termination_handler_repository = "https://aws.github.io/eks-charts"
}

resource "helm_release" "node_termination_handler" {
  count = var.aws_node_termination_handler_enabled ? 1 : 0

  name       = local.aws_node_termination_handler_release_name
  chart      = local.aws_node_termination_handler_chart_name
  version    = var.aws_node_termination_handler_version
  repository = local.aws_node_termination_handler_repository
  namespace  = local.aws_node_termination_handler_namespace
  wait = false

  # Ensure the pods only run on Linux nodes,
  # in case we have Windows nodes in our cluster too.
  set {
    name  = "nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }
}

