variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "EKS version to provision"
  default     = "1.16"
}

variable "ingress_enable" {
  description = "Enables or disabled public ingress through Network Load Balancer and nginx-ingress controller"
  type        = bool
}

variable "cert_manager_email" {
  description = "The e-mail address associated with the Let's Encrypt account created. It will receive expiration warnings etc."
  type        = string
}

variable "cert_manager_enable" {
  description = "Whether to deploy and configure Cert Manager with Let's Encrypt ClusterIssuers"
  default     = false
}

variable "cluster_autoscaler_enable" {
  description = "Whether to deploy and configure Cluster Auto Scaler"
  default     = false
}

variable "external_dns_enable" {
  description = "Whether to deploy and configure ExternalDNS with associated Route53 DNS zone"
  default     = false
}

variable "samples_enable" {
  description = "Deploys a sample NGINX and exposes it using Ingress, and if enabled, a Windows IIS exposed using ingress"
  default     = false
}

variable "samples_use_production_cert_issuer" {
  description = "If deploy_samples is true, this determines whether to use production or staging ClusterIssuer for Let's Encrypt certs"
  default     = false
}

variable "node_termination_handler_enable" {
  description = "Whether to deploy AWS Node Termination Handler which gracefully drains and cordons nodes backed by EC2 spot instances"
  default     = false
}

variable "dns_zone" {
  description = "The DNS zone to associate with this cluster. If Cert Manager is enabled, an IAM role will be created allowing Cert Manager Service Account to maintain records under this DNS zone."
}

variable "linux_workers_count" {
  default = 2
}

variable "windows_workers_count" {
  default = 0
}

variable "vpc_id" {
  type = string
}

variable "worker_subnet_ids" {
  type = list(string)
}

variable "lb_subnet_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
