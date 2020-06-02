provider "kubernetes" {
  version = "~>1.11"

  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

resource "null_resource" "aws_vpc_cni" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = module.eks.kubeconfig_filename
    }
    command = "kubectl --token=${data.aws_eks_cluster_auth.cluster.token} apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v${var.cluster_aws_cni_version}/aws-k8s-cni.yaml"
  }
}

