module "cilium" {
  # TODO: Add extra configuration variables
  source = "../terraform-aws-eks-addons/modules/cilium"
  # source              = "github.com/nuuday/terraform-aws-eks-addons//modules/cilium?ref=adding-new-modules"
  cluster_name = var.cluster_name
  enable       = var.cilium_enable
}

module "loki" {
  # TODO: Add extra configuration variables
  source = "../terraform-aws-eks-addons/modules/loki"
  # source = "github.com/nuuday/terraform-aws-eks-addons//modules/loki?ref=adding-new-modules"
  enable = var.loki_enable
}

module "prometheus" {
  # TODO: Add extra configuration variables
  source = "../terraform-aws-eks-addons/modules/prometheus"
  # source = "github.com/nuuday/terraform-aws-eks-addons//modules/prometheus?ref=adding-new-modules"
  enable = var.prometheus_enable
}


# TODO: ADD WHEN FIXED
/*
module "cluster-autoscaler" {
  # source = "github.com/nuuday/terraform-aws-eks-addons//modules/kube-monkey?ref=adding-new-modules"
  source                   = "../terraform-aws-eks-addons/modules/cluster-autoscaler"
  enable                   = var.cluster_autoscaler_enable
  cluster_name             = var.cluster_name
  oidc_provider_arn        = module.eks.oidc_provider_arn
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
}
*/


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
  # source = "github.com/nuuday/terraform-aws-eks-addons//modules/kube-monkey?ref=adding-new-modules"
  source = "../terraform-aws-eks-addons/modules/kube-monkey"
  enable = var.kube_monkey_enable
}

module "metrics-server" {
  # source = "github.com/nuuday/terraform-aws-eks-addons//modules/metrics-server?ref=adding-new-modules"
  source = "../terraform-aws-eks-addons/modules/metrics-server"
  enable = var.metrics_server_enable
}

module "aws-node-termination-handler" {
  # source = "github.com/nuuday/terraform-aws-eks-addons//modules/aws-node-termination-handler?ref=adding-new-modules"
  source = "../terraform-aws-eks-addons/modules/aws-node-termination-handler"
  enable = var.aws_node_termination_handler_enable
}