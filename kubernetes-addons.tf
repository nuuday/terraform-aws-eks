

module "aws-node-termination-handler" {
  # source = "github.com/nuuday/terraform-aws-eks-addons//modules/aws-node-termination-handler?ref=adding-new-modules"
  source = "../terraform-aws-eks-addons/modules/aws-node-termination-handler"
  enabled = var.aws_node_termination_handler_enabled
}