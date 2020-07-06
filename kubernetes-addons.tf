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

module "external-dns" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/external-dns?ref=external-dns-implementation"
  # source                   = "../terraform-aws-eks-addons/modules/external-dns"
  enable                   = var.external_dns_enable
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
  route53_zones            = var.route53_zones
  tags                     = var.tags
}

module "cert-manager" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/cert-manager?ref=cert-manager-impl-clean"

  # source                   = "../terraform-aws-eks-addons/modules/cert-manager"
  enable                   = var.cert_manager_enable
  email                    = var.cert_manager_email
  ingress_class            = local.cert_manager_ingress_class
  kubeconfig_filename      = module.eks.kubeconfig_filename
  kubectl_token            = data.aws_eks_cluster_auth.cluster.token
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
  route53_zones            = var.route53_zones
  tags                     = var.tags
}



module "kube-monkey" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/kube-monkey?ref=v0.2.2"
  enable = var.kube_monkey_enable
}

module "ingress_controller_nginx" {
  # source            = "github.com/nuuday/terraform-aws-eks-addons//modules/nginx-ingress-controller?ref=nginx-cleanup"
  source            = "../terraform-aws-eks-addons/modules/nginx-ingress-controller"
  enable            = var.ingress_controller_ingress_enable && var.ingress_controller_ingress_flavour == "nginx"
  loadbalancer_fqdn = module.lb.this_lb_dns_name
  controller_service_node_ports = [
    for listener in local.loadbalancer_listeners:
    {
      name = listener.name
      port = listener.port
      nodePort = listener.nodePort
      protocol = listener.protocol
    }
  ]
}

module "metrics-server" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/metrics-server?ref=v0.2.2"
  enable = var.metrics_server_enable
}

module "aws-node-termination-handler" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/aws-node-termination-handler?ref=v0.2.2"
  enable = var.aws_node_termination_handler_enable
}
