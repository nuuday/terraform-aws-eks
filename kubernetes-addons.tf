module "cluster-autoscaler" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/cluster-autoscaler?ref=v0.2.2"

  enable                   = var.cluster_autoscaler_enable
  cluster_name             = var.cluster_name
  oidc_provider_arn        = module.eks.oidc_provider_arn
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
}

module "cilium" {
  source       = "github.com/nuuday/terraform-aws-eks-addons//modules/cilium?ref=v0.2.2"
  cluster_name = var.cluster_name
  enable       = var.cilium_enable
}

module "loki" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/loki"
  # source = "../terraform-aws-eks-addons/modules/loki"
  enable                   = var.loki_enable
  cluster_name             = var.cluster_name
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
  tags                     = var.tags
}

module "prometheus" {
  # source = "../terraform-aws-eks-addons/modules/prometheus"
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/prometheus?ref=v0.2.2"
  enable = var.prometheus_enable
}



# module "external-dns" {
# TODO: ADD WHEN READY
# source = "github.com/nuuday/terraform-aws-eks-addons//modules/kube-monkey?ref=adding-new-modules"
#   source  = "../terraform-aws-eks-addons/modules/kube-monkey"
#   enable = var.kube_monkey_enable && kubernetes_cluster_role_binding.administrators_admin.id != ""
# }

# module "cert-manager" {
# TODO: ADD WHEN READY
# source = "github.com/nuuday/terraform-aws-eks-addons//modules/kube-monkey?ref=adding-new-modules"
#   source  = "../terraform-aws-eks-addons/modules/kube-monkey"
#   enable = var.kube_monkey_enable && kubernetes_cluster_role_binding.administrators_admin.id != ""
# }


module "kube-monkey" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/kube-monkey?ref=v0.2.2"
  enable = var.kube_monkey_enable
}

module "metrics-server" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/metrics-server?ref=v0.2.2"
  enable = var.metrics_server_enable

}

module "aws-node-termination-handler" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/aws-node-termination-handler?ref=v0.2.2"
  enable = var.aws_node_termination_handler_enable
}
