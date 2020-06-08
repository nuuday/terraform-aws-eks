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
  default     = false
  description = "Enable or Disable Cluster Autoscaler"
  type        = bool
}

variable "cluster_scheduled_shutdown_enabled" {
  default     = false
  description = "Schedule worker nodes shutdown outside of business hours."
  type        = bool
}

variable "cluster_scheduled_shutdown_start" {
  default     = "0 17 * * 1-5"
  description = "When should the scheduled shutdown start"
  type        = string
}

variable "cluster_scheduled_shutdown_end" {
  default     = "0 6 * * 1-5"
  description = "When should the schedules shutdown end"
  type        = string
}