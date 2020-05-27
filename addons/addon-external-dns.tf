locals {
  # Latest as of time of writing.
  # Found on: https://github.com/kubernetes-sigs/external-dns
  external_dns_chart_version = "2.21.0"
}

resource "aws_iam_role" "external_dns" {
  count = var.external_dns_enable ? 1 : 0

  name_prefix = "${module.eks.cluster_id}-ext-dns"

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
          "${local.oidc_issuer}:sub": "system:serviceaccount:${kubernetes_namespace.external_dns.0.metadata.0.name}:external-dns"
        }
      }
    }
  ]
}
EOF

  tags = local.combined_tags
}

resource "aws_iam_role_policy" "external_dns" {
  count = var.external_dns_enable ? 1 : 0

  name = "ExternalDns"
  role = aws_iam_role.external_dns.0.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/${data.aws_route53_zone.this.zone_id}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "kubernetes_namespace" "external_dns" {
  count = var.external_dns_enable ? 1 : 0

  metadata {
    name = "external-dns"
  }
}

resource "helm_release" "external_dns" {
  count = var.external_dns_enable ? 1 : 0

  name       = "external-dns"
  chart      = "external-dns"
  version    = local.external_dns_chart_version
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = kubernetes_namespace.external_dns.0.metadata.0.name

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "aws.region"
    value = data.aws_region.current.name
  }

  # Prevents "ALIAS" A records from being created.
  # They're specific to AWS and doesn't comply with the DNS RFC.
  set {
    name  = "aws.preferCNAME"
    value = "true"
  }

  # ExternalDNS creates TXT records with the same name as the CNAME
  # to keep track of which records ExternalDNS "owns".
  # TXT records need to be prefixed with something to avoid colissions.
  # This sets the prefix :-)
  set {
    name  = "txtPrefix"
    value = "foo"
  }

  # By default, both Ingress and Service objects are scanned to find out
  # which hostnames to create DNS records for.
  # This forces ExternalDNS to only scan Ingress objects.
  set {
    name  = "sources.0"
    value = "ingress"
    type  = "string"
  }

  set {
    name  = "extraArgs.domain-filter"
    value = var.dns_zone
  }

  # Expose Prometheus metrics.
  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set {
    name  = "metrics.podAnnotations.prometheus\\.io/scrape"
    value = "true"
    type  = "string"
  }

  set {
    name  = "metrics.podAnnotations.prometheus\\.io/port"
    value = "7979"
    type  = "string"
  }

  # Make ExternalDNS's service account assume the given IAM Role.
  # This is achieved through "IAM Roles for Service Accounts" (IRSA).
  set {
    name  = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns.0.arn
    type  = "string"
  }

  # Ensure ExternalDNS pods only run on Linux nodes,
  # in case we have Windows nodes in our cluster too.
  set {
    name  = "nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }

  depends_on = [
    module.eks,
  ]
}

