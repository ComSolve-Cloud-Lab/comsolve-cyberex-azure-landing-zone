# 🌐 PHASE 06 — AZURE NETWORK FOUNDATION

<p align="center">

# 🏗️ Azure Landing Zone — Network Foundation

</p>

<p align="center">

![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![VNet](https://img.shields.io/badge/Azure-VNet-blue?style=for-the-badge)
![Infrastructure](https://img.shields.io/badge/IaC-Terraform-success?style=for-the-badge)

</p>

---

# 🎯 PHASE OBJECTIVE

इस phase में Azure Landing Zone के लिए basic **Network Foundation** तैयार की जाएगी।

हम बनाएँगे:

- 🌐 Azure Virtual Network
- 🧩 5 Subnets
- 🔄 Terraform Modules
- 🔁 `for_each`
- 📋 Terraform Variables
- 📝 `terraform.tfvars`
- 🔗 VNet → Subnet dependency

---

# 🧭 NETWORK ARCHITECTURE

```text
                         ☁️ AZURE
                            │
                            ▼
                  🌐 Virtual Network
                 10.10.0.0/16
                            │
        ┌───────────┬───────┼───────┬───────────┐
        │           │       │       │           │
        ▼           ▼       ▼       ▼           ▼
     🟦 WEB       🟩 APP   🟨 DATA  🟪 MGMT    🟥 SECURITY
     /24           /24      /24      /24         /24

```

# 📂 PROJECT STRUCTURE

```text

terraform/
│
├── main.tf
├── provider.tf
├── variables.tf
├── terraform.tfvars
│
└── modules/
    │
    ├── resource-group/
    │
    ├── vnet/
    │   ├── main.tf
    │   └── variables.tf
    │
    └── subnet/
        ├── main.tf
        └── variables.tf

```

# 🔹 STEP 01 — VNet Variables

📄 File
terraform/modules/vnet/variables.tf

```text

variable "vnet_name" {


  description = "Name of the Azure Virtual Network"


  type = string


}




variable "address_space" {


  description = "Address space of the Virtual Network"


  type = string


}




variable "location" {


  description = "Azure region"


  type = string


}




variable "resource_group_name" {


  description = "Resource Group name"


  type = string


}

```


# 🔹 STEP 02 — VNet Child Module

📄 File
terraform/modules/vnet/main.tf

```text

resource "azurerm_virtual_network" "Vnet" {


  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name


  address_space = [
    var.address_space
  ]


}

```


# 🧠 VNet Module समझो

```text

Parent module से हमें 4 values मिलेंगी:

VNet Name
     │
     ├── vnet_name
     │
     ├── address_space
     │
     ├── location
     │
     └── resource_group_name

Child module इन values का उपयोग करके Azure में VNet बनाएगा।

```

# 🔹 STEP 03 — Subnet Variables
📄 File
terraform/modules/subnet/variables.tf

```text

variable "subnets" {


  description = "Subnet configuration"


  type = map(object({


    name             = string
    address_prefixes = list(string)


  }))


}




variable "virtual_network_name" {


  description = "Virtual Network name"


  type = string


}




variable "resource_group_name" {


  description = "Resource Group name"


  type = string


}

```


# 🔹 STEP 04 — Subnet Child Module
📄 File
terraform/modules/subnet/main.tf

```text

resource "azurerm_subnet" "Subnets" {


  for_each = var.subnets


  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name


  address_prefixes = each.value.address_prefixes


}

```

# 🧠 for_each समझो

हम 5 अलग-अलग subnet resources नहीं लिखेंगे।

Instead:

for_each = var.subnets

Terraform automatically हर subnet create करेगा।

```text

subnets
   │
   ├── web
   ├── application
   ├── data
   ├── management
   └── security

   ```


# 🔹 STEP 05 — Root Variables
📄 File
terraform/variables.tf

```text

Existing Resource Group variable के नीचे यह add करें:

variable "vnet_name" {


  description = "Virtual Network name"


  type = string


}




variable "vnet_address_space" {


  description = "Virtual Network address space"


  type = string


}




variable "subnets" {


  description = "Subnet configuration"


  type = map(object({


    name             = string
    address_prefixes = list(string)


  }))


}


```


# 🔹 STEP 06 — Terraform.tfvars

📄 File
terraform/terraform.tfvars


Existing values के नीचे:

```text

vnet_name = "vnet-comsolve-cyberex-dev"


vnet_address_space = "10.10.0.0/16"




subnets = {


  web = {


    name             = "snet-web"
    address_prefixes = ["10.10.1.0/24"]


  }


  application = {


    name             = "snet-application"
    address_prefixes = ["10.10.2.0/24"]


  }


  data = {


    name             = "snet-data"
    address_prefixes = ["10.10.3.0/24"]


  }


  management = {


    name             = "snet-management"
    address_prefixes = ["10.10.4.0/24"]


  }


  security = {


    name             = "snet-security"
    address_prefixes = ["10.10.5.0/24"]


  }


}

```


# 🔹 STEP 07 — Parent Main.tf

📄 File
terraform/main.tf



अब Resource Group module के नीचे VNet module add करें:

```text


module "vnet" {


  source = "./modules/vnet"


  vnet_name = var.vnet_name


  address_space = var.vnet_address_space


  location = "Central India"


  resource_group_name = var.resource_groups["network"].name


}

```


# 🔹 STEP 08 — Subnet Module Call

VNet module के नीचे:

```text

module "subnets" {


  source = "./modules/subnet"


  subnets = var.subnets


  virtual_network_name = var.vnet_name


  resource_group_name = var.resource_groups["network"].name


  depends_on = [
    module.vnet
  ]


}

```


# 🧠 PARENT → CHILD FLOW

```text
                  terraform.tfvars
                         │
                         ▼
                  variables.tf
                         │
                         ▼
                     main.tf
                    PARENT
                         │
             ┌───────────┴───────────┐
             │                       │
             ▼                       ▼
       VNet Module              Subnet Module
             │                       │
             ▼                       ▼
          VNet                    for_each
                                     │
                         ┌───────────┼───────────┐
                         ▼           ▼           ▼
                        Web         App         Data
                         │           │           │
                         ├───────────┼───────────┤
                         ▼           ▼
                      Management   Security


```


🔗 RESOURCE DEPENDENCY

Network architecture:

Resource Group
      │
      ▼
Virtual Network
      │
      ▼
Subnets

Terraform में:

RG → VNet → Subnets

Subnet को VNet के अंदर create करना है, इसलिए:

depends_on = [
  module.vnet
]

use किया गया है।




# 🧪 STEP 09 — Terraform Format

cd terraform

terraform fmt -recursive

# 🔍 STEP 10 — Terraform Validate

terraform validate

Expected:

Success! The configuration is valid.


# 📋 STEP 11 — Terraform Plan


terraform plan

Expected infrastructure:

```text

☁️ Azure
│
├── 📦 Resource Groups
│   ├── Network
│   ├── Security
│   └── Platform
│
├── 🌐 Virtual Network
│
└── 🧩 Subnets
    ├── Web
    ├── Application
    ├── Data
    ├── Management
    └── Security

📊 EXPECTED PLAN

Phase 05:

3 Resource Groups

Phase 06 adds:

1 Virtual Network
+
5 Subnets

Total expected resources:

3 Resource Groups
+
1 VNet
+
5 Subnets
----------------
9 Azure Resources
🚫 DO NOT APPLY YET

इस phase में पहले:

terraform fmt
        ↓
terraform init
        ↓
terraform validate
        ↓
terraform plan

Run करें।

अगर plan सही है तभी:

terraform apply

करेंगे।

```

# 🐙 STEP 12 — GitHub Commit

```text

Terraform code verify होने के बाद project root पर जाएँ:

cd ..

Check:

git status

Files add करें:

git add .

Commit:

git commit -m "feat: add Azure VNet and subnet foundation"

Push:

git push

✅ PHASE 06 CHECKLIST
Component	Status

🌐 VNet Module	✅

🧩 Subnet Module	✅

🔄 Subnet for_each	✅

📋 Variables	✅

📝 Terraform.tfvars	✅

🔗 VNet → Subnet Dependency	✅

🧪 Terraform Format	⏳

🔍 Terraform Validate	⏳

📋 Terraform Plan	⏳

🐙 GitHub Push	⏳

🎯 PHASE 06 RESULT
             ☁️ AZURE
                │
                ▼
      📦 Resource Group
                │
                ▼
        🌐 VNet
        10.10.0.0/16
                │
     ┌──────────┼──────────┐
     │          │          │
     ▼          ▼          ▼
   Web         App        Data
  /24          /24        /24
     │
     ├──────────────┐
     ▼              ▼
 Management      Security
    /24             /24
```


# 🚀 NEXT PHASE

🌍 PHASE 07 — Public IP & Azure Bastion

Next phase में:

```text

🌐 VNet
   │
   ├── 🧩 Subnets
   │
   ├── 🌍 Public IP
   │
   └── 🔐 Azure Bastion

इसके बाद धीरे-धीरे:

Application Gateway
        ↓
NAT Gateway
        ↓
NSG
        ↓
Route Tables
        ↓
Private Endpoints
        ↓
Key Vault

```

<p align="center">
🏗️ BUILD → SECURE → AUTOMATE → SCALE
</p> ```
⚠️ एक छोटी लेकिन जरूरी बात

ऊपर main.tf में मैंने:

location = "Central India"

दिया है। अगर हम अपने rule के हिसाब से बिल्कुल zero hard-code रखना चाहते हैं, तो इसे भी variable बनाना बेहतर है।

इसलिए variables.tf में:

variable "vnet_location" {
  type = string
}

और terraform.tfvars में:

vnet_location = "Central India"

फिर main.tf:

location = var.vnet_location

मैं यही recommended version रखूँगा। इससे पूरा Terraform configuration clean रहेगा और बाद में dev / uat / prod environments में locations बदलना आसान होगा।