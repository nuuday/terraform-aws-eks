module "lb" {
  source = "github.com/terraform-aws-modules/terraform-aws-alb?ref=v5.2.0"

  create_lb = var.loadbalancer_enabled

  name                             = var.cluster_name
  load_balancer_type               = "network"
  vpc_id                           = var.vpc_id
  subnets                          = var.loadbalancer_subnets
  enable_cross_zone_load_balancing = true

  http_tcp_listeners = [
    for listener in local.loadbalancer_listeners :
    {
      port               = listener.port
      protocol           = "TCP"
      target_group_index = index(local.loadbalancer_listeners, listener)
    }
  ]

  target_groups = [
    for listener in local.loadbalancer_listeners :
    {
      backend_port     = listener.nodePort
      backend_protocol = "TCP"
      target_type      = "instance"
    }
  ]
  tags = var.tags
}

resource "aws_security_group" "worker_http_ingress" {
  count = var.loadbalancer_enabled ? 1 : 0

  name_prefix = "${var.cluster_name}-ingress"
  description = "Allows access from anywhere to the ingress NodePorts"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.loadbalancer_listeners
    content {
      to_port     = ingress.value.nodePort
      from_port   = ingress.value.nodePort
      cidr_blocks = ingress.value.cidr
      protocol    = "tcp"
      description = ingress.value.name
    }
  }
}