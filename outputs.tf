output "cluster_arn" {
  description = "ARN of the provisioned EKS cluster."
  value       = module.eks.cluster_arn
}

output "cluster_name" {
  description = "Name of the provisioned EKS cluster."
  value       = module.eks.cluster_id
}

output "cluster_version" {
  description = "Version of the provisioned EKS cluster."
  value       = module.eks.cluster_version
}

output "kubeconfig" {
  description = "Contents of the kubeconfig for the provisioned EKS cluster."
  value       = module.eks.kubeconfig
}

output "kubeconfig_filename" {
  description = "Filename of the generated kubeconfig for the provisioned EKS cluster."
  value       = module.eks.kubeconfig_filename
}

output "workers_asg_arns" {
  description = "ARNs of the provisioned Auto-Scaling Groups."
  value       = module.eks.workers_asg_arns
}

output "oidc_provider_arn" {
  description = "ARN of the Open ID Connect issuer provisioned for EKS to allow K8s Service Accounts to assume IAM roles."
  value       = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  description = "URL of the Open ID Connect issuer provisioned for EKS to allow K8s Service Accounts to assume IAM roles."
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_endpoint" {
  description = "The endpoint for your Kubernetes API server."
  value       = data.aws_eks_cluster.cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "Cluster CA Certificate."
  value       = data.aws_eks_cluster.cluster.certificate_authority.0.data
}

output "cluster_token" {
  value       = data.aws_eks_cluster_auth.cluster.token
  description = "Cluster access token."
  sensitive   = true
}

output "workers_asg_names" {
  value = module.eks.workers_asg_names
}

