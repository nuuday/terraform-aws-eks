locals {
  # Latest as of time of writing.
  # Found on: https://cert-manager.io/docs/installation/kubernetes/
  cert_manager_version = "0.14.1"

  cert_manager_service_account_name = "cert-manager"
}

resource "aws_iam_role" "cert_manager" {
  count = var.cert_manager_enable ? 1 : 0

  name_prefix = "${var.cluster_name}-cert-manager"

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
          "${local.oidc_issuer}:sub": "system:serviceaccount:${kubernetes_namespace.cert_manager.0.metadata.0.name}:${local.cert_manager_service_account_name}"
        }
      }
    }
  ]
}
EOF

  tags = local.combined_tags
}

resource "aws_iam_role_policy" "cert_manager" {
  count = var.cert_manager_enable ? 1 : 0

  name = "CertManager"
  role = aws_iam_role.cert_manager.0.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "route53:GetChange",
            "Resource": "arn:aws:route53:::change/*"
        },
        {
            "Effect": "Allow",
            "Action": [
              "route53:ChangeResourceRecordSets",
              "route53:ListResourceRecordSets"
            ],
            "Resource": "arn:aws:route53:::hostedzone/${data.aws_route53_zone.this.zone_id}"
        },
        {
            "Effect": "Allow",
            "Action": "route53:ListHostedZonesByName",
            "Resource": "*"
        }
    ]
}
EOF
}


resource "null_resource" "cert_manager_crds" {
  count = var.cert_manager_enable ? 1 : 0

  provisioner "local-exec" {
    command = join(" ", [
      "kubectl apply",
      "--validate=false",
      "--kubeconfig=${module.eks.kubeconfig_filename}",
      "-f https://github.com/jetstack/cert-manager/releases/download/v${local.cert_manager_version}/cert-manager.crds.yaml",
    ])
  }

  depends_on = [
    module.eks,
  ]
}

resource "kubernetes_namespace" "cert_manager" {
  count = var.cert_manager_enable ? 1 : 0

  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  count = var.cert_manager_enable ? 1 : 0

  name       = "cert-manager"
  chart      = "cert-manager"
  version    = local.cert_manager_version
  repository = "https://charts.jetstack.io"
  namespace  = kubernetes_namespace.cert_manager.0.metadata.0.name

  set {
    name  = "global.rbac.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = local.cert_manager_service_account_name
  }

  # Otherwise cert-manager isn't able to read the
  # AWS STS token mounted inside the container.
  #
  # https://github.com/jetstack/cert-manager/issues/2147#issuecomment-540542406
  set {
    name  = "securityContext.enabled"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cert_manager.0.arn
    type  = "string"
  }

  set {
    name  = "nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }

  set {
    name  = "webhook.nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }

  set {
    name  = "cainjector.nodeSelector.kubernetes\\.io/os"
    value = "linux"
    type  = "string"
  }

  depends_on = [
    null_resource.cert_manager_crds,
  ]
}

resource "local_file" "cert_manager_issuers" {
  count = var.cert_manager_enable ? 1 : 0

  filename        = "${path.module}/.generated_manifests/issuers.yaml"
  file_permission = "0655"

  content = templatefile("${path.module}/manifests/cert-manager-issuers.yaml.tmpl", {
    author_email = var.cert_manager_email
    dns_zone     = var.dns_zone
    dns_zone_id  = data.aws_route53_zone.this.zone_id
    region       = data.aws_region.current.name
  })
}

resource "null_resource" "cert_manager_issuers" {
  count = var.cert_manager_enable ? 1 : 0

  depends_on = [
    null_resource.cert_manager_crds.0,
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.cert_manager_issuers.0.filename}"

    environment = {
      KUBECONFIG = "${path.root}/${module.eks.kubeconfig_filename}"
    }
  }
}
