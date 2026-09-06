# 🔐 Phase 03 — Checkov Removal & Final Decision

<p align="center">

![Security Scanning](https://img.shields.io/badge/Security%20Scanning-IaC%20Security-red?style=for-the-badge)

![Checkov](https://img.shields.io/badge/Checkov-Removed%20from%20CI-orange?style=for-the-badge)

![Trivy](https://img.shields.io/badge/Trivy-Primary%20IaC%20Scanner-blue?style=for-the-badge&logo=aquasecurity)

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-black?style=for-the-badge&logo=githubactions)

</p>

> 🎯 **Objective:** Remove Checkov from the Terraform CI pipeline after repeated investigation of `CKV2_AZURE_31`, preserve the correct Terraform architecture, and use Trivy as the primary Infrastructure-as-Code security scanner.

---

# 📌 1. Background

During the Terraform CI pipeline implementation for the **Cyberex Azure Landing Zone**, Checkov was introduced as an Infrastructure-as-Code security scanner.

The initial objective was:

```text
GitHub Repository
       │
       ▼
GitHub Actions
       │
       ├── Terraform Format
       ├── Terraform Init
       ├── Terraform Validate
       ├── Checkov Security Scan
       ├── Trivy IaC Scan
       └── Terraform Plan

```

Checkov successfully detected multiple Azure security controls.

However, one specific control repeatedly failed:

CKV2_AZURE_31

"Ensure VNET subnet is configured with a Network Security Group (NSG)"

The failure continued even after the Terraform configuration correctly created and associated an NSG with the subnets.

📌 2. Primary Problem

The affected Terraform architecture contained:

VNET
 │
 ├── Web Subnet
 ├── Application Subnet
 ├── Data Subnet
 ├── Management Subnet
 └── Security Subnet

A dedicated NSG module was created:

terraform/
└── modules/
    ├── nsg/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── subnet/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

The NSG was then associated with the subnets through:

resource "azurerm_subnet_network_security_group_association" "this" {

  for_each = azurerm_subnet.Subnets

  subnet_id                 = each.value.id
  network_security_group_id = var.network_security_group_id
}

This is the correct Terraform pattern for managing subnet-to-NSG association separately from subnet creation.

📌 3. Terraform Configuration Before Final Decision

The subnet resource was:

resource "azurerm_subnet" "Subnets" {

  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes = each.value.address_prefixes
}

The association was separately managed:

resource "azurerm_subnet_network_security_group_association" "this" {

  for_each = azurerm_subnet.Subnets

  subnet_id                 = each.value.id
  network_security_group_id = var.network_security_group_id
}

The root module passed the NSG ID:

module "subnets" {

  source = "./modules/subnet"

  subnets = var.subnets

  virtual_network_name = var.vnet_name

  resource_group_name = var.resource_groups["network"].name

  network_security_group_id = module.nsg.id

  depends_on = [
    module.vnet
  ]
}

The NSG itself was created through:

module "nsg" {

  source = "./modules/nsg"

  name                = "cyberex-nsg"
  location            = var.nic_location
  resource_group_name = var.resource_groups["network"].name

  tags = {
    Environment = "Development"
    Project     = "Cyberex"
    ManagedBy   = "Terraform"
  }
}
📌 4. Important Terraform Error Encountered

During troubleshooting, an attempt was made to configure:

network_security_group_id = var.network_security_group_id

directly inside:

resource "azurerm_subnet" "Subnets"

Terraform rejected this configuration.

The error was:

Error: Value for unconfigurable attribute

Can't configure a value for "network_security_group_id":
its value will be decided automatically based on the result of applying this configuration.

This confirmed that the current AzureRM provider behavior should not be worked around by forcing the NSG ID directly into the subnet resource.

The correct Terraform architecture remained:

azurerm_subnet
       │
       │
       ▼
azurerm_subnet_network_security_group_association
       │
       ▼
azurerm_network_security_group
📌 5. Checkov Failure

Checkov repeatedly reported:

Passed checks: 9
Failed checks: 5
Skipped checks: 0

The five failures were all:

CKV2_AZURE_31

The affected resources were:

module.subnets.azurerm_subnet.Subnets["web"]

module.subnets.azurerm_subnet.Subnets["application"]

module.subnets.azurerm_subnet.Subnets["data"]

module.subnets.azurerm_subnet.Subnets["management"]

module.subnets.azurerm_subnet.Subnets["security"]

Therefore:

1 Check
   │
   └── 5 subnet instances

The problem was not five independent Terraform configuration errors.

It was the same Checkov control failing against all subnet instances created through:

for_each = var.subnets
📌 6. Checks That Were Already Passing

Checkov was successfully passing several Azure security checks.

Network Interface
CKV_AZURE_118
Ensure that Network Interfaces disable IP forwarding

Status:

PASSED
HTTP Access
CKV_AZURE_160
Ensure that HTTP (port 80) access is restricted from the internet

Status:

PASSED
RDP Access
CKV_AZURE_9
Ensure that RDP access is restricted from the internet

Status:

PASSED
SSH Access
CKV_AZURE_10
Ensure that SSH access is restricted from the internet

Status:

PASSED
UDP Services
CKV_AZURE_77
Ensure that UDP Services are restricted from the Internet

Status:

PASSED
VNET DNS
CKV_AZURE_183
Ensure that VNET uses local DNS addresses

Status:

PASSED
VNET DNS Endpoints
CKV_AZURE_182
Ensure that VNET has at least 2 connected DNS Endpoints

Status:

PASSED
Public IP on NIC
CKV_AZURE_119
Ensure that Network Interfaces don't use public IPs

Status:

PASSED
VM Public IP / Serial Console
CKV2_AZURE_39
Ensure Azure VM is not configured with public IP and serial console access

Status:

PASSED
📌 7. Checkov Troubleshooting Attempts

The following approaches were investigated during troubleshooting.

Attempt 01 — Verify Terraform Configuration

Commands used:

terraform fmt -recursive
terraform validate
terraform plan

Terraform eventually produced:

Plan: 16 to add, 0 to change, 0 to destroy.

This confirmed that Terraform itself could successfully build the planned infrastructure.

📌 8. Verify Module Structure

The Terraform module structure was checked using:

tree /F .\modules

The final structure was:

modules
├── nic
│   ├── main.tf
│   ├── output.tf
│   └── variables.tf
│
├── nsg
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
│
├── public-ip
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
│
├── resource-group
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
│
├── subnet
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
│
└── vnet
    ├── main.tf
    ├── outputs.tf
    └── variables.tf

This verified that the NSG and subnet modules were correctly separated.

📌 9. NSG Module Verification

The NSG module was inspected with:

Get-Content .\modules\nsg\main.tf

The NSG resource was:

resource "azurerm_network_security_group" "this" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

The output was verified using:

Get-Content .\modules\nsg\outputs.tf

The module correctly exposed:

output "id" {

  description = "NSG resource ID"

  value = azurerm_network_security_group.this.id
}

Therefore the root module could correctly consume:

module.nsg.id
📌 10. Subnet Module Verification

Subnet variables were inspected:

Get-Content .\modules\subnet\variables.tf

The module accepted:

variable "network_security_group_id" {

  description = "Network Security Group ID associated with subnets"

  type = string
}

The subnet module also contained the dedicated association resource:

resource "azurerm_subnet_network_security_group_association" "this" {

  for_each = azurerm_subnet.Subnets

  subnet_id                 = each.value.id
  network_security_group_id = var.network_security_group_id
}

Therefore NSG association was explicitly managed.

📌 11. Checkov Version Verification

Checkov version was checked using:

checkov --version

Result:

3.3.13

Terraform version:

Terraform v1.14.6

AzureRM provider:

registry.terraform.io/hashicorp/azurerm v5.1.0

The Terraform provider configuration was verified through:

Get-Content .\providers.tf
📌 12. Terraform Provider Verification

The project was using:

terraform {

  required_version = ">= 1.6.0"

  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.1.0"
    }
  }
}

The lock file also confirmed:

azurerm 5.1.0

using:

Get-Content .\.terraform.lock.hcl |
Select-String "azurerm" -Context 2,5
📌 13. Checkov Direct Scan

Checkov was executed directly against the Terraform directory:

checkov -d .

The scan also exposed a separate local Windows/Python issue:

UnicodeDecodeError: 'charmap' codec can't decode byte 0x90

This indicated an additional local encoding/environment issue while running Checkov on Windows/Python 3.13.

Therefore Checkov troubleshooting involved two different aspects:

1. CKV2_AZURE_31
       │
       └── Terraform / Checkov relationship

2. UnicodeDecodeError
       │
       └── Local Checkov execution environment

These issues were kept separate from the actual Terraform infrastructure design.

📌 14. Checkov Skip Was Considered

A Checkov inline skip was considered:

#checkov:skip=CKV2_AZURE_31:Subnet NSG association is explicitly managed using azurerm_subnet_network_security_group_association

However, this approach was intentionally rejected.

Reason

The objective was:

Fix the security control
        ↓
Not hide the security control

Using a skip would change the scan result from:

FAILED

to:

SKIPPED

It would not prove that Checkov successfully understood the Terraform relationship.

Therefore skipping the check was not considered a genuine resolution.

📌 15. Why Terraform Code Was Not Changed Incorrectly

During troubleshooting, the following principle was maintained:

Do not modify valid Terraform architecture only to satisfy a static-analysis tool.

The subnet and NSG relationship was already explicitly represented using:

azurerm_subnet_network_security_group_association

Therefore the Terraform design was preserved.

The following incorrect workaround was not retained:

network_security_group_id = var.network_security_group_id

inside:

azurerm_subnet

because Terraform itself rejected that configuration.

📌 16. Final Technical Decision

After repeated troubleshooting, the final decision was:

REMOVE CHECKOV FROM CI PIPELINE

and:

KEEP TRIVY AS IaC SECURITY SCANNER

The reason is not that Checkov is a bad security tool.

The reason is that, for this project, the current Checkov implementation was creating repeated friction around:

CKV2_AZURE_31

without providing additional practical value after the Terraform architecture had already been validated.

📌 17. Final Security Scanning Architecture

The CI pipeline will use:

                    GitHub Push / Pull Request
                              │
                              ▼
                       GitHub Actions
                              │
             ┌────────────────┼────────────────┐
             │                │                │
             ▼                ▼                ▼
        Terraform         Terraform         Trivy
          fmt               validate          IaC
             │                │                │
             └────────────────┼────────────────┘
                              │
                              ▼
                       Terraform Plan

The important security gate is:

Trivy
  │
  ├── Terraform IaC scanning
  ├── HIGH vulnerabilities
  └── CRITICAL vulnerabilities
📌 18. Trivy CI Configuration

The pipeline will retain the Trivy IaC scan:

- name: Trivy IaC Security Scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: config
    scan-ref: terraform
    severity: HIGH,CRITICAL
    exit-code: 1
Meaning
scan-type: config

Trivy scans Infrastructure-as-Code configuration.

scan-ref: terraform

The Terraform directory is scanned.

severity: HIGH,CRITICAL

Only High and Critical findings are treated as security-gate findings.

exit-code: 1

If a matching security finding is detected, the GitHub Actions job fails.

📌 19. Final CI Pipeline

The intended pipeline flow is:

1. Checkout Repository
        ↓
2. Azure Login
        ↓
3. Verify Azure Login
        ↓
4. Verify Azure Subscription
        ↓
5. Setup Terraform
        ↓
6. Terraform Format Check
        ↓
7. Terraform Init
        ↓
8. Terraform Validate
        ↓
9. Trivy IaC Security Scan
        ↓
10. Terraform Plan

Checkov is no longer part of this flow.

📌 20. What Was NOT Changed

The following Terraform architecture was preserved:

Resource Group Module
        │
        ├── VNET Module
        │
        ├── Subnet Module
        │       │
        │       └── NSG Association
        │
        ├── NSG Module
        │
        ├── NIC Module
        │
        └── Public IP Module

No infrastructure resource was removed merely to satisfy Checkov.

No NSG association was removed.

No insecure workaround was introduced.

No Checkov skip was used as the final solution.

📌 21. Lessons Learned
Lesson 01 — Security tools are not the infrastructure

A security scanner is a validation layer.

Terraform architecture should not be unnecessarily redesigned just because one scanner cannot correctly interpret a valid relationship.

Lesson 02 — FAILED does not always mean Terraform is wrong

A Checkov failure means:

Checkov could not satisfy the policy

It does not automatically mean:

Azure infrastructure is incorrectly configured

Both Terraform validation and security scanning results must be analyzed independently.

Lesson 03 — Avoid blind Checkov skips

A skip can make the report look clean:

Failed: 0

but the actual result may simply be:

Skipped: 1

Therefore skips should only be used when there is a documented and legitimate exception.

Lesson 04 — Provider version matters

Security scanners interpret Terraform configuration based on their own parser and rule implementation.

The project versions were:

Terraform 1.14.6
AzureRM 5.1.0
Checkov 3.3.13

These versions should always be recorded when troubleshooting scanner behavior.

Lesson 05 — Keep troubleshooting history

Security-tool problems can reappear in future projects.

This document therefore records:

Problem
   ↓
Investigation
   ↓
Commands
   ↓
Terraform validation
   ↓
Checkov results
   ↓
Decision

This avoids repeating the same troubleshooting process in the future.

📌 22. Final Decision Summary
Item	Final Decision
Terraform	✅ Keep
Terraform Validate	✅ Keep
Terraform Plan	✅ Keep
Checkov	❌ Remove from CI
CKV2_AZURE_31	⚠️ Unresolved scanner compatibility/interpretation issue
Checkov Skip	❌ Not used
NSG Association	✅ Keep
NSG Module	✅ Keep
Subnet Module	✅ Keep
Trivy IaC Scan	✅ Keep
HIGH findings	🚫 CI failure
CRITICAL findings	🚫 CI failure
📌 23. Final Status
Terraform Architecture
        │
        ▼
      VALID
        │
        ▼
Terraform Validate
        │
        ▼
      PASS
        │
        ▼
Terraform Plan
        │
        ▼
      PASS
        │
        ▼
Trivy IaC Scan
        │
        ▼
Security Gate
        │
        ▼
Terraform CI

Checkov has been removed from the CI pipeline as a project-level decision.

The Terraform configuration remains focused on correct Azure infrastructure implementation, while Trivy provides the IaC security scanning and CI security gate.

📚 Related Documentation
Phase 01 — Checkov Troubleshooting History
Phase 02 — Checkov Root Cause Analysis
Terraform CI Pipeline
🏁 Final Conclusion

Checkov को हटाने का निर्णय security scanning को हटाने का निर्णय नहीं है।

इस project में decision यह है:

Checkov
   ❌

Trivy
   ✅

Terraform Validation
   ✅

Terraform Plan
   ✅

GitHub Actions Security Gate
   ✅

मुख्य उद्देश्य है:

Correct Terraform architecture + reliable CI validation + practical IaC security scanning

और सबसे महत्वपूर्ण:

Security scanner को satisfy करने के लिए valid infrastructure design को गलत तरीके से modify नहीं किया जाएगा।