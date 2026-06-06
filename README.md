# terraform-network-module

A reusable, production-grade Terraform module that provisions a complete AWS VPC networking stack. Designed to support three NAT gateway deployment modes — from zero cost to full high availability — controlled entirely through input variables.

---

## What This Module Creates

- VPC with DNS hostnames and DNS support enabled
- Public subnets (one per entry in `public_subnet_data`)
- Private subnets (one per entry in `private_subnet_data`)
- Internet Gateway
- Public route table (shared across all public subnets) with a route to the IGW
- Public route table associations
- Elastic IPs, NAT gateways, private route tables, and private route table associations — conditionally, based on NAT mode

---

## NAT Gateway Modes

This module supports three modes, controlled by two boolean variables:

| Mode | `need_nat_gateway` | `need_single_nat_gateway` | What gets created |
|---|---|---|---|
| **No NAT** | `false` | any | No EIPs, no NAT gateways, no private route tables. Private subnets have no outbound internet. Cheapest. |
| **Single NAT** | `true` | `true` | One EIP, one NAT gateway in the first public subnet. All private subnets share it. Good for dev/staging. |
| **HA NAT** | `true` | `false` | One EIP and one NAT gateway per public subnet. Each private subnet routes through its AZ-local NAT. Production-grade. |

---

## What Makes This Module Better

Most basic network modules use `count` for subnet iteration. This module uses `for_each` with stable CIDR-based keys — meaning you can add or remove individual subnets without Terraform destroying and recreating unrelated ones.

Other improvements over typical implementations:

- **`locals` for NAT count** — computed once, referenced everywhere. No repeated nested ternaries.
- **One private route table per subnet** — each private subnet gets its own route table pointing to its AZ-local NAT gateway in HA mode. This eliminates cross-AZ traffic and maintains true AZ isolation.
- **`merge()` for tags** — common tags (Environment, ManagedBy, Project) applied consistently to every resource, with resource-specific Name tags added per resource.
- **Conditional private route tables** — private route tables are only created when NAT exists. No orphaned route tables with broken routes.
- **Clean, no dead code** — no commented-out blocks or leftover debug resources.

---

## Usage

```hcl
module "network" {
  source = "git::https://github.com/Jasleenkaurnotay/terraform-network-module.git"

  vpc_name    = "my-app"
  vpc_cidr    = "10.0.0.0/16"
  environment = "prod"

  public_subnet_data = [
    { cidr = "10.0.1.0/24", availability_zone = "us-east-1a", prefix = "pub" },
    { cidr = "10.0.2.0/24", availability_zone = "us-east-1b", prefix = "pub" },
  ]

  private_subnet_data = [
    { cidr = "10.0.3.0/24", availability_zone = "us-east-1a", prefix = "pvt" },
    { cidr = "10.0.4.0/24", availability_zone = "us-east-1b", prefix = "pvt" },
  ]

  need_nat_gateway        = true
  need_single_nat_gateway = false  # HA mode — one NAT per AZ
}
```

---

## Input Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `vpc_name` | `string` | — | Name prefix applied to all resources |
| `vpc_cidr` | `string` | — | CIDR block for the VPC |
| `environment` | `string` | `"dev"` | Deployment environment (dev / staging / prod) |
| `public_subnet_data` | `list(object)` | — | List of public subnet configurations (cidr, availability_zone, prefix) |
| `private_subnet_data` | `list(object)` | — | List of private subnet configurations (cidr, availability_zone, prefix) |
| `need_nat_gateway` | `bool` | `false` | Master switch — whether to create NAT infrastructure at all |
| `need_single_nat_gateway` | `bool` | `true` | When NAT is enabled: true = single shared NAT (cost-saving), false = one NAT per AZ (HA) |

---

## Outputs

| Output | Description |
|---|---|
| `vpc_id` | The ID of the created VPC |
| `public_subnet_ids` | List of all public subnet IDs |
| `private_subnet_ids` | List of all private subnet IDs |
| `nat_gateway_ids` | List of all NAT gateway IDs (empty if NAT disabled) |

---

## Requirements

| Tool | Version |
|---|---|
| Terraform | >= 1.10 |
| AWS Provider | ~> 5.0 |

---

## Testing

A complete test configuration is provided in the `test/` directory.

```bash
cd test/
terraform init
terraform validate
terraform plan
terraform apply
```

Edit `test/terraform.tfvars` to test different NAT modes:

```hcl
# No NAT (free)
need_nat_gateway = false

# Single NAT
need_nat_gateway        = true
need_single_nat_gateway = true

# HA NAT (one per AZ)
need_nat_gateway        = true
need_single_nat_gateway = false
```

> **Important:** NAT gateways and Elastic IPs incur AWS charges. Always run `terraform destroy` after testing.

---

## File Structure

```
terraform-network-module/
├── main.tf          # VPC, subnets, IGW, route tables, NAT gateways
├── variables.tf     # All input variable definitions with types and descriptions
├── locals.tf        # Computed values: nat_count, common_tags, subnet maps
├── outputs.tf       # VPC ID, subnet IDs, NAT gateway IDs
├── versions.tf      # Terraform and provider version requirements
└── test/
    ├── main.tf           # Calls the module with local source path
    ├── variables.tf      # Variable declarations for the test caller
    ├── providers.tf      # AWS provider configuration
    ├── terraform.tfvars  # Test values — edit to switch NAT modes
    └── .gitignore        # Excludes state files and .terraform directory
```

---

## Author

Jasleen Kaur 
