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

```text

यह Child VNet Module का input box है।

इसमें हमने 4 चीजें मांगी हैं:

vnet_name
address_space
location
resource_group_name

मतलब Child Module खुद से कुछ decide नहीं करेगा।

Parent उसे बताएगा:

VNet का नाम क्या है?
VNet का IP range क्या है?
किस Azure region में बनाना है?
किस Resource Group में बनाना है?
Simple analogy 🧠
Parent
  │
  │ "ये लो VNet की information"
  ▼
Child variables.tf
  │
  ├── Name
  ├── IP Range
  ├── Location
  └── Resource Group

इसलिए variables.tf में resource create नहीं होता।

यह सिर्फ input receive करता है।

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

```text

यह actual VNet create करने वाला code है।

यहाँ:

azurerm_virtual_network

AzureRM provider को बताता है:

Azure में Virtual Network बनाओ।

फिर:

var.vnet_name

का मतलब:

Child module को जो VNet name मिला है, वो इस्तेमाल करो।

इसी तरह:

var.location
var.address_space
var.resource_group_name

सभी values Child module के variables से आती हैं।

Flow:
terraform.tfvars
       ↓
root variables.tf
       ↓
root main.tf
       ↓
VNet Module
       ↓
VNet variables.tf
       ↓
VNet main.tf
       ↓
☁️ Azure VNet


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

map(object({...})) क्यों?

यह Terraform का important concept है।

हम कह रहे हैं:

subnets एक map होगा और map के अंदर हर item एक object होगा।

Conceptually:

MAP
 │
 ├── web → OBJECT
 │          ├── name
 │          └── address_prefixes
 │
 ├── application → OBJECT
 │
 ├── data → OBJECT
 │
 ├── management → OBJECT
 │
 └── security → OBJECT

इससे Terraform को पहले से पता रहता है कि data कैसा दिखना चाहिए।

अगर गलती से:

address_prefixes = "10.10.1.0/24"

दे दिया जबकि list चाहिए, Terraform validation/error देगा।

यही type safety है। 🔐

```

```text



यह थोड़ा interesting है। 😄

हमारे पास 5 Subnets हैं।

अगर हम 5 अलग variables बनाते:

web_subnet
app_subnet
data_subnet
management_subnet
security_subnet

तो code unnecessarily बड़ा हो जाता।

इसलिए हमने:

subnets

नाम का एक variable बनाया।

उसके अंदर हर subnet की information है।

Concept:

subnets
   │
   ├── web
   ├── application
   ├── data
   ├── management
   └── security

हर subnet के अंदर:

name
address_prefixes

है।

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

  यह actual Subnet creation है।

सबसे important line:

for_each = var.subnets

🔥 इसका मतलब:

var.subnets में जितने items हैं, उतने subnet resources create करो।

हमारे पास:

web
application
data
management
security

यानि:

5 entries
     ↓
for_each
     ↓
5 subnet resources



each.value.name क्या है?

यह बहुत important है।

मान लो Terraform अभी web subnet पर काम कर रहा है।

तो:

each.key

होगा:

web

और:

each.value

होगा:

{
    name = "snet-web"
    address_prefixes = ["10.10.1.0/24"]
}

इसलिए:

each.value.name

का मतलब:

Current subnet का name निकालो।

और:

each.value.address_prefixes

का मतलब:

Current subnet का IP range निकालो।

याद रखने का तरीका 🧠
each.key
   ↓
कौन सा item?


each.value
   ↓
उस item की पूरी information
  
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


यह Parent का input definition है।

हम यहाँ बताते हैं:

VNet और Subnets की information किस format में आएगी?

यह actual values नहीं रखता।

इसमें सिर्फ structure/type होता है।

variables.tf
     ↓
"Data कैसा दिखना चाहिए?"

जबकि:

terraform.tfvars
     ↓
"Actual Data क्या है?"

🔥 यही difference याद रखना।

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

यहाँ actual configuration आती है।

उदाहरण concept:

VNet
 ├── Name
 ├── Address Space
 │
 └── Subnets
      ├── Web
      ├── Application
      ├── Data
      ├── Management
      └── Security

इसका फायदा:

कल अगर VNet बदलना है:

10.10.0.0/16

से:

10.20.0.0/16

तो Terraform resource code बदलने की जरूरत नहीं।

सिर्फ variable value बदलेंगे।

यही Infrastructure as Code का अच्छा pattern है।

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

यह पूरा Parent / Orchestrator है।

इसका काम खुद VNet बनाना नहीं है।

इसका काम है:

सही data सही module को देना।

Concept:

                  ROOT main.tf
                       │
             ┌─────────┴─────────┐
             │                   │
             ▼                   ▼
       Resource Group           VNet
                                 │
                                 ▼
                              Subnets

यानि root main.tf धीरे-धीरे हमारा Landing Zone controller बन रहा है।


🔟 resource_group_name = var.resource_groups["network"].name

यह line भी बहुत important है।

हमने Phase 05 में Resource Groups बनाए थे:

network
security
platform

अब VNet को network RG में रखना है।

इसलिए:

var.resource_groups["network"]

का मतलब:

Resource Groups में से network वाला object निकालो।

फिर:

.name

का मतलब:

उस object का name निकालो।

पूरी chain:

var.resource_groups
        ↓
     ["network"]
        ↓
       .name
        ↓
rg-comsolve-cyberex-network

🔥 इससे Resource Group का नाम दोबारा hard-code करने की जरूरत नहीं पड़ती।

1️⃣1️⃣ depends_on = [module.vnet]

यह Terraform को explicitly बताता है:

पहले VNet बनाओ, उसके बाद Subnets बनाना।

Architecture:

Resource Group
      ↓
     VNet
      ↓
   Subnets

हालाँकि Terraform कई बार resource references देखकर dependency खुद समझ सकता है, लेकिन यहाँ learning और explicit dependency के लिए depends_on दिखाना useful है।

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


🧠 सबसे Important Concept — Parent vs Child

इसे अच्छे से याद कर भाई:

👨 Parent
terraform/main.tf

का काम:

Module को call करना
+
Module को data देना
👶 Child
terraform/modules/vnet/
terraform/modules/subnet/

का काम:

Actual Azure resource create करना

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