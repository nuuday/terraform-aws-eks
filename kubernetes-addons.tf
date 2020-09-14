module "cluster-autoscaler" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/cluster-autoscaler?ref=v0.9.9"

  enable                   = var.cluster_autoscaler_enable
  cluster_name             = var.cluster_name
  oidc_provider_arn        = module.eks.oidc_provider_arn
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
}

module "cilium" {
  source       = "github.com/nuuday/terraform-aws-eks-addons//modules/cilium?ref=0.5.0"
  cluster_name = var.cluster_name
  enable       = var.cilium_enable
}

module "loki" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/loki?ref=v0.9.5"
  # source = "../terraform-aws-eks-addons/modules/loki"
  enable                   = var.loki_enable
  cluster_name             = var.cluster_name
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
  tags                     = var.tags
}

module "prometheus" {
  # source = "../terraform-aws-eks-addons/modules/prometheus"
  source              = "github.com/nuuday/terraform-aws-eks-addons//modules/prometheus?ref=0.5.0"
  enable              = var.prometheus_enable
  alertmanager_alerts = var.ingress_controller_ingress_enable ? module.ingress_controller_nginx.prometheus_alert_manager_rules : []
}

module "external-dns" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/external-dns?ref=v0.9.9"
  # source                   = "../terraform-aws-eks-addons/modules/external-dns"
  enable                   = var.external_dns_enable
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
  route53_zones            = var.route53_zones
  tags                     = var.tags
}

module "cert-manager" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/cert-manager?ref=v0.9.14"
  # source                   = "../terraform-aws-eks-addons/modules/cert-manager"
  enable                   = var.cert_manager_enable
  email                    = var.cert_manager_email
  ingress_class            = local.cert_manager_ingress_class
  kubectl_token            = data.aws_eks_cluster_auth.cluster.token
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
  route53_zones            = var.route53_zones
  tags                     = var.tags
  kubectl_server           = data.aws_eks_cluster.cluster.endpoint

}

module "kube-monkey" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/kube-monkey?ref=v0.9.9"
  enable = var.kube_monkey_enable
}

module "ingress_controller_nginx" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/nginx-ingress-controller?ref=v0.9.9"
  # source            = "../terraform-aws-eks-addons/modules/nginx-ingress-controller"
  enable            = var.ingress_controller_ingress_enable && var.ingress_controller_ingress_flavour == "nginx"
  loadbalancer_fqdn = module.lb.this_lb_dns_name
  controller_service_node_ports = [
    for listener in local.loadbalancer_listeners :
    {
      name     = listener.name
      port     = listener.port
      nodePort = listener.nodePort
      protocol = listener.protocol
    }
    if listener.ingress
  ]
}

module "metrics-server" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/metrics-server?ref=v0.9.9"
  enable = var.metrics_server_enable
}

module "aws-node-termination-handler" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/aws-node-termination-handler?ref=v0.9.9"
  enable = var.aws_node_termination_handler_enable
}
