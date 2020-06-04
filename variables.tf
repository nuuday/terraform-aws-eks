

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

variable "metrics_server_enabled" {
  default     = true
  description = "Enable or Disable metrics-server"
  type        = bool
}

variable "kube_monkey_enabled" {
  default     = true
  description = "Enable or Disable kube-monkey"
  type        = bool
}

variable "aws_node_termination_handler_enabled" {
  default     = true
  description = "Enable or Disable AWS Node Termination handler"
  type        = bool
}

variable "cluster_autoscaler_enabled" {
  default     = true
  description = "Enable or Disable Cluster Autoscaler"
  type        = bool
}

variable "cluster_autoscaler_version" {
  default     = "7.0.0"
  description = "AWS Node Termination handler version"
  type        = string
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