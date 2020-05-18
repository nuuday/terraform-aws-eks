locals {
  # Latest as of time of writing.
  # Found using 'helm search repo nginx-ingress'
  nginx_ingress_chart_version = "1.36.2" # maps to AppVersion 0.30.0
}

resource "kubernetes_namespace" "nginx_ingress" {
  count = var.ingress_enable ? 1 : 0

  metadata {
    name = "nginx-ingress"
  }
}

resource "helm_release" "nginx_ingress" {
  count = var.ingress_enable ? 1 : 0

  name       = "nginx-ingress"
  chart      = "nginx-ingress"
  version    = local.nginx_ingress_chart_version
  repository = "https://kubernetes-charts.storage.googleapis.com"
  namespace  = kubernetes_namespace.nginx_ingress.0.metadata.0.name

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name  = "controller.service.nodePorts.http"
    value = local.ingress_controller_node_ports.http
  }

  set {
    name  = "controller.service.nodePorts.https"
    value = local.ingress_controller_node_ports.https
  }

  # Preserve the source IP for incoming requests
  # https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-typenodeport
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.extraArgs.publish-status-address"
    value = module.lb.this_lb_dns_name
  }

  # Ensure pods are scheduled on Linux nodes only
  set {
    name  = "controller.nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }

  set {
    name  = "defaultBackend.nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }

  depends_on = [
    module.eks,
    module.lb,
  ]
}

