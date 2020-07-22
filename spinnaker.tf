locals {
  spinnaker_namespaces               = [for i, z in var.namespaces : z if z.spinnaker_enabled]
  spinnaker_serviceaccount_name      = "spinnaker"
  spinnaker_serviceaccount_namespace = "kube-system"
  spinnaker_kubeconfig_name          = split("/", replace(module.eks.cluster_endpoint, "https://", ""))[0]
  spinnaker_context_name             = var.spinnaker_context_prefix != "" ? "${var.spinnaker_context_prefix}${var.cluster_name}" : module.eks.cluster_arn
  spinnaker_kubeconfig = length(local.spinnaker_namespaces) > 0 ? templatefile("${path.module}/files/spinnaker_kubeconfig.tpl", {
    context_name        = local.spinnaker_context_name
    cluster_arn         = module.eks.cluster_arn
    endpoint            = module.eks.cluster_endpoint
    cluster_auth_base64 = module.eks.cluster_certificate_authority_data
    token               = data.kubernetes_secret.spinnaker[0].data.token
  }) : ""
}

resource "kubernetes_service_account" "spinnaker" {
  count = length(local.spinnaker_namespaces) > 0 ? 1 : 0
  metadata {
    name      = local.spinnaker_serviceaccount_name
    namespace = local.spinnaker_serviceaccount_namespace
  }
}

data "kubernetes_secret" "spinnaker" {
  count = length(local.spinnaker_namespaces) > 0 ? 1 : 0

  metadata {
    name      = kubernetes_service_account.spinnaker[0].default_secret_name
    namespace = kubernetes_service_account.spinnaker[0].metadata[0].namespace
  }
}

resource "kubernetes_role" "spinnaker" {
  depends_on = [kubernetes_namespace.namespaces]
  count      = length(local.spinnaker_namespaces)
  metadata {
    namespace = local.spinnaker_namespaces[count.index].name
    name      = "spinnaker"
  }
  rule {
    api_groups = [""]
    verbs      = ["get", "list"]
    resources  = ["namespaces", "configmaps", "events", "replicationcontrollers", "serviceaccounts", "pods/log"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "secrets", "configmaps", "serviceaccounts"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["controllerrevisions", "statefulsets"]
    verbs      = ["list"]
  }
  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments", "replicasets", "ingresses", "statefulsets"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["services/proxy", "pods/portforward"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }
}

resource "kubernetes_role_binding" "spinnaker" {
  depends_on = [kubernetes_namespace.namespaces]
  count      = length(local.spinnaker_namespaces)
  metadata {
    namespace = local.spinnaker_namespaces[count.index].name
    name      = "spinnaker"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "spinnaker"
  }
  subject {
    namespace = local.spinnaker_serviceaccount_namespace
    kind      = "ServiceAccount"
    name      = local.spinnaker_serviceaccount_name
  }
}
