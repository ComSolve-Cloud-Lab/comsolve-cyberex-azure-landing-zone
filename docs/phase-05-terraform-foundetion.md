# 🏗️ PHASE 05 — Terraform Provider & Azure Infrastructure Foundation

<p align="center">

## ☁️ AZURE LANDING ZONE — TERRAFORM FOUNDATION

</p>

<p align="center">

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![IaC](https://img.shields.io/badge/IaC-Infrastructure%20as%20Code-success?style=for-the-badge)
![Modules](https://img.shields.io/badge/Architecture-Modular-blue?style=for-the-badge)

</p>

---

# 🎯 PHASE OBJECTIVE

Phase 05 से हमारे Azure Landing Zone project में **actual Terraform code** शुरू होगा.

इस phase में हम Terraform को Azure के साथ connect करेंगे और पहला reusable Child Module implement करेंगे.

### इस Phase में हम बनाएँगे:

| Component | Status |
|---|---|
| ⚙️ Terraform Provider | 🟢 |
| 📋 Variables | 🟢 |
| 🏷️ Locals | 🟢 |
| 📦 Resource Group Module | 🟢 |
| 🔄 `for_each` | 🟢 |
| 🏷️ Standard Tags | 🟢 |
| 🧪 Terraform Init | 🟢 |
| 🔍 Terraform Validate | 🟢 |
| 📋 Terraform Plan | 🟢 |
| ☁️ Azure Deployment | 🟢 |

---

# 🧭 TERRAFORM ARCHITECTURE

```text
                         👨‍💻 DEVELOPER
                              │
                              ▼
                       📁 Terraform Root
                              │
                    ┌─────────┴─────────┐
                    │                   │
                    ▼                   ▼
               providers.tf        variables.tf
                    │                   │
                    └─────────┬─────────┘
                              ▼
                         🏗️ main.tf
                              │
                              ▼
                     📦 Child Module
                              │
                              ▼
                    Resource Group Module
                              │
                         🔄 for_each
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
             RG-1            RG-2            RG-3
              │               │               │
              └───────────────┼───────────────┘
                              ▼
                           ☁️ Azure


# 📂 PROJECT STRUCTURE

हमारे Terraform project का current structure:

terraform/
│
├── main.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── outputs.tf
│
└── modules/
    │
    ├── resource-group/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── vnet/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── subnet/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── public-ip/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

⚙️ STEP 01 — Terraform Provider

📄 File

terraform/providers.tf
💻 Code
terraform {
  required_version = ">= 1.6.0"


  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}


provider "azurerm" {
  features {}
}


# 🧠 समझो

यह block Terraform को बताता है कि:

"हम Microsoft Azure infrastructure manage करने के लिए AzureRM provider इस्तेमाल करेंगे."

📋 STEP 02 — Terraform Variables
📄 File
terraform/variables.tf
💻 Code
variable "location" {
  description = "Azure deployment region"
  type        = string
  default     = "Central India"
}


variable "company_name" {
  description = "Company name"
  type        = string
  default     = "comsolve"
}


variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cyberex"
}


variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
🏷️ STEP 03 — Terraform Locals
📄 File
terraform/locals.tf
💻 Code
locals {


  name_prefix = "${var.company_name}-${var.project_name}-${var.environment}"


  common_tags = {
    Project     = "CyberEx"
    Company     = "ComSolve"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Infrastructure"
  }


}


🧠 इसका फायदा

हर resource में बार-बार यह लिखने की जरूरत नहीं:

ComSolve
CyberEx
Development
Terraform
Infrastructure

हम एक common tagging strategy use करेंगे.

📦 STEP 04 — Resource Group Child Module

अब हम अपना पहला reusable Terraform Child Module बनाएँगे.

📄 File
terraform/modules/resource-group/main.tf
💻 Code
resource "azurerm_resource_group" "this" {


  for_each = var.resource_groups


  name     = each.value.name
  location = each.value.location


  tags = each.value.tags
}
📋 STEP 05 — Resource Group Module Variables
📄 File
terraform/modules/resource-group/variables.tf
💻 Code
variable "resource_groups" {


  description = "Map of Azure Resource Groups"


  type = map(object({


    name     = string
    location = string
    tags     = map(string)


  }))
}
📤 STEP 06 — Resource Group Module Outputs
📄 File
terraform/modules/resource-group/outputs.tf
💻 Code
output "resource_groups" {


  description = "Created Azure Resource Groups"


  value = {


    for key, rg in azurerm_resource_group.this :


    key => {
      id       = rg.id
      name     = rg.name
      location = rg.location
    }


  }
}
🏗️ STEP 07 — Root Module

अब Parent / Root module से Child Module को call करेंगे.

📄 File
terraform/main.tf
💻 Code
module "resource_groups" {


  source = "./modules/resource-group"


  resource_groups = {


    network = {


      name     = "rg-comsolve-cyberex-network"
      location = var.location


      tags = merge(
        local.common_tags,
        {
          Layer = "Network"
        }
      )
    }


    security = {


      name     = "rg-comsolve-cyberex-security"
      location = var.location


      tags = merge(
        local.common_tags,
        {
          Layer = "Security"
        }
      )
    }


    platform = {


      name     = "rg-comsolve-cyberex-platform"
      location = var.location


      tags = merge(
        local.common_tags,
        {
          Layer = "Platform"
        }
      )
    }


  }
}
🔄 STEP 08 — for_each कैसे काम कर रहा है?

हमने तीन अलग-अलग Resource Group resource blocks नहीं बनाए.

Instead:

for_each = var.resource_groups

Terraform automatically map के प्रत्येक item के लिए Resource Group बनाएगा.

Input
network
security
platform
Terraform Result
📦 rg-comsolve-cyberex-network


📦 rg-comsolve-cyberex-security


📦 rg-comsolve-cyberex-platform
📤 STEP 09 — Root Outputs
📄 File
terraform/outputs.tf
💻 Code
output "resource_groups" {


  description = "Azure Resource Groups created by Terraform"


  value = module.resource_groups.resource_groups
}
🚀 STEP 10 — Terraform Initialization

VS Code Terminal में project root से:

cd terraform

फिर:

terraform init
Expected Result
Terraform has been successfully initialized!
🧹 STEP 11 — Terraform Format

पूरे Terraform project को format करें:

terraform fmt -recursive
🔍 STEP 12 — Terraform Validation

Configuration validate करें:

terraform validate
Expected Result
Success! The configuration is valid.
📋 STEP 13 — Terraform Plan

अब देखें Terraform क्या create करने वाला है:

terraform plan

Expected infrastructure:

📦 Resource Group
📦 Resource Group
📦 Resource Group

Total:

3 Azure Resource Groups
🚀 STEP 14 — Terraform Apply

Plan verify करने के बाद:

terraform apply

Terraform confirmation मांगेगा:

Do you want to perform these actions?

Type:

yes
☁️ EXPECTED AZURE INFRASTRUCTURE

Deployment successful होने के बाद:

☁️ Azure Subscription
│
├── 📦 rg-comsolve-cyberex-network
│
├── 📦 rg-comsolve-cyberex-security
│
└── 📦 rg-comsolve-cyberex-platform
🏷️ RESOURCE NAMING STANDARD

इस project में naming convention:

<company>-<project>-<environment>-<resource>

Example:

comsolve-cyberex-dev

Resource Group:

rg-comsolve-cyberex-network

Future VNet:

vnet-comsolve-cyberex-dev

Future Subnet:

snet-comsolve-cyberex-web

Future Public IP:

pip-comsolve-cyberex-appgw
🏷️ TAGGING STANDARD

हर Azure resource पर common tags maintain किए जाएंगे:

Project
Company
Environment
ManagedBy
Owner
Layer

Example:

tags = {
  Project     = "CyberEx"
  Company     = "ComSolve"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "Infrastructure"
  Layer       = "Network"
}
🧠 WHAT WE LEARNED
🟣 Terraform Provider

Azure resources manage करने के लिए provider configure किया.

🟢 Variables

Environment और project-specific values को variables में रखा.

🔵 Locals

Common naming और tagging को centralize किया.

🟠 Child Module

Resource Group के लिए reusable module बनाया.

🔄 for_each

एक ही Terraform resource definition से multiple Resource Groups create किए.

🏗️ Parent → Child Architecture
Root Module
     │
     ▼
Resource Group Module
     │
     ▼
for_each
     │
 ┌───┼───┐
 ▼   ▼   ▼
RG1 RG2 RG3
🔐 SECURITY NOTE

इस phase में कोई password, secret या Azure credential Terraform code में hard-code नहीं किया गया है.

❌ Password
❌ Client Secret
❌ API Key
❌ Access Key
❌ Private Key

Authentication और secure state management को आगे dedicated phases में implement किया जाएगा.

📊 PHASE 05 CHECKLIST
Component	Status
⚙️ AzureRM Provider	✅
📋 Variables	✅
🏷️ Locals	✅
📦 Resource Group Module	✅
🔄 for_each	✅
🏷️ Resource Tags	✅
📤 Outputs	✅
🧪 Terraform Init	⏳
🔍 Terraform Validate	⏳
📋 Terraform Plan	⏳
☁️ Terraform Apply	⏳
🏁 PHASE 05 STATUS
<p align="center">
🟢 TERRAFORM FOUNDATION STARTED
Parent Module + Child Module + for_each
</p>
⏭️ NEXT PHASE
🌐 Phase 06 — Azure VNet, Subnets & Network Foundation

Next phase में हम implement करेंगे:

🌐 Virtual Network
        │
        ├── 🟦 Web Subnet
        ├── 🟩 Application Subnet
        ├── 🟨 Data Subnet
        ├── 🟪 Management Subnet
        └── 🟥 Security Subnet

इसके बाद:

🌍 Public IP
        ↓
🚪 Azure Bastion
        ↓
🌐 Application Gateway
        ↓
🛡️ Network Security
<p align="center">
🏗️ BUILD → SECURE → AUTOMATE → SCALE
</p> ```
📁 Phase 05 में ये files भरनी हैं

तुम्हारे existing structure में नई file बनाने की जरूरत नहीं है। बस इन files में ऊपर का code डालना है:

terraform/
│
├── main.tf                 ← STEP 07
├── providers.tf            ← STEP 01
├── variables.tf            ← STEP 02
├── locals.tf               ← STEP 03
├── outputs.tf              ← STEP 09
│
└── modules/
    └── resource-group/
        ├── main.tf        ← STEP 04
        ├── variables.tf   ← STEP 05
        └── outputs.tf     ← STEP 06