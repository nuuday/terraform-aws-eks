variable "cluster_default_workers_subnets" {
  default     = []
  description = "Default worker subnets"
  type        = list(string)
}

variable "cluster_default_workers_asg_max_size" {
  default     = 5
  description = "Default worker asg max size"
  type        = number
}

variable "cluster_default_workers_instance_types" {
  default     = ["m5.large"]
  description = "Default worker subnets"
  type        = list(string)
}

variable "cluster_default_workers_enabled" {
  default     = true
  description = "Default worker subnets"
  type        = bool
}

variable "loadbalancer_enabled" {
  default = false
  type    = bool
}

variable "loadbalancer_subnets" {
  default = []
  type    = list(string)
}

variable "loadbalancer_listeners" {
  description = "List of loadbalancer listeners and node port (https and http will be enabled automatically when enabling the ingress controller)"
  default     = []
  type = list(object({
    port     = number
    name     = string
    cidr     = list(string)
    nodePort = number
    protocol = string
  }))
}

variable "route53_zones" {
  default     = []
  type        = list(string)
  description = "List of route53 zones the cluster should manage."
}

variable "metrics_server_enable" {
  default     = true
  description = "Enable or Disable metrics-server"
  type        = bool
}
variable "cilium_enable" {
  default     = false
  description = "Enable or Disable cilium"
  type        = bool
}
variable "prometheus_enable" {
  default     = true
  description = "Enable or Disable prometheus"
  type        = bool
}

variable "loki_enable" {
  default     = true
  description = "Enable or Disable loki"
  type        = bool
}

variable "kube_monkey_enable" {
  default     = true
  description = "Enable or Disable kube-monkey"
  type        = bool
}

variable "aws_node_termination_handler_enable" {
  default     = true
  description = "Enable or Disable AWS Node Termination handler"
  type        = bool
}

variable "cluster_autoscaler_enable" {
  default     = true
  description = "Enable or Disable Cluster Autoscaler"
  type        = bool
}

variable "cluster_scheduled_shutdown_enabled" {
  default     = false
  description = "Schedule worker nodes shutdown outside of business hours."
  type        = bool
}

variable "cluster_scheduled_shutdown_start" {
  default     = "0 17 * * *"
  description = "When should the scheduled shutdown start"
  type        = string
}

variable "cluster_scheduled_shutdown_end" {
  default     = "0 6 * * 1-5"
  description = "When should the schedules shutdown end"
  type        = string
}

variable "external_dns_enable" {
  default     = true
  description = "Enable or Disable External-dns"
  type        = bool
}

variable "cert_manager_enable" {
  default     = true
  description = "Enable or Disable cert-manager"
  type        = bool
}

variable "cert_manager_email" {
  description = "Email address to associate with issued ssl certificates"
  type        = string
}

variable "cert_manager_ingress_class" {
  default     = ""
  type        = string
  description = "Cert manager ingress class"
}

variable "ingress_controller_ingress_enable" {
  default     = true
  type        = bool
  description = "Enable or disable preinstalled ingress controller"
}

variable "ingress_controller_ingress_class" {
  default     = ""
  type        = string
  description = "Ingress controller class"
}

variable "ingress_controller_ingress_flavour" {
  default = "nginx"
  type    = string
  /*
  TODO: Add when fully supports
  validation {
    condition = can(regex("^(nginx)$", var.ingress_controller_ingress_flavour))
  }
  */
  description = "Ingress controller class"
}

variable "ingress_controller_https_nodePort" {
  default = 32443
  type    = number
}
variable "ingress_controller_ingress_https_cidr" {
  default = ["0.0.0.0/0"]
  type    = list(string)
}
variable "ingress_controller_https_port" {
  default = 443
  type    = number
}
variable "ingress_controller_http_port" {
  default = 80
  type    = number
}
variable "ingress_controller_ingress_http_cidr" {
  default = ["0.0.0.0/0"]
  type    = list(string)
}
variable "ingress_controller_http_nodePort" {
  default = 32080
  type    = number
}

variable "spinnaker_context_prefix" {
  default = ""
}

variable "spinnaker_enabled" {
  default = false
  type = bool
  description = "Enable or disable spinnaker service account"
}
