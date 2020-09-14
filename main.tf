provider "helm" {
  version = "~>1.2"

  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}

terraform {
  required_version = "~>0.12"

  required_providers {
    aws  = "~>2.60"
    http = "~>1.2"
  }
}

locals {
  default_tags = {
    managed-by : "terraform"
    terraform-module : "terraform-aws-eks"
  }
  tags                             = merge(local.default_tags, var.tags)
  ingress_controller_ingress_class = var.ingress_controller_ingress_class != "" ? var.ingress_controller_ingress_class : var.ingress_controller_ingress_flavour
  cert_manager_ingress_class       = var.cert_manager_ingress_class != "" ? var.cert_manager_ingress_class : var.ingress_controller_ingress_class

  loabbalancer_listener_ingress_defaults = [
    { port = var.ingress_controller_http_port, cidr = var.ingress_controller_ingress_http_cidr, nodePort = var.ingress_controller_http_nodePort, name = "http", protocol = "tcp", ingress = true },
    { port = var.ingress_controller_https_port, cidr = var.ingress_controller_ingress_https_cidr, nodePort = var.ingress_controller_https_nodePort, name = "https", protocol = "tcp", ingress = true }
  ]
  loadbalancer_listeners = concat(var.ingress_controller_ingress_enable ? local.loabbalancer_listener_ingress_defaults : [], var.loadbalancer_listeners)

  http_tcp_listeners = [
    for listener in local.loadbalancer_listeners :
    {
      port               = listener.port
      protocol           = upper(listener.protocol)
      target_group_index = index(local.loadbalancer_listeners, listener)
    }
  ]
}

data "aws_caller_identity" "iam" {}
data "aws_region" "current" {}

output "loadbalancer_listeners" {
  value = local.http_tcp_listeners
}