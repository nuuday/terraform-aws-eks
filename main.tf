provider "aws" {
  region = "eu-north-1"
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


terraform {
  required_version = "~>0.12"

  required_providers {
    aws  = "~>2.60"
    http = "~>1.2"
  }
}

locals {
  default_tags = {
    managed-by: "terraform"
    terraform-module: "terraform-aws-eks"
  }
  tags = merge(local.default_tags, var.tags)
}

data "aws_caller_identity" "iam" {}
data "aws_region" "current" {}



/*


data "aws_vpc" "selected" {
  id = var.vpc_id
}



data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}


data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

locals {
  # oidc_issuer = trimprefix(module.eks.cluster_oidc_issuer_url, "https://")



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

*/
