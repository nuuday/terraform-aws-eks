module "cilium" {
  # TODO: Add extra configuration variables
  # source = "../terraform-aws-eks-addons/modules/cilium"
  source       = "github.com/nuuday/terraform-aws-eks-addons//modules/cilium?ref=v0.2.1"
  cluster_name = var.cluster_name
  enable       = var.cilium_enable

  depends_on = [module.eks]
}

module "loki" {
  # TODO: Add extra configuration variables
  source                   = "github.com/nuuday/terraform-aws-eks-addons//modules/loki?ref=loki-s3-dynamodb-storage"
  enable                   = var.loki_enable
  cluster_name             = var.cluster_name
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
  tags                     = var.tags

  depends_on = [module.eks]
}

module "prometheus" {
  # TODO: Add extra configuration variables
  # source = "../terraform-aws-eks-addons/modules/prometheus"
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/prometheus?ref=v0.2.1"
  enable = var.prometheus_enable

  depends_on = [module.eks]
}

module "cluster-autoscaler" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/cluster-autoscaler?ref=v0.2.1"

  enable                   = var.cluster_autoscaler_enable
  cluster_name             = var.cluster_name
  oidc_provider_arn        = module.eks.oidc_provider_arn
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url

  depends_on = [module.eks]
}

# module "external-dns" {
# TODO: ADD WHEN READY
# source = "github.com/nuuday/terraform-aws-eks-addons//modules/kube-monkey?ref=adding-new-modules"
#   source  = "../terraform-aws-eks-addons/modules/kube-monkey"
#   enable = var.kube_monkey_enable
# }

# module "cert-manager" {
# TODO: ADD WHEN READY
# source = "github.com/nuuday/terraform-aws-eks-addons//modules/kube-monkey?ref=adding-new-modules"
#   source  = "../terraform-aws-eks-addons/modules/kube-monkey"
#   enable = var.kube_monkey_enable
# }


module "kube-monkey" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/kube-monkey?ref=v0.2.1"
  # source = "../terraform-aws-eks-addons/modules/kube-monkey"
  enable = var.kube_monkey_enable

  depends_on = [module.eks]
}

module "metrics-server" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/metrics-server?ref=v0.2.1"
  # source = "../terraform-aws-eks-addons/modules/metrics-server"
  enable = var.metrics_server_enable

  depends_on = [module.eks]
}

module "aws-node-termination-handler" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/aws-node-termination-handler?ref=v0.2.1"
  # source = "../terraform-aws-eks-addons/modules/aws-node-termination-handler"
  enable = var.aws_node_termination_handler_enable

  depends_on = [module.eks]

}

