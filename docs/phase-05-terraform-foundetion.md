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

```


# 📂 PROJECT STRUCTURE


```text

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


```


# 🏗️ PHASE 05 — Resource Group Foundation

हम सिर्फ ये files बनाएँगे:

```text

terraform/
│
├── main.tf
├── variables.tf
├── terraform.tfvars
│
└── modules/
    └── resource-group/
        ├── main.tf
        └── variables.tf

```

# 1️⃣ provider.tf — Terraform + Azure Connection

📄 terraform/provider.tf

```text

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

```

🧠 इसे आसान भाषा में समझ


इस file में दो अलग चीजें हैं:

@@  🔹 Part 1 — terraform {}

```text

terraform {


  required_version = ">= 1.6.0"


  required_providers {


    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }


  }
}

```



यह Terraform को बताता है:


🗣️ "Terraform भाई, Azure infrastructure manage करना है और इसके लिए AzureRM provider चाहिए."

यहाँ:

source = "hashicorp/azurerm"

मतलब AzureRM provider HashiCorp का provider है।

और:

version = "~> 4.0"

मतलब हम AzureRM Provider की 4.x compatible version use करेंगे।


2️⃣ provider "azurerm"

```text

provider "azurerm" {


  features {}


}
```


यह actual Azure provider configuration है।

Simple language में:

```text

terraform {}
     │
     │ बताता है कौन सा provider चाहिए
     ▼
azurerm
     │
     ▼
provider "azurerm"
     │
     │ Azure से communicate
     ▼
☁️ Azure

```


# 3️⃣ Authentication कहाँ है?

```text

यह बहुत important है भाई। 👇

हम अभी इसमें:

client_id
client_secret
tenant_id
subscription_id

नहीं डालेंगे।

क्यों?

क्योंकि हम credentials को Terraform code में hard-code नहीं करना चाहते।

हम आगे GitHub Actions + Azure OIDC use करेंगे।

Local development के लिए तुम Azure CLI से login कर सकते हो:

az login

फिर:

az account set --subscription "7cf9c45e-0a1e-4828-9c98-3e8f25397732"

इससे local Terraform Azure credentials use कर सकता है।

```

# 4️⃣ Parent main.tf

📄 terraform/main.tf

```text

module "resource_groups" {


  source = "./modules/resource-group"


  resource_groups = var.resource_groups


}
```



### 🧠 इसका simple मतलब

Parent module बोल रहा है:

"मेरे पास Resource Groups की सारी information var.resource_groups में है। इसे Child Module को दे दो।"

यहाँ कोई Resource Group name hard-code नहीं है। ✅


यह Parent है।

इसका काम सिर्फ Child Module को call करना है।

```text

main.tf
   │
   │ calls
   ▼
modules/resource-group

```


# 5️⃣ Parent variables.tf

```text

📄 terraform/variables.tf

variable "resource_groups" {


  description = "Resource Group configuration"


  type = map(object({
    name     = string
    location = string
  }))
}

```  


###  🧠 यहाँ असली game है

हम Terraform को बता रहे हैं:

हर Resource Group के पास 2 चीजें होंगी:

name
location

इसलिए:

```text
resource_groups
      │
      ├── network
      │     ├── name
      │     └── location
      │
      ├── security
      │     ├── name
      │     └── location
      │
      └── platform
            ├── name
            └── location

```

# 6️⃣ terraform.tfvars



📄 terraform/terraform.tfvars

यही जगह है जहाँ actual values रखेंगे। 🔥

```text

resource_groups = {


  network = {
    name     = "rg-comsolve-cyberex-network"
    location = "Central India"
  }


  security = {
    name     = "rg-comsolve-cyberex-security"
    location = "East US"
  }


  platform = {
    name     = "rg-comsolve-cyberex-platform"
    location = "West Europe"
  }


}

```

🔥 यहाँ actual values हैं।

इसलिए:

```text

variables.tf
     │
     │ Structure
     ▼
terraform.tfvars
     │
     │ Actual Values
     ▼
main.tf
```

अब देख:

❌ main.tf में कोई hard-coded name नहीं।

❌ variables.tf में कोई hard-coded name नहीं।

✅ Actual values सिर्फ terraform.tfvars में।

---


# 7️⃣ Child variables.tf

```text

📄 terraform/modules/resource-group/variables.tf

variable "resource_groups" {


  description = "Resource Group names and locations"


  type = map(object({
    name     = string
    location = string
  }))


}

```

# 🧠 अब Parent → Child connection समझ


Parent से:

resource_groups = var.resource_groups

Child में आता है:

variable "resource_groups"

मतलब:

```text

              PARENT
                 │
                 │ resource_groups
                 ▼
        ┌─────────────────┐
        │   CHILD MODULE  │
        │                 │
        │ resource_groups │
        └─────────────────┘

```

# 8️⃣ Child main.tf

```text

📄 terraform/modules/resource-group/main.tf

resource "azurerm_resource_group" "Rgs" {


  for_each = var.resource_groups


  name     = each.value.name
  
  location = each.value.location


}


यह actual Azure Resource Group create करेगा।

```


# 🧠 अब पूरा Phase 05 एक बार समझ

```text
                    👨‍💻 YOU
                      │
                      ▼
              terraform.tfvars
                      │
             Actual RG Values
                      │
                      ▼
               variables.tf
                      │
                 var.resource_groups
                      │
                      ▼
                  main.tf
                PARENT MODULE
                      │
                      │ module call
                      ▼
           CHILD RESOURCE GROUP
                      │
                      ▼
              child variables.tf
                      │
                      ▼
               child main.tf
                      │
                   for_each
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       Network     Security     Platform
          │           │           │
          ▼           ▼           ▼
         RG1         RG2         RG3
          │           │           │
          └───────────┼───────────┘
                      ▼
                  ☁️ AZURE

और side में:

provider.tf
     │
     ├── terraform version
     ├── AzureRM provider
     └── Azure provider
             │
             ▼
          ☁️ Azure

```

# 🔥 अब सबसे important part यही है।

for_each

हमारे terraform.tfvars में:

network
security
platform

तीन entries हैं।

Terraform automatically तीन Resource Groups बनाएगा।


# 🧠 each को ऐसे समझ

पहली iteration:

each.key   = network
each.value = {
    name     = "rg-comsolve-cyberex-network"

    location = "Central India"
}

दूसरी:

each.key   = security
each.value = {
    name     = "rg-comsolve-cyberex-security"

    location = "East US"
}

तीसरी:

each.key   = platform
each.value = {
    name     = "rg-comsolve-cyberex-platform"

    location = "West Europe"
}

इसलिए:

name = each.value.name

का मतलब:

जिस RG की iteration चल रही है, उसका name ले लो।

और:

location = each.value.location

का मतलब:

उसी RG की location ले लो।

# 🔥 पूरा Flow

```text

अब पूरा architecture देख:

terraform.tfvars
        │
        │ Actual Values
        ▼
variables.tf
        │
        │ var.resource_groups
        ▼
main.tf
        │
        │ module input
        ▼
Child Module
        │
        ▼
modules/resource-group/variables.tf
        │
        ▼
modules/resource-group/main.tf
        │
        │ for_each
        ▼
 ┌──────────────┬──────────────┬
 │              │              │
 ▼              ▼              ▼
Network       Security       Platform
 │              │              │
 ▼              ▼              ▼
RG-1           RG-2           RG-3

```

# 6️⃣ terraform.tfstate


अब एक important चीज़:

❌ terraform.tfstate manually मत बनाना।

जब तुम:

terraform apply

चलाओगे, Terraform automatically terraform.tfstate बनाएगा।

इसलिए:

terraform.tfstate

को manually create करने की जरूरत नहीं है।

और अभी learning के लिए local state रख सकते हैं। बाद में हम इसे:

☁️ Azure Storage Account
        │
        ▼
🔐 Remote Backend
        │
        ▼
Terraform State

में shift करेंगे।

Production Landing Zone में remote state बहुत important है।


# ⚠️ एक जरूरी बात — terraform.tfvars

तुमने सही पकड़ा कि values hard-code नहीं होनी चाहिए।

लेकिन बाद में इसमें secrets नहीं डालेंगे।

उदाहरण:

❌ Client Secret
❌ Password
❌ Storage Account Key
❌ API Key

इन चीजों के लिए आगे Azure Key Vault / GitHub OIDC / Secret Management करेंगे।

---
# 🚀 अब Run करो

पहले Azure login:

az login

फिर subscription:

az account set --subscription "7cf9c45e-0a1e-4828-9c98-3e8f25397732"

Terraform folder में:

terraform fmt -recursive

फिर:

terraform init

फिर:

terraform validate

फिर:

terraform plan

plan में तुम्हें 3 Resource Groups दिखने चाहिए:

rg-comsolve-cyberex-network

rg-comsolve-cyberex-security

rg-comsolve-cyberex-platform

और locations:

Central India

East US

West Europe

--