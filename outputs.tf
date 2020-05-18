output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_name" {
  value = module.eks.cluster_id
}

output "cluster_version" {
  value = module.eks.cluster_version
}

output "kubeconfig" {
  value = module.eks.kubeconfig
}

output "kubeconfig_filename" {
  value = module.eks.kubeconfig_filename
}

output "workers_asg_arns" {
  value = module.eks.workers_asg_arns
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}
