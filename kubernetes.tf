provider "kubernetes" {
  version = "~>1.11"

  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

resource "null_resource" "aws_iam_cluster_role_bindings" {
  provisioner "local-exec" {
    command = <<EOF
cat <<MOF | kubectl apply --token ${data.aws_eks_cluster_auth.cluster.token} -f -
${templatefile("${path.module}/files/cluster-role-bindings.yaml", { tags = jsonencode(local.tags) })}
MOF
EOF

    environment = {
      KUBECONFIG = "${module.eks.kubeconfig_filename}"
    }
  }
}