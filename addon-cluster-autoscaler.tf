locals {
  cluster_autoscaler = {
    asg_tags = var.cluster_autoscaler_enable ? {
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"             = "true"
    } : {}
  }
}

resource "aws_iam_role" "cluster_autoscaler" {
  count = var.cluster_autoscaler_enable ? 1 : 0

  name_prefix = "${var.cluster_name}-autoscaler"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${module.eks.oidc_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.oidc_issuer}:sub": "system:serviceaccount:${kubernetes_namespace.cluster_autoscaler.0.metadata.0.name}:aws-cluster-autoscaler"
        }
      }
    }
  ]
}
EOF

  tags = local.combined_tags
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid = "Read"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid = "Write"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    dynamic "condition" {
      for_each = local.cluster_autoscaler.asg_tags
      iterator = tag

      content {
        test     = "StringEqualsIgnoreCase"
        variable = "autoscaling:ResourceTag/${tag.key}"
        values   = [tag.value]
      }
    }
  }
}

resource "aws_iam_role_policy" "cluster_autoscaler" {
  count = var.cluster_autoscaler_enable ? 1 : 0

  name = "ClusterAutoscaler"
  role = aws_iam_role.cluster_autoscaler.0.id

  policy = data.aws_iam_policy_document.cluster_autoscaler.json
}

resource "kubernetes_namespace" "cluster_autoscaler" {
  count = var.cluster_autoscaler_enable ? 1 : 0

  metadata {
    name = "cluster-autoscaler"
  }
}

resource "helm_release" "cluster_autoscaler" {
  count = var.cluster_autoscaler_enable ? 1 : 0

  name       = "aws-cluster-autoscaler"
  chart      = "cluster-autoscaler"
  version    = "7.0.0"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  namespace  = kubernetes_namespace.cluster_autoscaler.0.metadata.0.name

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "rbac.create"
    value = true
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = true
  }

  set {
    name  = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.0.arn
    type  = "string"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "autoDiscovery.enabled"
    value = true
  }

  set {
    name  = "nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }
}
