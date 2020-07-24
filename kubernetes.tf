provider "kubernetes" {
  version = "~>1.11"

  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

resource "null_resource" "aws_iam_cluster_role_bindings" {
  provisioner "local-exec" {
    command = <<EOF
cat <<MOF | kubectl apply --token ${data.aws_eks_cluster_auth.cluster.token} -f -
${templatefile("${path.module}/files/cluster-role-bindings.yaml", { tags = jsonencode(local.tags) })}
MOF
EOF

    environment = {
      KUBECONFIG = "${module.eks.kubeconfig_filename}"
    }
  }
}


locals {
  spinnaker_serviceaccount_name      = "spinnaker"
  spinnaker_serviceaccount_namespace = "kube-system"
  spinnaker_kubeconfig_name          = split("/", replace(module.eks.cluster_endpoint, "https://", ""))[0]
  spinnaker_context_name             = var.spinnaker_context_prefix != "" ? "${var.spinnaker_context_prefix}${var.cluster_name}" : module.eks.cluster_arn
  spinnaker_kubeconfig = var.spinnaker_enabled ? templatefile("${path.module}/files/spinnaker_kubeconfig.tpl", {
    context_name        = local.spinnaker_context_name
    cluster_arn         = module.eks.cluster_arn
    endpoint            = module.eks.cluster_endpoint
    cluster_auth_base64 = module.eks.cluster_certificate_authority_data
    token               = data.kubernetes_secret.spinnaker[0].data.token
  }) : ""
}

resource "kubernetes_service_account" "spinnaker" {
  count = var.spinnaker_enabled ? 1 : 0
  metadata {
    name      = local.spinnaker_serviceaccount_name
    namespace = local.spinnaker_serviceaccount_namespace
  }
}

data "kubernetes_secret" "spinnaker" {
  count = var.spinnaker_enabled ? 1 : 0

  metadata {
    name      = kubernetes_service_account.spinnaker[0].default_secret_name
    namespace = kubernetes_service_account.spinnaker[0].metadata[0].namespace
  }
}