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
  tags = merge(local.default_tags, var.tags)
  }

data "aws_caller_identity" "iam" {}
data "aws_region" "current" {}