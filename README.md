# EKS

This Terraform module provisions an [EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/clusters.html) with

- 2x Linux worker nodes
- [IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) enabled

It also provisions a [Network Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/network-load-balancers.html) with

- Public listener on port `80/tcp` for HTTP traffic
- Public listener on port `443/tcp` for HTTPS traffic

Each listener forwards traffic to two distinct target groups.
All worker nodes are automatically registered as targets inside the both target groups.

For ingress, it deploys the `nginx-ingress-controller` using the Helm chart [stable/nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress).
See the [Ingress](#ingress) section for more details.

DNS records in Route53 are managed using [ExternalDNS](https://github.com/kubernetes-sigs/external-dns) using the Helm chart [stable/external-dns](https://github.com/helm/charts/tree/master/stable/external-dns).
See the [DNS](#dns) section for more details.

## Getting Started

Spin it all up using the following command:

```bash
terraform apply
```

**Note** If you want Windows workers added to the cluster, try the below command instead.
It will also spin up an IIS container and expose it to the Internet.

```bash
terraform apply -var windows_workers_count=1
```

Once completed, Terraform will return URLs for the sample app(s) deployed into the EKS cluster.
They are described below.

|Output key        |Description                                                                                  |
|------------------|---------------------------------------------------------------------------------------------|
|`iis_sample_url`  |URL for the sample IIS app. **Note** Requires Terraform variable `windows_workers_count > 0`.|
|`nginx_sample_url`|URL for the sample nginx app.                                                                |

**Note** It may take several minutes for the URLs to be accessible.
This is due to DNS changes needing to propagate.

**Note** The HTTPS certificates are issued through the [Let's Encrypt *staging* issuer](https://letsencrypt.org/docs/staging-environment/).
This is done to avoid hitting Let's Encrypt quotas.

## Prerequisites

These must be installed and available in your `$PATH`

- Helm 3+
- Terraform 0.12
- kubectl
- aws-iam-authenticator

## Ingress

Worker nodes which have the `nginx-ingress-controller` running on them will become _healthy_ in the target group,
and will start receiving traffic from the NLB.

The nginx controller will, based on `Ingress` objects we deploy, adjust their configurations and ensure traffic is routed to the correct services inside the cluster.
There's a "catch-all" service deployed alongside with `nginx-ingress-controller`, so we'll be able to see if traffic at least makes it into the cluster.

Try visiting the load balancer hostname in your browser. Retrieve it like this:

```bash
# bash/sh/zsh
lb_host=$(terraform output lb_fqdn)
curl $lb_host
```

```powershell
# PowerShell
$lb_host = $(terraform output lb_fqdn)
Invoke-WebRequest -UseBasicParsing -Uri $lb_host
```

If everything is working as intended, you'll see the following response:

```
default backend - 404
```

## DNS

**Note** To avoid mistakes, this Terraform module creates a new DNS zone in Route53 in which ExternalDNS operates.

ExternalDNS is granted access to modify this DNS zone using [IAM Roles for Service Accounts]().
The IAM role, policy, and ExternalDNS itself is defined in [external-dns.tf](addons/addon-external-dns.tf).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~>0.12 |
| aws | ~>2.60 |
| helm | ~>1.2 |
| http | ~>1.2 |
| kubernetes | ~>1.11 |

## Providers

| Name | Version |
|------|---------|
| aws | ~>2.60 |
| helm | ~>1.2 |
| http | ~>1.2 |
| kubernetes | ~>1.11 |
| local | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cert\_manager\_email | The e-mail address associated with the Let's Encrypt account created. It will receive expiration warnings etc. | `string` | n/a | yes |
| cert\_manager\_enable | Whether to deploy and configure Cert Manager with Let's Encrypt ClusterIssuers. | `bool` | `false` | no |
| cluster\_autoscaler\_enable | Whether to deploy and configure Cluster Auto Scaler. | `bool` | `false` | no |
| cluster\_name | Name of the EKS cluster. | `string` | n/a | yes |
| cluster\_version | EKS version to provision. | `string` | `"1.16"` | no |
| dns\_zone | The DNS zone to associate with this cluster. If Cert Manager is enabled, an IAM role will be created allowing Cert Manager Service Account to maintain records under this DNS zone. | `any` | n/a | yes |
| external\_dns\_enable | Whether to deploy and configure ExternalDNS with associated Route53 DNS zone. | `bool` | `false` | no |
| ingress\_enable | Enables or disabled public ingress through Network Load Balancer and nginx-ingress controller. | `bool` | n/a | yes |
| lb\_subnet\_ids | Subnet IDs to associate with the Network Load Balancer. Typically the public subnets of your VPC. | `list(string)` | `[]` | no |
| linux\_workers\_count | The number of Linux worker nodes to create through a single ASG. | `number` | `2` | no |
| node\_termination\_handler\_enable | Whether to deploy AWS Node Termination Handler which gracefully drains and cordons nodes backed by EC2 spot instances. | `bool` | `false` | no |
| samples\_enable | Deploys a sample NGINX and exposes it using Ingress, and if enabled, a Windows IIS exposed using ingress. | `bool` | `false` | no |
| samples\_use\_production\_cert\_issuer | If deploy\_samples is true, this determines whether to use production or staging ClusterIssuer for Let's Encrypt certs. | `bool` | `false` | no |
| tags | Tags to apply to all resources provisioned by this module. | `map(string)` | `{}` | no |
| vpc\_id | The ID of the VPC to provision the EKS cluster, worker nodes, and load balancer into. | `string` | n/a | yes |
| windows\_workers\_count | The number of Windows worker nodes to create through a single ASG. | `number` | `0` | no |
| worker\_subnet\_ids | Subnet IDs to associate with worker nodes. Typically the private subnets of your VPC. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_arn | ARN of the provisioned EKS cluster. |
| cluster\_name | Name of the provisioned EKS cluster. |
| cluster\_oidc\_issuer\_url | URL of the Open ID Connect issuer provisioned for EKS to allow K8s Service Accounts to assume IAM roles. |
| cluster\_version | Version of the provisioned EKS cluster. |
| iis\_sample\_url | URL for the Windows IIS sample app. It will take a few minutes to be available due to DNS propagation. |
| kubeconfig | Contents of the kubeconfig for the provisioned EKS cluster. |
| kubeconfig\_filename | Filename of the generated kubeconfig for the provisioned EKS cluster. |
| nginx\_sample\_url | URL for the NGINX sample app. It will take a few minutes to be available due to DNS propagation. |
| oidc\_provider\_arn | ARN of the Open ID Connect issuer provisioned for EKS to allow K8s Service Accounts to assume IAM roles. |
| workers\_asg\_arns | ARNs of the provisioned Auto-Scaling Groups. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
