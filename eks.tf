locals {
  map_roles = concat([
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:role/admin"
      username = "administrator"
      groups   = ["administrators"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:role/admin-robot"
      username = "admin-robot"
      groups   = ["administrators"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:role/poweruser"
      username = "poweruser"
      groups   = ["powerusers"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:role/developers"
      username = "developer"
      groups   = ["developers"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:role/readonly"
      username = "readonly"
      groups   = ["readonly"]
    },
  ], var.map_roles)

  eks_oidc_issuer = trimprefix(module.eks.cluster_oidc_issuer_url, "https://")

  worker_groups_tags = [
    for tag in keys(module.cluster-autoscaler.asg_tags) :
    {
      key = tag, value = module.cluster-autoscaler.asg_tags[tag], propagate_at_launch = true
    }
  ]

  worker_groups_launch_template_default = [
    for subnet in var.cluster_default_workers_subnets :
    {
      name                    = subnet
      override_instance_types = var.cluster_default_workers_instance_types
      subnets                 = [subnet]

      spot_instance_pools           = 4
      asg_max_size                  = var.cluster_default_workers_asg_max_size
      asg_min_size                  = 0
      asg_desired_capacity          = 1
      kubelet_extra_args            = "--node-labels=node.kubernetes.io/lifecycle=spot"
      asg_recreate_on_change        = true
      public_ip                     = false
      tags                          = local.worker_groups_tags
      target_group_arns             = module.lb.target_group_arns
      additional_security_group_ids = [aws_security_group.worker_http_ingress[0].id]
    }
  ]
  worker_groups_launch_template = var.cluster_default_workers_enabled ? concat(var.worker_groups_launch_template, local.worker_groups_launch_template_default) : var.worker_groups_launch_template
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "13.2.1"

  cluster_name = var.cluster_name
  subnets      = var.subnets

  attach_worker_cni_policy                     = var.attach_worker_cni_policy
  cluster_create_security_group                = var.cluster_create_security_group
  cluster_create_timeout                       = var.cluster_create_timeout
  cluster_delete_timeout                       = var.cluster_delete_timeout
  cluster_enabled_log_types                    = var.cluster_enabled_log_types
  cluster_encryption_config                    = var.cluster_encryption_config
  cluster_endpoint_private_access              = var.cluster_endpoint_private_access
  cluster_endpoint_private_access_cidrs        = var.cluster_endpoint_private_access_cidrs
  cluster_endpoint_public_access               = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs         = var.cluster_endpoint_public_access_cidrs
  cluster_iam_role_name                        = var.cluster_iam_role_name
  cluster_log_kms_key_id                       = var.cluster_log_kms_key_id
  cluster_log_retention_in_days                = var.cluster_log_retention_in_days
  cluster_security_group_id                    = var.cluster_security_group_id
  cluster_version                              = var.cluster_version
  config_output_path                           = var.config_output_path
  create_eks                                   = var.create_eks
  eks_oidc_root_ca_thumbprint                  = var.eks_oidc_root_ca_thumbprint
  enable_irsa                                  = var.enable_irsa
  iam_path                                     = var.iam_path
  kubeconfig_aws_authenticator_additional_args = var.kubeconfig_aws_authenticator_additional_args
  kubeconfig_aws_authenticator_command         = var.kubeconfig_aws_authenticator_command
  kubeconfig_aws_authenticator_command_args    = var.kubeconfig_aws_authenticator_additional_args
  kubeconfig_aws_authenticator_env_variables   = var.kubeconfig_aws_authenticator_env_variables
  kubeconfig_name                              = var.kubeconfig_name
  manage_aws_auth                              = var.manage_aws_auth
  manage_cluster_iam_resources                 = var.manage_cluster_iam_resources
  manage_worker_iam_resources                  = var.manage_worker_iam_resources
  node_groups                                  = var.node_groups
  node_groups_defaults                         = var.node_groups_defaults
  permissions_boundary                         = var.permissions_boundary
  wait_for_cluster_cmd                         = var.wait_for_cluster_cmd
  wait_for_cluster_interpreter                 = var.wait_for_cluster_interpreter
  worker_groups                                = var.worker_groups
  worker_additional_security_group_ids         = var.worker_additional_security_group_ids
  worker_ami_name_filter                       = var.worker_ami_name_filter
  worker_ami_name_filter_windows               = var.worker_ami_name_filter_windows
  worker_ami_owner_id                          = var.worker_ami_owner_id
  worker_ami_owner_id_windows                  = var.worker_ami_owner_id_windows
  worker_create_initial_lifecycle_hooks        = var.worker_create_initial_lifecycle_hooks
  worker_create_security_group                 = var.worker_create_security_group
  worker_groups_launch_template                = local.worker_groups_launch_template
  worker_security_group_id                     = var.worker_security_group_id
  worker_sg_ingress_from_port                  = var.worker_sg_ingress_from_port
  workers_additional_policies                  = var.workers_additional_policies
  workers_group_defaults                       = var.workers_group_defaults
  workers_role_name                            = var.workers_role_name
  write_kubeconfig                             = var.write_kubeconfig
  vpc_id                                       = var.vpc_id
  tags                                         = local.tags
  map_roles                                    = local.map_roles
  map_users                                    = var.map_users
  map_accounts                                 = var.map_accounts
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

resource "aws_autoscaling_schedule" "eks_asg_on" {
  depends_on             = [module.eks]
  count                  = var.cluster_scheduled_shutdown_enabled ? length(module.eks.workers_asg_names) : 0
  scheduled_action_name  = "${module.eks.workers_asg_names[count.index]}-turn-on"
  min_size               = local.worker_groups_launch_template[count.index].asg_min_size
  max_size               = local.worker_groups_launch_template[count.index].asg_max_size
  desired_capacity       = local.worker_groups_launch_template[count.index].asg_desired_capacity
  recurrence             = var.cluster_scheduled_shutdown_end
  autoscaling_group_name = module.eks.workers_asg_names[count.index]
}

resource "aws_autoscaling_schedule" "eks_asg_off" {
  depends_on             = [module.eks]
  count                  = var.cluster_scheduled_shutdown_enabled ? length(module.eks.workers_asg_names) : 0
  scheduled_action_name  = "${module.eks.workers_asg_names[count.index]}-turn-off"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = var.cluster_scheduled_shutdown_start
  autoscaling_group_name = module.eks.workers_asg_names[count.index]
}

