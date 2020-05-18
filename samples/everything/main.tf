terraform {
  required_version = "~>0.12"
}

provider "aws" {
  version = "~>2.60"
}

locals {
  dns_zone = "asore.aws.nuuday.nu"
}

data "aws_availability_zones" "available" {}

data "aws_route53_zone" "root" {
  name = "aws.nuuday.nu"
}

resource "aws_route53_zone" "test" {
  name          = local.dns_zone
  force_destroy = true
}

resource "aws_route53_record" "test" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = local.dns_zone
  type    = "NS"
  ttl     = "30"

  records = aws_route53_zone.test.name_servers
}

# Even though we create the DNS zone above, we can't just
# reference its 'name' attribute since it's not a computed value.
#
# Looking it up like this forces the module.eks to wait until the zone
# is actually created.
data "aws_route53_zone" "test" {
  name = aws_route53_zone.test.name
}

module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v2.33.0"

  name                 = "asorevpc"
  cidr                 = "172.16.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets       = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

module "cluster" {
  source = "../../"

  cluster_name = "complete-example"

  # Addons
  ingress_enable                  = true
  external_dns_enable             = true
  cluster_autoscaler_enable       = true
  cert_manager_enable             = true
  cert_manager_email              = "asore@nuuday.dk"
  node_termination_handler_enable = true

  samples_enable                     = true
  samples_use_production_cert_issuer = false

  dns_zone = trimsuffix(data.aws_route53_zone.test.name, ".")

  linux_workers_count   = 2
  windows_workers_count = 0

  vpc_id            = module.vpc.vpc_id
  worker_subnet_ids = module.vpc.private_subnets
  lb_subnet_ids     = module.vpc.public_subnets

  tags = {
    author = "asore@nuuday.dk"
    team   = "odin-platform"
  }
}
