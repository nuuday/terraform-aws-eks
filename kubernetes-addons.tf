module "cluster-autoscaler" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/cluster-autoscaler?ref=v0.15.0"
  # source = "../terraform-aws-eks-addons//modules/cluster-autoscaler"
  enable                   = var.cluster_autoscaler_enable
  cluster_name             = var.cluster_name
  oidc_provider_arn        = module.eks.oidc_provider_arn
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
}

module "loki" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/loki?ref=v0.15.0"
  # source = "../terraform-aws-eks-addons/modules/loki"
  enable                   = var.loki_enable
  cluster_name             = var.cluster_name
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
  tags                     = var.tags
}

module "external-dns" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/external-dns?ref=v0.15.0"
  # source                   = "../terraform-aws-eks-addons/modules/external-dns"
  enable                   = var.external_dns_enable
  oidc_provider_issuer_url = module.eks.cluster_oidc_issuer_url
  route53_zones            = var.route53_zones
  tags                     = var.tags
}

module "cert-manager" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/cert-manager?ref=v0.15.0"
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

module "ingress_controller_nginx" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/nginx-ingress-controller?ref=v0.15.0"
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
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/metrics-server?ref=v0.15.0"
  # source = "../terraform-aws-eks-addons//modules/metrics-server"
  enable = var.metrics_server_enable
}

module "aws-node-termination-handler" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/aws-node-termination-handler?ref=v0.15.0"
  # source = "../terraform-aws-eks-addons//modules/aws-node-termination-handler"
  enable = var.aws_node_termination_handler_enable
}

locals {
  prometheus_username = "metrics"
}

module "prometheus" {
  source = "github.com/nuuday/terraform-aws-eks-addons//modules/prometheus-operator?ref=v0.17.1"
  # source           = "../terraform-aws-eks-addons//modules/prometheus-operator"
  slack_webhook    = var.slack_webhook
  ingress_enabled  = length(var.route53_zones) > 0 ? true : false
  ingress_hostname = "prometheus.${var.route53_zones[0]}"
  ingress_annotations = {
    "nginx.ingress.kubernetes.io/auth-type"   = "basic"
    "nginx.ingress.kubernetes.io/auth-secret" = "prometheus-basic-auth"
    "nginx.ingress.kubernetes.io/auth-realm"  = "Authentication Required"
    "cert-manager.io/cluster-issuer"          = "letsencrypt"
  }
  enabled        = var.prometheus_enable
  thanos_enabled = var.thanos_enabled
  thanos = {
    type = "s3"
    config = {
      bucket     = var.thanos.bucket
      endpoint   = "s3.${var.thanos.region}.amazonaws.com"
      access_key = var.thanos.access_key
      secret_key = var.thanos.secret_key
    }
  }
  helm_values = var.prometheus_helm_values
}

resource "random_password" "prometheus" {
  length  = 16
  special = false
}

resource "kubernetes_secret" "prometheus" {
  metadata {
    name      = "prometheus-basic-auth"
    namespace = "kube-system"
  }
  data = {
    auth = "${local.prometheus_username}:${bcrypt(random_password.prometheus.result)}"
  }
}
