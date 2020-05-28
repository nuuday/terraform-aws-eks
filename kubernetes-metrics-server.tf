locals {
  metrics_server_chart_name   = "metrics-server"
  metrics_server_release_name = "metrics-server"
  metrics_server_namespace    = "kube-system"
  metrics_server_repository   = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "metrics_server" {
  name       = local.metrics_server_release_name
  chart      = local.metrics_server_chart_name
  version    = var.metrics_server_version
  repository = local.metrics_server_repository
  namespace  = local.metrics_server_namespace
  wait       = false


  set {
    name  = "nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }
}
