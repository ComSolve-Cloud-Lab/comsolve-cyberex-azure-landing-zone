# 🔎 Phase 25.06 — Terraform CD Pipeline Failure Investigation

<p align="center">

![Terraform](https://img.shields.io/badge/Terraform-Infrastructure-blue?logo=terraform)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CD-black?logo=githubactions)
![Azure](https://img.shields.io/badge/Azure-Cloud-blue?logo=microsoftazure)
![Troubleshooting](https://img.shields.io/badge/Status-Investigation-orange)

</p>

---

## 🎯 Investigation Objective

इस investigation का objective Terraform CD Pipeline के बार-बार fail होने का **actual root cause identify करना** है।

अभी कोई code change या state modification नहीं किया जाएगा।

पहले:

```text
Failure
   ↓
Evidence
   ↓
Possible Root Causes
   ↓
Terraform Dependency Graph
   ↓
Code Verification
   ↓
Root Cause Confirmation
   ↓
Fix
   ↓
Validation
```

---

# 🧩 1. Current CD Architecture

Current deployment flow:

```text
GitHub main
     │
     ▼
Terraform Plan
     │
     ▼
Saved tfplan Artifact
     │
     ▼
Comsolve_production
     │
     ▼
Deployment Approval
     │
     ▼
Terraform Apply
     │
     ▼
Azure Resources
```

Terraform Apply के अंदर expected resource flow:

```text
Resource Groups
      │
      ├──────────────┐
      ▼              ▼
     VNet           NSG
      │
      ▼
    Subnets
      │
      ▼
 Other Network Resources
```

---

# 🔴 2. First Failure — ResourceGroupNotFound

पहले Terraform Apply में error आया:

```text
ResourceGroupNotFound:

Resource group
'rg-comsolve-cyberex-network'
could not be found.
```

Affected resources:

```text
module.nsg.azurerm_network_security_group.this

module.vnet.azurerm_virtual_network.Vnet
```

दोनों resources:

```text
Resource Group:
rg-comsolve-cyberex-network
```

में create होने थे।

### Initial Observation

इसका मतलब उस समय Azure में required Resource Group उपलब्ध नहीं था।

लेकिन यहाँ दो possibilities हैं:

### Possibility A — Correct Dependency

Terraform dependency correctly defined थी:

```text
Resource Group
      ↓
VNet / NSG
```

तो VNet और NSG को RG बनने के बाद ही create होना चाहिए।

### Possibility B — Missing Dependency

अगर VNet और NSG में Resource Group का नाम केवल hardcoded string से दिया गया है:

```hcl
resource_group_name = "rg-comsolve-cyberex-network"
```

और Resource Group module से कोई Terraform reference नहीं है, तो Terraform dependency graph में direct relationship दिखाई नहीं दे सकती।

इस situation में Terraform theoretically resources को parallel में schedule कर सकता है:

```text
             ┌──→ VNet
Terraform ───┤
             ├──→ NSG
             │
             └──→ Resource Group
```

जिससे possible race condition हो सकती है:

```text
VNet / NSG
    ↓
Azure API
    ↓
Resource Group अभी available नहीं
    ↓
404 ResourceGroupNotFound
```

⚠️ यह अभी **hypothesis** है, confirmed root cause नहीं।

---

# 🔴 3. Second Failure — Resource Already Exists

पहली failed deployment के बाद:

```text
re-run failed job
```

चलाया गया।

अब नया error आया:

```text
Error:

a resource with the ID
"/subscriptions/.../resourceGroups/rg-comsolve-cyberex-network"

already exists
```

इसी तरह:

```text
rg-comsolve-cyberex-network
rg-comsolve-cyberex-platform
rg-comsolve-cyberex-security
```

Azure में मौजूद हैं।

लेकिन Terraform कह रहा है:

```text
to be managed via Terraform
this resource needs to be imported into the State
```

---

# 🧠 4. What This Tells Us

अब situation यह है:

```text
                    Azure
                     │
        ┌────────────┴────────────┐
        │                         │
   Resource Groups            Other Resources
        │
        ├── network              ?
        ├── platform             ?
        └── security             ?
```

Azure में Resource Groups मौजूद हैं।

लेकिन Terraform इन्हें:

```text
Terraform State
```

में tracked resource के रूप में नहीं पहचान रहा।

इसलिए Terraform दो अलग worlds देख रहा है:

```text
Azure Reality
────────────────────────
RG exists ✅


Terraform State
────────────────────────
RG not tracked ❌
```

Result:

```text
Terraform
   ↓
Create RG
   ↓
Azure
   ↓
Already Exists
   ↓
Error
```

---

# ⚠️ 5. Important Observation

यह केवल "Resource Already Exists" problem नहीं है।

यह एक **State + Dependency + Partial Apply** investigation बन चुकी है।

Possible sequence:

```text
Initial Apply
     │
     ▼
Terraform starts deployment
     │
     ├── Resource Groups
     │
     ├── VNet
     │
     └── NSG
           │
           ▼
      Dependency issue?
           │
           ▼
     404 ResourceGroupNotFound
           │
           ▼
      Apply fails
           │
           ▼
Some Azure resources may already exist
           │
           ▼
Re-run Apply
           │
           ▼
Terraform sees RG absent from State
           │
           ▼
Terraform tries Create
           │
           ▼
Azure says Already Exists
```

लेकिन यहाँ एक चीज़ **हमें verify करनी ही होगी**:

> अगर Terraform ने Resource Group successfully create किया था, तो Terraform State में वह क्यों नहीं आया?

इसके कई कारण हो सकते हैं:

* partial/failed apply behavior
* state backend/state write issue
* plan generated against different state
* state configuration problem
* resource manually existed
* module/resource addressing change
* state reset/loss
* गलत backend/state
* parallel resource/dependency issue के साथ state behavior

इसलिए अभी सीधे `terraform import` करना भी premature है।

---

# 🔍 6. Main Hypothesis

हमारी primary hypothesis:

```text
Resource Group
      │
      │ Terraform dependency
      ▼
VNet / NSG
```

यह dependency शायद Terraform code में properly expressed नहीं है।

### Bad Dependency Pattern

```hcl
module "resource_groups" {
  ...
}

module "vnet" {

  source = "./modules/vnet"

  resource_group_name = "rg-comsolve-cyberex-network"

}
```

यहाँ Terraform को यह सिर्फ एक string दिखाई दे सकती है:

```text
"rg-comsolve-cyberex-network"
```

उसे यह जरूरी नहीं पता कि:

```text
module.resource_groups
```

पहले execute होना चाहिए।

---

# ✅ 7. Preferred Dependency Pattern

Best practice:

```hcl
module "resource_groups" {
  ...
}
```

और VNet module को RG module के output से connect करना:

```hcl
module "vnet" {

  source = "./modules/vnet"

  resource_group_name =
    module.resource_groups.resource_group_names["network"]

}
```

अब Terraform dependency graph समझ सकता है:

```text
module.resource_groups
          │
          │ output reference
          ▼
      module.vnet
```

और:

```text
module.resource_groups
          │
          ├──────────────► VNet
          │
          └──────────────► NSG
```

---

# 🧠 8. Terraform Dependency Principle

हमारा golden rule:

> **Terraform में dependency को `depends_on` से force करने से पहले resource/module reference से dependency establish करनी चाहिए।**

Preferred:

```text
Resource A output
      ↓
Resource B input
```

Instead of immediately doing:

```hcl
depends_on = [
  module.resource_groups
]
```

### क्यों?

क्योंकि explicit reference Terraform को actual dependency बताता है।

`depends_on` को तब use करना चाहिए जब dependency Terraform expressions से naturally establish नहीं हो रही हो।

---

# 🔎 9. What We Need to Verify in Code

अब code में निम्न चीजें verify करनी हैं:

### 9.1 Resource Group Module

Check:

```text
modules/resource-group/main.tf
```

देखना है:

```hcl
resource "azurerm_resource_group" "Rgs"
```

कैसे create हो रहा है।

---

### 9.2 Resource Group Outputs

Check:

```text
modules/resource-group/outputs.tf
```

देखना है कि RG names/IDs/location outputs available हैं या नहीं।

Expected concept:

```text
resource_group_name
resource_group_id
location
```

---

### 9.3 Root main.tf

सबसे important:

```text
main.tf
```

देखना है:

```text
module "resource_groups"
module "vnet"
module "nsg"
module "subnet"
```

इनके बीच dependency कैसे बनाई गई है।

---

### 9.4 VNet Module

Check:

```text
modules/vnet/main.tf
```

विशेष रूप से:

```hcl
resource_group_name = ?
```

अगर यहाँ:

```hcl
resource_group_name = var.resource_group_name
```

है तो root module से variable कहाँ से आ रहा है, यह देखना जरूरी है।

---

### 9.5 NSG Module

Check:

```text
modules/nsg/main.tf
```

विशेष रूप से:

```hcl
resource_group_name = ?
```

---

### 9.6 Backend Configuration

Check:

```text
providers.tf
```

और backend configuration:

```hcl
terraform {
  backend "azurerm" {
    ...
  }
}
```

यह बहुत important है क्योंकि current issue में:

```text
Azure Resource
        ≠
Terraform State
```

का mismatch दिखाई दे रहा है।

---

# 🧪 10. Investigation Questions

Code देखकर हमें इन questions के answers चाहिए:

| Question                                                          | Status |
| ----------------------------------------------------------------- | ------ |
| Resource Groups Terraform से create हो रहे हैं?                   | ❓      |
| VNet Terraform module से create हो रहा है?                        | ✅      |
| NSG Terraform module से create हो रहा है?                         | ✅      |
| VNet → RG dependency explicit/reference based है?                 | ❓      |
| NSG → RG dependency explicit/reference based है?                  | ❓      |
| Subnet → VNet dependency correct है?                              | ❓      |
| Terraform backend correct है?                                     | ❓      |
| Existing RG Terraform state में है?                               | ❓      |
| First failed Apply में RG वास्तव में Terraform ने create किया था? | ❓      |
| Plan और Apply same state/backend use कर रहे हैं?                  | ❓      |

---

# 🧭 11. Investigation Flow

हम अब यह process follow करेंगे:

```text
                FAILURE
                   │
                   ▼
        ResourceGroupNotFound
                   │
                   ▼
       Dependency Investigation
                   │
                   ▼
          Terraform Code Review
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
   Dependency OK         Dependency Missing
        │                     │
        ▼                     ▼
 State Investigation      Fix Dependency
        │                     │
        └──────────┬──────────┘
                   ▼
             Confirm Root Cause
                   │
                   ▼
             State Alignment
                   │
                   ▼
             Terraform Plan
                   │
                   ▼
             Terraform Apply
                   │
                   ▼
            Azure Validation
```

---

# 🚫 12. What We Will NOT Do Yet

जब तक root cause confirm नहीं होता:

```text
❌ Resource Groups delete नहीं करेंगे
❌ Terraform State manually delete नहीं करेंगे
❌ blindly terraform import नहीं करेंगे
❌ depends_on randomly add नहीं करेंगे
❌ YAML/CD architecture change नहीं करेंगे
❌ existing Azure resources destroy नहीं करेंगे
❌ बार-बार Apply नहीं चलाएँगे
```

पहले evidence।

---

# 🎯 13. Current Working Theory

Current strongest theory:

```text
Resource Groups
      │
      │
      ├───────────────┐
      │               │
      ▼               ▼
     VNet            NSG
```

होना चाहिए।

लेकिन अगर code में:

```text
VNet ──X── Resource Group
NSG  ──X── Resource Group
```

dependency properly expressed नहीं है, तो Terraform इन्हें independent resources की तरह schedule कर सकता है।

इससे पहला:

```text
404 ResourceGroupNotFound
```

explain हो सकता है।

फिर failed/partial deployment के बाद:

```text
Azure RG exists
Terraform State doesn't contain RG
```

के कारण दूसरा:

```text
Resource already exists
Import required
```

error आ सकता है।

**लेकिन यह अभी hypothesis है। Code और state configuration देखकर ही इसे Root Cause घोषित करेंगे।**

---

# 🏁 14. Next Action

अब हमारा next step केवल:

```text
CODE REVIEW
```

है।

Required files:

```text
main.tf

providers.tf

modules/resource-group/main.tf
modules/resource-group/outputs.tf

modules/vnet/main.tf
modules/vnet/variables.tf

modules/nsg/main.tf
modules/nsg/variables.tf

backend configuration
```

इसके बाद हम पहले Terraform dependency graph mentally/technically verify करेंगे:

```text
RG
 ↓
VNet
 ↓
Subnet

RG
 ↓
NSG
```

फिर decide करेंगे:

```text
ROOT CAUSE CONFIRMED ✅
```

और उसके बाद ही:

```text
FIX → STATE ALIGNMENT → PLAN → APPLY
```

करेंगे।

---

### 🍼 Phase 25.06 — Terraform CD Failure Resolution

**Step 01 — Current Code → Dependency Check**

**🎯 अभी सिर्फ 2–4 छोटे steps**

Step 1️⃣ — Project में जाना

अपने local project में जाओ:

cd D:\Projects3\comsolve-cyberex-azure-landing-zone

फिर:

git status

अभी कुछ modify मत करना।

Step 2️⃣ — Actual Current Code निकालना

हमें सबसे पहले जो अभी सच में code है, वही देखना है।

VS Code में ये files खोलो:

comsolve-cyberex-azure-landing-zone
│
├── main.tf
├── providers.tf
│
└── terraform
    └── modules
        ├── resource-group
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        │
        ├── vnet
        │   ├── main.tf
        │   └── variables.tf
        │
        └── nsg
            ├── main.tf
            └── variables.tf

⚠️ अगर तुम्हारे project में structure थोड़ा अलग है तो कोई problem नहीं।

Step 3️⃣ — पहले सिर्फ ये 3 चीजें मुझे दो

सबसे पहले मुझे पूरा project नहीं चाहिए।

A. Root main.tf
main.tf
B. Resource Group
terraform/modules/resource-group/main.tf
C. VNet + NSG
terraform/modules/vnet/main.tf
terraform/modules/nsg/main.tf

इन 4 files का current code यहाँ paste/upload कर दे।

🔎 Step 4️⃣ — मैं क्या check करूँगा?

मैं code में specifically ये देखूँगा:

Resource Group
      │
      │ dependency ?
      ▼
     VNet

Resource Group
      │
      │ dependency ?
      ▼
     NSG

और फिर तुम्हें साफ दिखाऊँगा:

❌ Current Code
RG ──X──> VNet
RG ──X──> NSG

या

✅ Current Code
RG
├──→ VNet
└──→ NSG

फिर अगर dependency missing हुई तो हम उसी जगह modified code बनाएँगे:

CURRENT CODE
     ↓
   CHANGE
     ↓
UPDATED CODE

और उसके बाद ही अगला baby step करेंगे।

# 🚫 अभी ये commands मत चलाना

terraform import

terraform apply

terraform state rm

terraform state push

और depends_on भी अभी randomly add नहीं करना है।

---

# 🚀 Terraform Existing Infrastructure State Synchronization & Import Troubleshooting

<p align="center">

![Terraform](https://img.shields.io/badge/Terraform-1.14.6-7B42BC?logo=terraform)
![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoftazure)
![AzureRM](https://img.shields.io/badge/AzureRM-5.3.0-0078D4)
![Backend](https://img.shields.io/badge/Backend-Azure%20Storage-0078D4)
![Status](https://img.shields.io/badge/Status-Resolved-success)

</p>

---

## 🎯 1. Problem Statement

हमारे Terraform Landing Zone project में initial problem यह थी कि Terraform configuration Azure infrastructure को manage करने की कोशिश कर रही थी, लेकिन Azure में कई resources पहले से मौजूद थे।

मुख्य existing resources:

* Resource Groups
* Virtual Network
* Subnets
* Network Security Group
* Network Interface
* Subnet ↔ NSG Associations

Terraform के पास इन existing resources की सही **state information** नहीं थी।

इसका result यह था कि:

```text
Azure Infrastructure
        ↓
Resources पहले से मौजूद
        ↓
Terraform Configuration भी मौजूद
        ↓
Terraform State में resources missing
        ↓
terraform plan
        ↓
Terraform ने resources को "to be created" माना
```

इसका सही solution resources को delete/recreate करना नहीं था।

सही approach थी:

```text
Existing Azure Resources
        ↓
Terraform Import
        ↓
Terraform State
        ↓
terraform plan
        ↓
No Changes
```

---

# 🧭 2. पूरा Troubleshooting Journey

हमारा troubleshooting sequence broadly यह रहा:

```text
01. Dependency / Output Issue
        ↓
02. Root output.tf correction
        ↓
03. VNet / NIC Resource Group reference correction
        ↓
04. Azure Storage Backend setup
        ↓
05. Remote Terraform State configuration
        ↓
06. Initial Resource Import
        ↓
07. Remaining Existing Resources identification
        ↓
08. VNet Import
        ↓
09. Subnet Imports
        ↓
10. NSG Import
        ↓
11. NIC Import
        ↓
12. Subnet ↔ NSG Association Imports
        ↓
13. terraform state list
        ↓
14. terraform plan
        ↓
15. No Changes
```

---

# 🔴 3. Initial Issue — Dependency / Output Problem

## समस्या क्या थी?

Root module में child modules के outputs के through resources एक-दूसरे पर depend कर रहे थे।

Example:

```hcl
module "resource_groups" {
  source = "./modules/resource-group"
}
```

और बाद में दूसरे modules को Resource Group name चाहिए था।

इसलिए child module का output correctly defined होना जरूरी था।

---

## ❌ Problem

`output.tf` initially blank था।

इसका मतलब:

```text
Resource Group Module
        ↓
Resource Group create
        ↓
Output उपलब्ध नहीं
        ↓
Root module को RG name नहीं मिला
        ↓
Dependency / Reference problem
```

---

# 🟢 4. Fix — Resource Group Output Add किया

Resource Group module में output add किया गया:

```hcl
output "resource_group_names" {
  description = "Map of Resource Group names"

  value = {
    for key, rg in azurerm_resource_group.Rgs :
    key => rg.name
  }
}
```

इसका purpose:

```text
network   → rg-comsolve-cyberex-network
security  → rg-comsolve-cyberex-security
platform  → rg-comsolve-cyberex-platform
```

को root module में expose करना था।

---

# 🔴 5. VNet और NIC में Resource Group Reference Issue

इसके बाद VNet और NIC configuration में Resource Group reference को correct किया गया।

### VNet

```hcl
resource_group_name = module.resource_groups.resource_group_names["network"]
```

### NIC

NIC को भी correct network Resource Group reference दिया गया।

Root module का concept:

```text
Resource Group Module
        ↓
resource_group_names["network"]
        ↓
VNet
        ↓
Subnet
        ↓
NIC
```

इससे Terraform dependency chain clear हुई।

---

# 🟡 6. फिर भी Problem क्यों रही?

यहाँ actual important point सामने आया:

**Configuration सही होने के बावजूद Azure resources पहले से मौजूद थे।**

Terraform configuration कह रही थी:

```text
"मुझे यह resource चाहिए"
```

लेकिन Terraform State कह रही थी:

```text
"मेरे state में यह resource मौजूद नहीं है"
```

Terraform के लिए इसका मतलब था:

```text
Configuration:
resource चाहिए

State:
resource नहीं है

Result:
CREATE करने की कोशिश
```

लेकिन Azure में resource पहले से था।

इसलिए हमें **Terraform Import** की जरूरत पड़ी।

---

# ☁️ 7. Remote Terraform State की जरूरत क्यों पड़ी?

Terraform state को local machine पर रखने के बजाय हमने Azure Storage Account में remote backend configure करने का decision लिया।

Architecture:

```text
Developer / GitHub Actions
          │
          ▼
      Terraform
          │
          ▼
   Azure Storage Backend
          │
          ▼
      tfstate file
```

इससे:

* State centralized रहती है
* CI/CD pipeline same state use करती है
* Local machine की state पर dependency कम होती है
* Team environment में state sharing possible होती है
* Terraform state को remote backend से manage किया जा सकता है

---

# 🟢 8. Azure Storage Account बनाया

हमने Terraform state के लिए Resource Group, Storage Account और Blob Container तैयार किया।

Known backend:

```text
Resource Group:
rg-comsolve-cyberex-network

Storage Account:
cyberexterraformstate

Container:
tfstate

State Key:
cyberex-landing-zone.tfstate
```

---

## Azure CLI Commands

### Resource Group

```powershell
az group create --name rg-comsolve-cyberex-network --location centralindia
```

**काम:** Azure में Resource Group create/check करता है।

---

### Storage Account

```powershell
az storage account create --name cyberexterraformstate --resource-group rg-comsolve-cyberex-network --location centralindia --sku Standard_LRS
```

**काम:** Terraform remote state रखने के लिए Azure Storage Account बनाता है।

---

### Storage Container

```powershell
az storage container create --name tfstate --account-name cyberexterraformstate --auth-mode login
```

**काम:** Storage Account के अंदर `tfstate` Blob Container बनाता है।

---

# 🟢 9. Terraform Remote Backend Configuration

`providers.tf` में backend configure किया गया:

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-comsolve-cyberex-network"
    storage_account_name = "cyberexterraformstate"
    container_name       = "tfstate"
    key                  = "cyberex-landing-zone.tfstate"
  }
}

provider "azurerm" {
  features {}
}
```

---

# 🔧 10. Backend Initialize / Reconfigure

### Command

```powershell
terraform init -reconfigure
```

**काम:** Terraform को configured Azure remote backend के साथ initialize/reconfigure करता है।

Expected:

```text
Terraform has been successfully initialized!
```

---

# 🔴 11. Provider Cache / Initialization Issue

एक point पर provider installation/cache related issue आया।

Terraform ने AzureRM provider को correctly use नहीं किया था।

---

## Fix

```powershell
terraform init -upgrade
```

**काम:** Required providers को upgrade/check करके Terraform working directory को initialize करता है।

इसके बाद:

```powershell
terraform validate
```

**काम:** Terraform configuration की syntax और internal configuration validity check करता है।

Result:

```text
Success! The configuration is valid.
```

---

# 🔴 12. First Terraform Import Problem

अब हमने existing Azure resources को Terraform State में लाने का काम शुरू किया।

Initial focus था:

```text
Resource Groups
```

क्योंकि ये resources Azure में पहले से मौजूद थे।

---

# 📦 13. `imports.tf` क्यों बनाया?

`imports.tf` का purpose existing resources के Terraform import को document/manage करना था।

Important:

> `imports.tf` खुद Azure resource create नहीं करता।

Import का purpose है:

```text
Azure Existing Resource
        ↓
Terraform Import
        ↓
Terraform State
```

---

# 🟢 14. Initial Resource Group Imports

सबसे पहले 3 Resource Groups import किए गए:

```text
network
security
platform
```

Conceptually import blocks:

```hcl
import {
  to = module.resource_groups.azurerm_resource_group.Rgs["network"]

  id = "/subscriptions/<subscription-id>/resourceGroups/rg-comsolve-cyberex-network"
}

import {
  to = module.resource_groups.azurerm_resource_group.Rgs["security"]

  id = "/subscriptions/<subscription-id>/resourceGroups/rg-comsolve-cyberex-security"
}

import {
  to = module.resource_groups.azurerm_resource_group.Rgs["platform"]

  id = "/subscriptions/<subscription-id>/resourceGroups/rg-comsolve-cyberex-platform"
}
```

---

# ⚠️ 15. Import का सबसे Important Concept

यह समझना बहुत जरूरी है:

### Import क्या करता है?

```text
Azure Resource
      ↓
Resource already exists
      ↓
Terraform State में उसका ID register
```

### Import क्या नहीं करता?

```text
❌ Azure resource create नहीं करता
❌ Existing resource modify नहीं करता
❌ Resource configuration automatically नहीं लिखता
❌ Terraform code generate नहीं करता
```

Import mainly Terraform को बताता है:

> "यह Azure resource पहले से मौजूद है और इसे इस Terraform resource address के साथ manage करो।"

---

# 🔴 16. सिर्फ RG Import करने से Problem क्यों पूरी solve नहीं हुई?

क्योंकि Terraform project में केवल Resource Groups ही नहीं थे।

Configuration में और भी resources थे:

```text
Resource Groups
VNet
Subnets
NSG
NIC
Subnet ↔ NSG Associations
```

लेकिन Azure में ये existing थे और Terraform State में missing थे।

इसलिए धीरे-धीरे identify हुआ कि हमें सभी existing resources को state में import करना पड़ेगा।

---

# 🔎 17. `terraform state list` क्यों इस्तेमाल किया?

### Command

```powershell
terraform state list
```

**काम:** Current Terraform State में कौन-कौन से resources registered हैं, उनकी पूरी list दिखाता है।

यह हमारे troubleshooting का सबसे important verification command था।

---

# 🟢 18. VNet Import

Azure में existing VNet:

```text
vnet-comsolve-cyberex-dev
```

Terraform State में missing था।

इसलिए VNet import किया गया।

State address:

```text
module.vnet.azurerm_virtual_network.Vnet
```

---

# 🟢 19. Subnet Imports

इसके बाद 5 existing Subnets identify किए गए:

```text
snet-management
snet-web
snet-data
snet-application
snet-security
```

Terraform State addresses:

```text
module.subnets.azurerm_subnet.Subnets["management"]
module.subnets.azurerm_subnet.Subnets["web"]
module.subnets.azurerm_subnet.Subnets["data"]
module.subnets.azurerm_subnet.Subnets["application"]
module.subnets.azurerm_subnet.Subnets["security"]
```

---

# 🟢 20. NSG Import

Existing NSG:

```text
cyberex-nsg
```

Terraform State address:

```text
module.nsg.azurerm_network_security_group.this
```

यह भी import किया गया।

---

# 🟢 21. NIC Import

Existing NIC:

```text
nic-comsolve-cyberex-web
```

Terraform State address:

```text
module.nics.azurerm_network_interface.Nic
```

NIC को भी Terraform State में import किया गया।

---

# 🔥 22. सबसे Important — Subnet ↔ NSG Association Import

यहाँ सबसे ज्यादा confusion और errors आए।

हमारे Terraform code में:

```hcl
resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {

  for_each = module.subnets.subnet_ids

  subnet_id                 = each.value
  network_security_group_id = module.nsg.id
}
```

इसका मतलब:

```text
5 Subnets
   +
1 NSG
   ↓
5 Associations
```

Therefore Terraform State में 5 association resources चाहिए थे।

---

# ❌ 23. Association Import में हुई मुख्य गलती

पहले गलत assumption था कि import ID:

```text
subnet_id|nsg_id
```

होगा।

यह गलत था।

यह syntax दूसरे association resource types में मिलता है, जैसे:

```text
Network Interface ↔ NSG
```

लेकिन:

```text
Subnet ↔ NSG
```

के लिए AzureRM provider का import ID **Subnet Resource ID** है।

इसलिए सही तरीका:

```text
Subnet Resource ID
        ↓
terraform import
        ↓
Subnet ↔ NSG Association
```

---

# ✅ 24. Correct Association Import

उदाहरण:

```powershell
terraform import 'azurerm_subnet_network_security_group_association.subnet_nsg["data"]' '/subscriptions/7cf9c45e-0a1e-4828-9c98-3e8f25397732/resourceGroups/rg-comsolve-cyberex-network/providers/Microsoft.Network/virtualNetworks/vnet-comsolve-cyberex-dev/subnets/snet-data'
```

यहाँ import ID केवल:

```text
/subscriptions/.../subnets/snet-data
```

है।

---

# 🧠 25. Association Import को याद रखने का आसान तरीका

| Association Type          | Import ID Concept      |
| ------------------------- | ---------------------- |
| Subnet ↔ NSG              | **Subnet Resource ID** |
| NIC ↔ NSG                 | NIC ID + NSG ID format |
| हमारी current association | **Subnet ID**          |

इसलिए हमारी current resource:

```text
azurerm_subnet_network_security_group_association
```

के लिए:

```text
❌ subnet_id|nsg_id

✅ subnet_id
```

---

# 🟢 26. Final State Verification

सभी imports के बाद हमने:

```powershell
terraform state list
```

चलाया।

Final state में यह सब दिखाई दिया:

```text
azurerm_subnet_network_security_group_association.subnet_nsg["application"]
azurerm_subnet_network_security_group_association.subnet_nsg["data"]
azurerm_subnet_network_security_group_association.subnet_nsg["management"]
azurerm_subnet_network_security_group_association.subnet_nsg["security"]
azurerm_subnet_network_security_group_association.subnet_nsg["web"]

module.nics.azurerm_network_interface.Nic

module.nsg.azurerm_network_security_group.this

module.resource_groups.azurerm_resource_group.Rgs["network"]
module.resource_groups.azurerm_resource_group.Rgs["platform"]
module.resource_groups.azurerm_resource_group.Rgs["security"]

module.subnets.azurerm_subnet.Subnets["application"]
module.subnets.azurerm_subnet.Subnets["data"]
module.subnets.azurerm_subnet.Subnets["management"]
module.subnets.azurerm_subnet.Subnets["security"]
module.subnets.azurerm_subnet.Subnets["web"]

module.vnet.azurerm_virtual_network.Vnet
```

इसका मतलब:

```text
3 Resource Groups       ✅
1 VNet                  ✅
5 Subnets               ✅
1 NSG                   ✅
1 NIC                   ✅
5 Subnet/NSG Associations ✅
```

---

# 🎯 27. Final `terraform plan`

सबसे important verification:

```powershell
terraform plan
```

Result:

```text
No changes.
Your infrastructure matches the configuration.
```

यह हमारा final success point था।

---

# 🧠 28. `No changes` का Actual Meaning

इस result को ऐसे समझो:

```text
Terraform Configuration
        │
        │
        ▼
Terraform State
        │
        │
        ▼
Azure Infrastructure
```

और Terraform को कोई unmanaged difference नहीं मिला।

Therefore:

```text
Plan:
0 to add
0 to change
0 to destroy
```

इसका मतलब यह नहीं है कि हमने Azure resources दोबारा बनाए।

बल्कि:

```text
Azure resources पहले से थे
        ↓
हमने Terraform State में import किए
        ↓
Terraform ने configuration से match किया
        ↓
No changes
```

---

# 🔍 29. क्या हमने Drift Check किया?

हाँ, `terraform plan` ने configuration और current infrastructure/state के बीच difference detect करने का काम किया।

लेकिन terminology सही रखना जरूरी है:

### Import ≠ Drift Fix

Import का purpose:

```text
Existing Resource
        ↓
Terraform State में register
```

Drift का मतलब:

```text
Terraform State / Configuration
        ↓
Azure में actual resource अलग हो गया
```

उदाहरण:

```text
Terraform expects:
NSG = cyberex-nsg

Azure actual:
NSG configuration manually changed

        ↓

terraform plan

        ↓

Difference / Drift दिखाई दे सकता है
```

इसलिए हमारे case में primary problem **missing state/import** थी, न कि केवल drift।

---

### 🛠️ Step 30 — Terraform Commands Complete Reference Table

| Command | हमने क्यों चलाया? | कब use करना है? | Action Category |
| :--- | :--- | :--- | :-: |
| `terraform init` | Terraform working directory initialize करना | New Terraform project / Backend change | ![Init](https://img.shields.io/badge/Setup-INITIALIZE-blue?style=flat-square) |
| `terraform init -upgrade` | Provider version/cache refresh करना | Provider installation / Update issue | ![Upgrade](https://img.shields.io/badge/Setup-UPGRADE-blue?style=flat-square) |
| `terraform init -reconfigure` | Backend configuration को reinitialize करना | Backend change / Reconfiguration | ![Reconfig](https://img.shields.io/badge/Setup-RECONFIGURE-blue?style=flat-square) |
| `terraform validate` | Terraform code valid है या नहीं चेक करना | Code change के बाद CI/CD में | ![Validate](https://img.shields.io/badge/Validation-PASSED-brightgreen?style=flat-square) |
| `terraform fmt` | Terraform files auto-format करना | Code formatting phase | ![Format](https://img.shields.io/badge/Code_Quality-FORMAT-informational?style=flat-square) |
| `terraform fmt -check -recursive` | Formatting check करना बिना modify किए | CI/CD pipeline validation gate | ![Lint Check](https://img.shields.io/badge/CI_Gate-LINT_CHECK-yellow?style=flat-square) |
| `terraform plan` | Configuration vs state/infrastructure difference देखना | Apply से पहले हमेशा | ![Plan](https://img.shields.io/badge/Dry_Run-PLAN_PREVIEW-orange?style=flat-square) |
| `terraform apply` | Infrastructure changes deploy करना | Approved deployment stage | ![Deploy](https://img.shields.io/badge/Execution-APPLY_DEPLOY-brightgreen?style=flat-square) |
| `terraform state list` | State में registered resources देखना | Import / State troubleshooting | ![State List](https://img.shields.io/badge/State-LIST_RESOURCES-purple?style=flat-square) |
| `terraform import` | Existing Azure resource को state में register करना | Existing unmanaged resources adopt करना | ![Import](https://img.shields.io/badge/State-IMPORT_RESOURCE-purple?style=flat-square) |
| `terraform state show <address>` | State में particular resource की details देखना | Specific resource verification | ![State Show](https://img.shields.io/badge/State-INSPECT_RESOURCE-purple?style=flat-square) |
| `terraform state pull` | Remote state JSON readout pull करना | Advanced state troubleshooting | ![State Pull](https://img.shields.io/badge/State-PULL_REMOTE-purple?style=flat-square) |
| `terraform show` | Terraform state/plan readable format में देखना | Detailed state & execution plan inspection | ![Inspect](https://img.shields.io/badge/Analysis-READABLE_STATE-blueviolet?style=flat-square) |                |

---

# ⭐ 31. Import Commands — कब और क्यों?

Import को सबसे ज्यादा ध्यान से समझना है।

## Normal New Resource

अगर resource Terraform से नया बनना है:

```text
terraform code
      ↓
terraform plan
      ↓
terraform apply
      ↓
Azure resource created
```

---

## Existing Resource

अगर resource Azure में पहले से मौजूद है:

```text
Azure resource already exists
      ↓
Terraform code exists
      ↓
Terraform state missing
      ↓
terraform import
      ↓
Terraform state updated
      ↓
terraform plan
```

---

# 📋 32. हमारे Project में Import Mapping

### 📋 Step 32 — Project Resource Import Mapping Reference

| Azure Resource | Terraform Address | Import क्यों किया? | Action Type |
| :--- | :--- | :--- | :-: |
| **`rg-comsolve-cyberex-network`** | `module.resource_groups.azurerm_resource_group.Rgs["network"]` | Existing Resource Group adoption | ![Imported](https://img.shields.io/badge/State-IMPORTED-purple?style=flat-square) |
| **`rg-comsolve-cyberex-security`** | `module.resource_groups.azurerm_resource_group.Rgs["security"]` | Existing Resource Group adoption | ![Imported](https://img.shields.io/badge/State-IMPORTED-purple?style=flat-square) |
| **`rg-comsolve-cyberex-platform`** | `module.resource_groups.azurerm_resource_group.Rgs["platform"]` | Existing Resource Group adoption | ![Imported](https://img.shields.io/badge/State-IMPORTED-purple?style=flat-square) |
| **`vnet-comsolve-cyberex-dev`** | `module.vnet.azurerm_virtual_network.Vnet` | Existing VNet adoption | ![Imported](https://img.shields.io/badge/State-IMPORTED-purple?style=flat-square) |
| **`snet-management`** | `module.subnets.azurerm_subnet.Subnets["management"]` | Existing subnet adoption | ![Imported](https://img.shields.io/badge/State-IMPORTED-purple?style=flat-square) |
| **`snet-web`** | `module.subnets.azurerm_subnet.Subnets["web"]` | Existing subnet adoption | ![Imported](https://img.shields.io/badge/State-IMPORTED-purple?style=flat-square) |
| **`snet-data`** | `module.subnets.azurerm_subnet.Subnets["data"]` | Existing subnet adoption | ![Imported](https://img.shields.io/badge/State-IMPORTED-purple?style=flat-square) |
| **`snet-application`** | `module.subnets.azurerm_subnet.Subnets["application"]` | Existing subnet adoption | ![Imported](https://img.shields.io/badge/State-IMPORTED-purple?style=flat-square) |
| **`snet-security`** | `module.subnets.azurerm_subnet.Subnets["security"]` | Existing subnet adoption | ![Imported](https://img.shields.io/badge/State-IMPORTED-purple?style=flat-square) |
| **`cyberex-nsg`** | `module.nsg.azurerm_network_security_group.this` | Existing NSG adoption | ![Imported](https://img.shields.io/badge/State-IMPORTED-purple?style=flat-square) |
| **`nic-comsolve-cyberex-web`** | `module.nics.azurerm_network_interface.Nic` | Existing Network Interface adoption | ![Imported](https://img.shields.io/badge/State-IMPORTED-purple?style=flat-square) |
| **`Subnet ↔ NSG (×5)`** | `azurerm_subnet_network_security_group_association.subnet_nsg[...]` | Existing Subnet-NSG Associations adoption | ![Imported](https://img.shields.io/badge/State-IMPORTED-purple?style=flat-square) |
---

# 🔄 33. हमारे पूरे Issue का Root Cause

सबसे simple language में:

```text
                 INITIAL STATE

        Terraform Configuration
                  │
                  ▼
       "मुझे ये resources चाहिए"
                  │
                  X
                  │
       Terraform State में
       resources missing थे
                  │
                  ▼
        Azure में resources
        पहले से मौजूद थे
                  │
                  ▼
        Terraform confused
                  │
                  ▼
         Plan में resources
          create होने लगे
```

---

# ✅ 34. Final Solution

हमने architecture को इस तरह align किया:

```text
              Terraform Code
                    │
                    ▼
             Terraform State
                    │
                    ▼
          Azure Remote Backend
                    │
                    ▼
             Azure Resources
```

और existing resources के लिए:

```text
Azure Existing Resource
          │
          ▼
    terraform import
          │
          ▼
   Terraform State
          │
          ▼
    terraform plan
          │
          ▼
       No Changes
```

---

# 🚨 35. सबसे Important Lessons

## Lesson 01 — Existing Azure Resource को देखकर सीधे Apply नहीं करना

अगर resource Azure में पहले से मौजूद है और Terraform state में नहीं है:

```text
पहले import
फिर plan
```

---

## Lesson 02 — `terraform import` Resource Create नहीं करता

```text
Import = State Registration
```

न कि:

```text
Import = Resource Creation
```

---

## Lesson 03 — `terraform plan` सबसे important safety check है

```text
terraform plan
```

से पता चलता है:

```text
Add?
Change?
Destroy?
No Changes?
```

---

## Lesson 04 — `terraform state list` Import Troubleshooting का सबसे useful command है

अगर doubt है:

> "यह resource Terraform manage कर रहा है या नहीं?"

तो:

```powershell
terraform state list
```

देखो।

अगर address नहीं है:

```text
Terraform State में resource registered नहीं है
```

---

## Lesson 05 — Import ID resource type पर depend करता है

हर Terraform resource का import syntax same नहीं होता।

इसलिए:

```text
❌ अनुमान लगाकर import ID नहीं देना
```

बल्कि:

```text
Resource Type
     ↓
Official Provider Documentation
     ↓
Correct Import ID
```

---

# 🏁 36. Final Status

Current result:

```text
Terraform Initialization       ✅
AzureRM Provider               ✅
Remote Backend                 ✅
Resource Group State           ✅
VNet State                     ✅
Subnet State                   ✅
NSG State                      ✅
NIC State                      ✅
Subnet ↔ NSG Associations      ✅
Terraform Validation           ✅
Terraform Plan                 ✅
Infrastructure Drift/Change    ✅ No actionable changes
```

Final Terraform result:

```text
No changes.
Your infrastructure matches the configuration.
```

---

# 🚀 37. आगे CD में क्या होगा?

अब local machine पर:

```text
❌ terraform apply
```

नहीं करना है।

हमारा final deployment architecture:

```text
Feature Branch
      │
      ▼
Pull Request
      │
      ▼
CI Validation
      │
      ▼
PR Approval
      │
      ▼
Merge → main
      │
      ▼
GitHub Actions CD
      │
      ▼
Terraform Init
      │
      ▼
Terraform Plan
      │
      ▼
Terraform Plan Artifact
      │
      ▼
Deployment Approval
      │
      ▼
Terraform Apply
      │
      ▼
Azure
```

यानी **अब हमारा Terraform state/import वाला phase practically resolve हो चुका है।**

सबसे important achievement:

```text
Existing Azure Infrastructure
            +
Terraform Configuration
            +
Terraform Remote State
            ↓
       NO CHANGES
```

यही वह clean baseline है जिससे अब हम confidently **CD pipeline deployment** की तरफ जा सकते हैं।


---
# 🚀 Azure Infrastructure — Post Deployment Verification

<p align="center">

![Azure](https://img.shields.io/badge/Azure-Post%20Deployment-blue)
![Terraform](https://img.shields.io/badge/Terraform-Verified-623CE4)
![CLI](https://img.shields.io/badge/Azure%20CLI-Read--Only-0078D4)
![Status](https://img.shields.io/badge/Status-Verification-yellow)

</p>

> 🎯 **Objective:** Terraform CD pipeline के बाद Azure में deployed infrastructure को terminal से verify करना।
>
> ⚠️ सभी commands **Read-Only** हैं। ये Azure resources को modify नहीं करतीं।

---

# 🧭 Verification Flow

```text
Azure Login
    ↓
Resource Groups
    ↓
VNet + Address Space
    ↓
5 Subnets + CIDR
    ↓
NSG
    ↓
Subnet ↔ NSG Association
    ↓
NIC + Subnet
    ↓
Terraform State
    ↓
Storage Account + TFState
    ↓
Final Resource Count
```

---

# 1️⃣ Azure Login Verification

### 🔹 Command

```powershell
az account show --query "{Subscription:id,Tenant:tenantId,User:user.name}" -o table
```

### 🧠 Purpose

Current Azure CLI login, Tenant और Subscription verify करता है।

### ✅ Expected

```text
Subscription
------------------------------------
7cf9c45e-0a1e-4828-9c98-3e8f25397732
```

---

# 2️⃣ Resource Groups Verification

हमारे Terraform infrastructure में 3 Resource Groups हैं।

### 🔹 Command

```powershell
az group list --query "[?starts_with(name, 'rg-comsolve-cyberex')].{Name:name,Location:location,State:properties.provisioningState}" -o table
```

### 🧠 Purpose

Azure में तीनों Resource Groups actually मौजूद हैं या नहीं verify करता है।

### ✅ Expected

```text
Name                              Location
--------------------------------  -----------
rg-comsolve-cyberex-network       centralindia
rg-comsolve-cyberex-security      eastus
rg-comsolve-cyberex-platform      westeurope
```

---

# 3️⃣ VNet Verification 🌐

### 🔹 Command

```powershell
az network vnet show -g rg-comsolve-cyberex-network -n vnet-comsolve-cyberex-dev --query "{Name:name,Location:location,AddressSpace:addressSpace.addressPrefixes,State:provisioningState}" -o table
```

### 🧠 Purpose

VNet का:

* Name
* Location
* Address Space / CIDR
* Provisioning State

verify करता है।

### 🔍 Important

यहाँ **VNet CIDR जरूर check करना है**।

Example:

```text
AddressSpace
----------------
10.x.x.x/16
```

---

# 4️⃣ VNet + Subnet Complete View 🧩

एक ही command में VNet और सभी subnet ranges देखने के लिए:

### 🔹 Command

```powershell
az network vnet show -g rg-comsolve-cyberex-network -n vnet-comsolve-cyberex-dev --query "{VNet:name,AddressSpace:addressSpace.addressPrefixes,Subnets:subnets[].{Name:name,Prefix:addressPrefix,NSG:networkSecurityGroup.id}}" -o json
```

### 🧠 Purpose

यह सबसे useful network verification command है।

यह दिखाएगा:

```text
VNet
 └── Address Space
      ├── snet-management → CIDR
      ├── snet-web        → CIDR
      ├── snet-data       → CIDR
      ├── snet-application→ CIDR
      └── snet-security   → CIDR
```

साथ में प्रत्येक subnet का attached NSG भी दिखेगा।

---

# 5️⃣ सभी 5 Subnets अलग से Verify करें

### 🔹 Command

```powershell
az network vnet subnet list -g rg-comsolve-cyberex-network --vnet-name vnet-comsolve-cyberex-dev --query "[].{Name:name,Prefix:addressPrefix,NSG:networkSecurityGroup.id,State:provisioningState}" -o table
```

### 🧠 Purpose

सभी 5 subnets की:

* Name
* CIDR / Address Prefix
* NSG
* Provisioning State

verify करता है।

### ✅ Expected Subnets

```text
snet-management
snet-web
snet-data
snet-application
snet-security
```

---

# 6️⃣ NSG Verification 🛡️

### 🔹 Command

```powershell
az network nsg show -g rg-comsolve-cyberex-network -n cyberex-nsg --query "{Name:name,Location:location,State:provisioningState,Rules:securityRules[].name}" -o json
```

### 🧠 Purpose

Actual Azure NSG मौजूद है या नहीं और उसकी state verify करता है।

---

# 7️⃣ Subnet ↔ NSG Association 🔗

### 🔹 Command

```powershell
az network vnet subnet list -g rg-comsolve-cyberex-network --vnet-name vnet-comsolve-cyberex-dev --query "[].{Subnet:name,NSG:networkSecurityGroup.id}" -o table
```

### 🧠 Purpose

हर subnet के साथ `cyberex-nsg` associated है या नहीं verify करता है।

### ✅ Expected

हर subnet के सामने NSG ID में:

```text
cyberex-nsg
```

आना चाहिए।

---

# 8️⃣ NIC Verification 🖥️

### 🔹 Command

```powershell
az network nic show -g rg-comsolve-cyberex-network -n nic-comsolve-cyberex-web --query "{Name:name,Location:location,State:provisioningState,Subnet:ipConfigurations[0].subnet.id,PrivateIP:ipConfigurations[0].privateIPAddress}" -o json
```

### 🧠 Purpose

NIC का:

* Name
* Location
* State
* Connected Subnet
* Private IP

verify करता है।

---

# 9️⃣ NIC → Subnet Verification 🔌

### 🔹 Command

```powershell
az network nic show -g rg-comsolve-cyberex-network -n nic-comsolve-cyberex-web --query "ipConfigurations[].{Name:name,PrivateIP:privateIPAddress,Subnet:subnet.id}" -o table
```

### 🧠 Purpose

NIC किस subnet में connected है यह clearly verify करता है।

Expected हमारे architecture में:

```text
nic-comsolve-cyberex-web
        ↓
snet-web
```

---

# 🔟 Storage Account Verification 💾

Terraform backend के लिए Storage Account:

```text
cyberexterraformstate
```

### 🔹 Command

```powershell
az storage account show -g rg-comsolve-cyberex-network -n cyberexterraformstate --query "{Name:name,Location:location,SKU:sku.name,Kind:kind,State:provisioningState}" -o table
```

### 🧠 Purpose

Remote Terraform State वाला Storage Account actual Azure में मौजूद है या नहीं verify करता है।

---

# 1️⃣1️⃣ Terraform State Container Verification 📦

### 🔹 Command

```powershell
az storage container list --account-name cyberexterraformstate --auth-mode login --query "[].{Name:name}" -o table
```

### 🧠 Purpose

Storage Account के अंदर Terraform state container मौजूद है या नहीं verify करता है।

### ✅ Expected

```text
Name
----------------
tfstate
```

---

# 1️⃣2️⃣ Terraform State File Verification 🗂️

### 🔹 Command

```powershell
az storage blob list --account-name cyberexterraformstate --container-name tfstate --auth-mode login --query "[].{Name:name,Size:properties.contentLength}" -o table
```

### 🧠 Purpose

Remote backend में actual `.tfstate` blob मौजूद है या नहीं verify करता है।

### ✅ Expected

```text
cyberex-landing-zone.tfstate
```

---

# 1️⃣3️⃣ Terraform State Verification 🏗️

अब local Terraform से remote state की resource entries verify करें।

### 🔹 Command

```powershell
terraform state list
```

### 🧠 Purpose

Terraform state में currently managed resources दिखाता है।

### ✅ Expected — 16 Resources

```text
3 × Resource Groups
1 × VNet
5 × Subnets
1 × NSG
5 × Subnet ↔ NSG Associations
1 × NIC
-------------------------
16 × Terraform Resources
```

---

# 1️⃣4️⃣ Terraform Plan Final Safety Check ✅

### 🔹 Command

```powershell
terraform plan
```

### 🧠 Purpose

Terraform configuration + remote state + actual Azure infrastructure के बीच difference check करता है।

### 🟢 Best Expected Result

```text
No changes. Your infrastructure matches the configuration.
```

इसका मतलब:

```text
Terraform Configuration
        =
Terraform State
        =
Azure Infrastructure
```

---

# 1️⃣5️⃣ Final Azure Resource Count 🔢

### 🔹 Command

```powershell
az resource list --query "[?contains(resourceGroup, 'rg-comsolve-cyberex')].{Name:name,Type:type,ResourceGroup:resourceGroup}" -o table
```

### 🧠 Purpose

हमारे Cyberex Resource Groups के अंदर actual Azure resources की list दिखाता है।

---

# 1️⃣6️⃣ Final Resource Summary 📊

Terraform-managed infrastructure:

|  # | Resource                   | Expected |
| -: | -------------------------- | -------: |
|  1 | Resource Group — Network   |        ✅ |
|  2 | Resource Group — Security  |        ✅ |
|  3 | Resource Group — Platform  |        ✅ |
|  4 | Virtual Network            |        ✅ |
|  5 | Subnet — Management        |        ✅ |
|  6 | Subnet — Web               |        ✅ |
|  7 | Subnet — Data              |        ✅ |
|  8 | Subnet — Application       |        ✅ |
|  9 | Subnet — Security          |        ✅ |
| 10 | Network Security Group     |        ✅ |
| 11 | Subnet ↔ NSG — Management  |        ✅ |
| 12 | Subnet ↔ NSG — Web         |        ✅ |
| 13 | Subnet ↔ NSG — Data        |        ✅ |
| 14 | Subnet ↔ NSG — Application |        ✅ |
| 15 | Subnet ↔ NSG — Security    |        ✅ |
| 16 | Network Interface          |        ✅ |

### Backend Infrastructure — Separate Verification

| Component            | Expected                         |
| -------------------- | -------------------------------- |
| Storage Account      | `cyberexterraformstate` ✅        |
| Blob Container       | `tfstate` ✅                      |
| Terraform State Blob | `cyberex-landing-zone.tfstate` ✅ |

> ℹ️ **Important:** Storage Account, container और state blob Terraform के 16 managed resources में count नहीं हो रहे हैं; ये हमारे **remote Terraform backend infrastructure** का हिस्सा हैं।

---

# 🏁 Final Acceptance Criteria

Deployment को successful मानने के लिए:

```text
☑ Azure Login Successful
☑ 3 Resource Groups Present
☑ VNet Present
☑ VNet CIDR Correct
☑ 5 Subnets Present
☑ All Subnet CIDRs Correct
☑ NSG Present
☑ All Subnets Associated with NSG
☑ NIC Present
☑ NIC Connected to snet-web
☑ Storage Account Present
☑ tfstate Container Present
☑ Terraform State Blob Present
☑ Terraform State Contains 16 Resources
☑ terraform plan = No changes
```

## 🎯 Final Architecture Verification

```text
                    Azure
                      │
          ┌───────────┴───────────┐
          │                       │
   Resource Groups          Terraform Backend
          │                       │
          │                cyberexterraformstate
          │                       │
          │                    tfstate
          │                       │
          ▼                       ▼
     Network RG             .tfstate Blob
          │
          ▼
   vnet-comsolve-cyberex-dev
          │
   ┌──────┼──────┬──────────┬──────────┐
   ▼      ▼      ▼          ▼          ▼
 Mgmt    Web    Data    Application  Security
   │      │
   │      └────── NIC
   │
   └───────────────┐
                   ▼
               cyberex-nsg
```

### 🟢 Deployment Status

```text
CI Pipeline       → ✅ PASS
CD Plan           → ✅ PASS
Deployment        → ✅ PASS
Terraform State   → ✅ SYNCED
Terraform Plan    → ✅ NO CHANGES
Azure Validation  → 🔍 FINAL CHECK
```

> 🚀 **Golden Rule:** Pipeline successful होना पहला proof है; `Azure CLI + Terraform State + terraform plan` का combined verification final deployment evidence है।

---