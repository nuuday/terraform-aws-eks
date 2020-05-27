data "aws_caller_identity" "iam" { }






terraform {
  required_version = "~>0.12"

  required_providers {
    aws  = "~>2.60"
    http = "~>1.2"
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "helm" {
  version = "~>1.2"

  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "aws_route53_zone" "this" {
  name = var.dns_zone
}

locals {
  oidc_issuer = trimprefix(module.eks.cluster_oidc_issuer_url, "https://")

  aws_vpc_cni_version = "1.6"

  # nginx servers will listen on these ports on the worker nodes
  ingress_controller_node_ports = {
    http  = 32080
    https = 32443
  }

  module_tags = {
    module_repos = "https://github.com/nuuday/terraform-aws-eks"
  }

  combined_tags = merge(var.tags, local.module_tags)
}

module "lb" {
  source = "github.com/terraform-aws-modules/terraform-aws-alb?ref=v5.2.0"

  create_lb = var.ingress_enable

  name               = var.cluster_name
  load_balancer_type = "network"
  vpc_id             = data.aws_vpc.selected.id
  subnets            = var.lb_subnet_ids

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 1
    },
  ]

  target_groups = [
    {
      name_prefix      = "http"
      backend_protocol = "TCP"
      backend_port     = local.ingress_controller_node_ports.http
      target_type      = "instance"
    },
    {
      name_prefix      = "https"
      backend_protocol = "TCP"
      backend_port     = local.ingress_controller_node_ports.https
      target_type      = "instance"
    },
  ]

  tags = local.combined_tags
}

resource "aws_security_group" "worker_http_ingress" {
  name_prefix = "${var.cluster_name}-ingress-http-"
  description = "Allows HTTP access from anywhere to the ingress NodePorts"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "HTTP from NLB"
    from_port   = local.ingress_controller_node_ports.http
    to_port     = local.ingress_controller_node_ports.http
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "worker_https_ingress" {
  name_prefix = "${var.cluster_name}-ingress-https-"
  description = "Allows HTTPS access from anywhere to the ingress NodePorts"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "HTTPS from NLB"
    from_port   = local.ingress_controller_node_ports.https
    to_port     = local.ingress_controller_node_ports.https
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
/*

module "eks" {
  source = "github.com/terraform-aws-modules/terraform-aws-eks?ref=v12.0.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  enable_irsa = true
  vpc_id      = data.aws_vpc.selected.id
  subnets     = var.worker_subnet_ids

  worker_groups_launch_template = [
    {
      platform                = "linux"
      asg_max_size            = var.linux_workers_count
      asg_min_size            = var.linux_workers_count
      asg_desired_capacity    = var.linux_workers_count
      override_instance_types = ["t3.large"]
      spot_instance_pools     = 1

      target_group_arns = module.lb.target_group_arns

      additional_security_group_ids = [
        aws_security_group.worker_http_ingress.id,
        aws_security_group.worker_https_ingress.id,
      ]

      # These indicate that this ASG will participate in auto-scaling
      # through the cluster-autoscaler.
      tags = [for k, v in local.cluster_autoscaler.asg_tags : {
        key                 = k
        value               = v
        propagate_at_launch = false
      }]
    },

    {
      name                    = "windows-worker-group"
      platform                = "windows"
      asg_max_size            = var.windows_workers_count
      asg_min_size            = var.windows_workers_count
      asg_desired_capacity    = var.windows_workers_count
      override_instance_types = ["m5.large"]
      spot_instance_pools     = 1

      # These indicate that this ASG will participate in auto-scaling
      # through the cluster-autoscaler.
      tags = [for k, v in local.cluster_autoscaler.asg_tags : {
        key                 = k
        value               = v
        propagate_at_launch = false
      }]
    }
  ]

  tags = local.combined_tags
}
*/

data "http" "aws_vpc_cni" {
  url = "https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v${local.aws_vpc_cni_version}/aws-k8s-cni.yaml"
}

resource "null_resource" "aws_vpc_cni" {
  provisioner "local-exec" {
    command = <<EOF
cat <<MOF | kubectl apply -f -
${data.http.aws_vpc_cni.body}
MOF
EOF

    environment = {
      KUBECONFIG = "${module.eks.kubeconfig_filename}"
    }
  }
}

resource "null_resource" "windows_support" {
  count = var.windows_workers_count > 0 ? 1 : 0

  depends_on = [
    module.eks,
  ]

  provisioner "local-exec" {
    command = "sh ${path.module}/scripts/enable-windows-support.sh -w"
    environment = {
      KUBECONFIG         = "${module.eks.kubeconfig_filename}"
      AWS_DEFAULT_REGION = data.aws_region.current.name
    }
  }
}

