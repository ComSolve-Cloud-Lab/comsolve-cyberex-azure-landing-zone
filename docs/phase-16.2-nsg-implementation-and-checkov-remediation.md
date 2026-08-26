# 🛡️ Phase 16.2 — NSG Implementation & Checkov Remediation

<p align="center">

![Checkov](https://img.shields.io/badge/Checkov-IaC%20Security-success?style=for-the-badge)
![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Network Security](https://img.shields.io/badge/Network-Security-red?style=for-the-badge)
![NSG](https://img.shields.io/badge/Azure-NSG-blue?style=for-the-badge)

</p>

---

# 🎯 Phase Objective

इस Phase में हम **Phase 16.1 में मिले real Checkov security finding** को properly remediate करेंगे।

हमारा Checkov finding था:

```text
CKV2_AZURE_31

Ensure VNET subnet is configured with a Network Security Group (NSG)

```

इस finding को केवल bypass करने के बजाय हम Azure Network Security Group को Terraform architecture में properly implement करेंगे।

इस Phase में हम सीखेंगे:

🔍 Checkov finding का मतलब
🧠 NSG क्यों जरूरी है
🌐 Subnet और NSG का relationship
📁 Existing Terraform module को identify करना
🏗️ NSG को module-based architecture में add करना
🔗 NSG को subnet से associate करना
🧪 Local Terraform validation
🔐 Checkov security validation
🚀 GitHub Actions pipeline validation
❌ Security check को bypass करने का सही और गलत तरीका
🏗️ Current CI/CD Flow

Phase 16.1 के बाद हमारी pipeline में Checkov Security Gate है:

GitHub
   │
   ▼
GitHub Actions
   │
   ▼
Azure OIDC Login
   │
   ▼
Terraform Setup
   │
   ▼
Terraform Format
   │
   ▼
Terraform Init
   │
   ▼
Terraform Validate
   │
   ▼
🔐 Checkov Security Gate
   │
   ├── FAIL ❌
   │
   │   CKV2_AZURE_31
   │   Subnet has no NSG
   │
   └── PASS ✅
          │
          ▼
      Trivy Scan
          │
          ▼
     Terraform Plan

इस Phase में हमारा objective:

Checkov FAIL
     │
     ▼
Find Root Cause
     │
     ▼
Implement NSG
     │
     ▼
Associate NSG with Subnets
     │
     ▼
Run Checkov
     │
     ▼
PASS ✅

---

📁 Step 01 — Current Project Structure समझें

हमारा existing structure approximately ऐसा है:

comsolve-cyberex-azure-landing-zone/
│
├── terraform/
│   │
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── locals.tf
│   │
│   └── modules/
│       │
│       ├── resource-group/
│       │
│       ├── vnet/
│       │
│       ├── subnet/
│       │
│       ├── nic/
│       │
│       └── public-ip/
│
└── .github/
    └── workflows/
        └── terraform-ci.yml

हम अभी existing subnet module में NSG implementation करेंगे।

🔎 Step 02 — पहले Existing Subnet Code देखें

VS Code में जाएँ:

terraform
  ↓
modules
  ↓
subnet
  ↓
main.tf

आपके current code में लगभग यह है:

resource "azurerm_subnet" "Subnets" {

  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes = each.value.address_prefixes
}
❌ Problem क्या है?

यह code केवल subnet create कर रहा है:

VNet
 │
 ├── web subnet
 ├── application subnet
 ├── data subnet
 ├── management subnet
 └── security subnet

लेकिन:

Subnet
   │
   ❌ NSG Association नहीं

इसी वजह से Checkov ने finding दी:

CKV2_AZURE_31


# 🧠 Step 03 — NSG होता क्या है? 🧠— NSG क्या करता है?

Azure Network Security Group यानी NSG subnet या network interface के traffic को control करने के लिए security rules provide करता है।

NSG = Network Security Group

यह Azure में network traffic filtering के लिए use होता है।

Basic flow:

Internet
   │
   ▼
Azure Network
   │
   ▼
Subnet
   │
   ▼
NSG
   │
   ├── Allow
   ├── Deny
   └── Restrict

Example:

Internet → Application Subnet
             │
             ▼
            NSG
             │
       ┌─────┴─────┐
       │           │
     Allow        Deny
      443          3389

इससे subnet-level network security enforce की जा सकती है।

NSG के बिना subnet में required network-level security controls missing हो सकते हैं।


### 🔐— NSG क्यों जरूरी है?

NSG का purpose:

- 🔒 Network traffic control

- 🚫 Unwanted traffic restriction

- 🌐 Inbound traffic filtering

- 📤 Outbound traffic filtering

- 🛡️ Network segmentation

- 🔐 Defense-in-depth

- 📋 Security compliance

### Important:

NSG केवल Checkov को PASS कराने के लिए नहीं बनाया जाना चाहिए।

यह actual Azure security architecture का हिस्सा होना चाहिए।

---

# ⚠️ Step 04 — क्या NSG bypass कर सकते हैं? क्या हम Checkov को Bypass कर सकते हैं?

Technically हाँ।

लेकिन production security architecture में बिना reason के security control bypass करना recommended नहीं है।

Technically Checkov finding को suppress/skip किया जा सकता है।

Example:

CKV2_AZURE_31
        ↓
Skip
        ↓
Pipeline PASS

लेकिन हमारे learning project में ऐसा नहीं करेंगे।

क्यों?

क्योंकि actual problem है:

Subnet
   ↓
No NSG

और security scanner सही finding दे रहा है।

अगर हम केवल bypass करेंगे:

Security Finding
      ↓
Ignore
      ↓
Pipeline PASS

तो security improve नहीं होगी।

इसलिए हमारा approach:
❌ Bypass
❌ Ignore
❌ Suppress

✅ Fix

---

# 🏗️ Step 05 — NSG Module बनाना

अब नया module बनाते हैं।

हमारे existing Terraform structure को देखते हुए NSG के लिए नया module बनाया जाएगा।

Expected structure:

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
    │
    ├── vnet/
    │
    ├── subnet/
    │
    ├── nic/
    │
    ├── public-ip/
    │
    └── nsg/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

VS Code terminal में project root से:

cd terraform
mkdir modules\nsg

अब files बनाएँ:

New-Item modules\nsg\main.tf -ItemType File
New-Item modules\nsg\variables.tf -ItemType File
New-Item modules\nsg\outputs.tf -ItemType File

Structure:

terraform/
└── modules/
    └── nsg/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf


# 🔐 Step 06 — NSG Module main.tf

Open:

terraform/modules/nsg/main.tf

Paste:

resource "azurerm_network_security_group" "this" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

यह Azure में NSG create करेगा।

📦 Step 07 — NSG Module variables.tf

Open:

terraform/modules/nsg/variables.tf

Paste:

variable "name" {
  description = "Name of the Network Security Group"
  type        = string
}

variable "location" {
  description = "Azure region where the NSG will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Tags for the NSG"
  type        = map(string)
  default     = {}
}
📤 Step 08 — NSG Module outputs.tf

Open:

terraform/modules/nsg/outputs.tf

Paste:

output "id" {
  description = "ID of the Network Security Group"
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "Name of the Network Security Group"
  value       = azurerm_network_security_group.this.name
}

अब module NSG का ID बाहर expose करेगा।

🔗 Step 09 — Root main.tf में NSG Module Add करें

अब जाएँ:

terraform/main.tf

जहाँ आपके existing modules हैं।

उदाहरण:

module "resource_groups" {
  ...
}

module "vnet" {
  ...
}

module "subnets" {
  ...
}

NSG module को subnet module से पहले add करें।


module "nsg" {

  source = "./modules/nsg"

  name                = "cyberex-nsg"
  location            = var.nic_location
  resource_group_name = module.resource_groups.resource_group_names["network"]

  tags = {
    Environment = "Development"
    Project     = "Cyberex"
    ManagedBy   = "Terraform"
  }
}

⚠️ Important: ऊपर "network" वाला resource-group key आपके actual resource-group module के output/key के अनुसार होना चाहिए।

अगर आपके project में resource group output अलग है, वही existing output use करें।

---

# 🔗 Step 10 — Subnet और NSG Association

अब सबसे important हिस्सा।

Azure में केवल NSG create करना पर्याप्त नहीं है।

हमें:

NSG
 │
 ▼
Subnet

associate करना होगा।

इसके लिए Terraform resource है:

azurerm_subnet_network_security_group_association


# 🧩 Step 11 — Existing Subnet Module में Association Add करें

Open:

terraform/modules/subnet/main.tf

Existing subnet resource को रहने दें:

resource "azurerm_subnet" "Subnets" {

  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes = each.value.address_prefixes
}

इसके नीचे add करें:

resource "azurerm_subnet_network_security_group_association" "this" {

  for_each = azurerm_subnet.Subnets

  subnet_id                 = each.value.id
  network_security_group_id = var.network_security_group_id
}

अब architecture:

Subnet Resource
      │
      ▼
Subnet ID
      │
      ▼
NSG Association
      │
      ▼
NSG ID


# 📥 Step 12 — Subnet Module में NSG Variable Add करें

Open:

terraform/modules/subnet/variables.tf

Add:

variable "network_security_group_id" {
  description = "Network Security Group ID associated with the subnets"
  type        = string
}

अब subnet module NSG ID accept कर सकता है।

# 🔌 Step 13 — Root main.tf में NSG ID Pass करें

Existing:

module "subnets" {}

के अंदर add करें:

network_security_group_id = module.nsg.id

Example:

module "subnets" {

  source = "./modules/subnet"

  resource_group_name  = module.resource_groups.resource_group_names["network"]
  virtual_network_name = module.vnet.name

  subnets = var.subnets

  network_security_group_id = module.nsg.id
}

Important:

module.nsg.id

NSG module का output है।

यह value subnet module को pass की जा रही है।

Again, existing resource-group/VNet output names अपने actual code के अनुसार रखें।

🧠 Step 14 — अब Terraform Dependency कैसे काम करेगी?

Terraform automatically dependency समझेगा:

module.nsg.id
      │
      ▼
module.subnets
      │
      ▼
NSG Association

मतलब:

Create Resource Group
        ↓
Create VNet
        ↓
Create NSG
        ↓
Create Subnets
        ↓
Associate NSG with Subnets

# 🧠 पूरा Terraform Dependency Flow समझें

अब architecture:

Resource Group
      │
      ├───────────────┐
      │               │
      ▼               ▼
     VNet            NSG
      │               │
      │               │
      └───────┬───────┘
              │
              ▼
           Subnets
              │
              ▼
      NSG Association

Terraform dependency:

Resource Group
      ↓
VNet
      ↓
NSG
      ↓
Subnet
      ↓
NSG Association




# 🔍 Step 15 — Terraform Format

Project root:

cd terraform

Run:

terraform fmt -recursive

Expected:

No errors

🔎 Step 16 — Terraform Validate

Run:

terraform validate

Expected:

Success! The configuration is valid.

अगर validation fail हो:

❌ Stop
   ↓
Error पढ़ो
   ↓
File + line number identify करो
   ↓
Fix
   ↓
terraform validate

🛡️ Step 17 — Local Checkov Scan

अब सबसे important test:

checkov -d .

या project root से:

checkov -d terraform

अब पहले जो:

CKV2_AZURE_31
FAILED

आ रहा था, वह ideally disappear होना चाहिए।

Expected concept:

Passed checks
   ↑
Increase

Failed checks
   ↓
Decrease
🐳 Step 18 — Local Trivy Scan

Run:

trivy config terraform

हमने पहले Trivy से clean result देखा था:

Misconfigurations: 0

NSG implementation के बाद फिर से verify करें।

📋 Step 19 — Terraform Plan

अब:

terraform init

फिर:

terraform plan -input=false

यह actual Azure resources create नहीं करेगा।

यह केवल दिखाएगा:

Plan: X to add, 0 to change, 0 to destroy

इसलिए इस phase में safe testing कर सकते हैं।

🐙 Step 20 — Git Status

अब project root में जाएँ:

cd ..

Check:

git status

आपको modified/new files दिखाई देंगी।

Expected:

terraform/main.tf
terraform/modules/nsg/main.tf
terraform/modules/nsg/variables.tf
terraform/modules/nsg/outputs.tf
terraform/modules/subnet/main.tf
terraform/modules/subnet/variables.tf
💾 Step 21 — Git Add
git add terraform/

Check:

git status
📝 Step 22 — Commit
git commit -m "feat: implement NSG for subnet security"
🚀 Step 23 — Push

अपनी current feature branch पर push करें:

git push origin HEAD

इससे current branch ही push होगी।

⚙️ Step 24 — GitHub Actions

अब GitHub जाएँ:

Repository
   ↓
Actions
   ↓
Terraform CI
   ↓
Latest Workflow Run

Pipeline flow:

Checkout
   ↓
Azure OIDC Login
   ↓
Azure Verification
   ↓
Terraform Setup
   ↓
Terraform fmt
   ↓
Terraform init
   ↓
Terraform validate
   ↓
Checkov
   ↓
Trivy
   ↓
Terraform Plan
🛡️ Step 25 — Checkov अब क्या करेगा?

पहले:

Subnet
   ↓
No NSG
   ↓
CKV2_AZURE_31
   ↓
FAILED
   ↓
Pipeline ❌

अब:

Subnet
   ↓
NSG
   ↓
NSG Association
   ↓
Checkov
   ↓
Finding resolved
   ↓
Pipeline ✅
⚠️ Step 26 — एक Important बात

तुम्हारे current Checkov output में पाँच failures थे:

web
application
data
management
security

यह पाँच अलग-अलग architecture problems नहीं हैं।

क्योंकि तुम्हारे subnet module में:

for_each = var.subnets

है।

इसलिए एक ही security gap multiple subnet instances पर दिखाई दे रहा है।

Common Module Problem
        │
        ▼
for_each
 ┌──────┼──────┬──────────┐
 ▼      ▼      ▼          ▼
web    app    data    management ...
 │      │      │          │
 └──────┴──────┴──────────┘
             │
             ▼
       Same CKV Finding

इसलिए एक सही module-level fix कई findings resolve कर सकता है।

🚨 Step 27 — क्या सभी Subnets को Same NSG देना सही है?

यह बहुत important architecture question है।

Learning phase में:

One NSG
   ↓
Multiple Subnets

कर सकते हैं।

लेकिन production में जरूरी नहीं कि:

web
application
data
management
security

सभी के लिए same NSG सही हो।

Better architecture हो सकता है:

Web Subnet
   ↓
Web-NSG

Application Subnet
   ↓
Application-NSG

Data Subnet
   ↓
Data-NSG

Management Subnet
   ↓
Management-NSG

क्योंकि अलग subnet के अलग security requirements हो सकते हैं।

Phase 16.2 में हमारा goal पहले Checkov finding को properly resolve करना है। Detailed NSG rule design हम आगे security architecture phase में कर सकते हैं।

❌ Step 28 — अगर अभी NSG नहीं डालना हो तो?

अगर तुम्हारा objective केवल pipeline pass करना होता, तो Checkov finding suppress की जा सकती थी।

लेकिन वह security fix नहीं होता।

Example concept:

Checkov
   ↓
Finding
   ↓
Suppression
   ↓
Pipeline PASS

यह केवल scanner को कहता है:

इस finding को अभी ignore करो।

हम इस project में इसे primary solution नहीं रखेंगे।

🔥 Step 29 — अभी हमारा सही Approach
❌ Checkov bypass नहीं

❌ --skip-check CKV2_AZURE_31 नहीं

❌ Security gate disable नहीं

❌ Pipeline को force-pass नहीं

✅ NSG create

✅ Subnet-NSG association

✅ Local Checkov

✅ Local Trivy

✅ Terraform validate

✅ Terraform plan

✅ Git push

✅ GitHub Actions verification

🎯 Final Architecture
                 🐙 GitHub
                     │
                     ▼
              GitHub Actions
                     │
                     ▼
              🔐 Azure OIDC
                     │
                     ▼
              Terraform CI
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
     Checkov       Trivy       Terraform
        │            │            │
        ▼            ▼            ▼
   IaC Security   IaC Scan       Plan
                     │
                     ▼
                ☁️ Azure
                     │
              ┌──────┴──────┐
              ▼             ▼
             VNet          NSG
              │             │
              ▼             │
           Subnets ◄────────┘
              │
              ▼
       NSG Associations
🚀 इस Phase का सबसे important lesson

Checkov ने हमें सिर्फ error नहीं दिया — उसने हमारे Terraform architecture में security gap दिखाया।

हमने:

Error
 ↓
Read finding
 ↓
Understand root cause
 ↓
Identify affected module
 ↓
Implement security control
 ↓
Run scanner again
 ↓
Verify
 ↓
Commit
 ↓
CI pipeline

यही actual DevSecOps mindset है।