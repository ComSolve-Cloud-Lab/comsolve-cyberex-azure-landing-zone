# 🛡️ Phase 16.1 — Checkov Security Gate Troubleshooting & Remediation

<p align="center">

![Checkov](https://img.shields.io/badge/Checkov-IaC%20Security-success?style=for-the-badge)
![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Security](https://img.shields.io/badge/Security-Gate-red?style=for-the-badge)

</p>

---

# 🎯 Phase Objective

इस Phase में हम एक **real Checkov pipeline failure** को troubleshoot करेंगे।

हमारा objective केवल error को हटाना नहीं है।

हम सीखेंगे:

- 🔍 Pipeline failure को कैसे पढ़ना है
- 🧠 Checkov ने क्या detect किया
- 📍 Exact Terraform file और line कैसे identify करनी है
- 🔐 Security finding का actual meaning क्या है
- 🛠️ Root cause कैसे identify करना है
- ✅ Correct remediation कैसे design करनी है
- 🧪 Local machine पर fix कैसे verify करना है
- 🚀 GitHub पर push करके pipeline दोबारा कैसे validate करनी है

---

# 🏗️ Current CI/CD Flow

हमारी current pipeline:

```text
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
   └── PASS ✅
          │
          ▼
      Trivy Scan
          │
          ▼
     Terraform Plan
```

---

इस incident में pipeline यहाँ fail हुई:

Terraform Validate
       ↓
Checkov
       ↓
❌ FAILED
       ↓
Trivy
       ↓
SKIPPED
       ↓
Terraform Plan
       ↓
SKIPPED
🚨 Step 01 — Pipeline Failure को पहले पढ़ें

GitHub Actions में failed job खोलने पर हमें यह finding मिली:

Check: CKV2_AZURE_31

"Ensure VNET subnet is configured with a Network Security Group (NSG)"

इसका simple meaning:

Terraform में create होने वाले subnet के साथ Network Security Group (NSG) association detect नहीं हो रही है।

यह Terraform syntax error नहीं है।

यह एक security policy failure है।

🔍 Step 02 — Exact Resource Identify करें

Checkov ने बताया:

FAILED for resource:

module.subnets.azurerm_subnet.Subnets["application"]

इसी तरह:

module.subnets.azurerm_subnet.Subnets["web"]

module.subnets.azurerm_subnet.Subnets["application"]

module.subnets.azurerm_subnet.Subnets["data"]

module.subnets.azurerm_subnet.Subnets["management"]

module.subnets.azurerm_subnet.Subnets["security"]

इससे हमें पता चला कि problem केवल एक subnet की नहीं है।

हमारे subnet module में common security gap है।

📍 Step 03 — Exact Terraform File Identify करें

Checkov ने यह location दी:

/modules/subnet/main.tf:5-15

इसका मतलब:

terraform
   │
   └── modules
       │
       └── subnet
           │
           └── main.tf

अब हमें इस file को inspect करना है:

terraform/modules/subnet/main.tf
🧠 Step 04 — Problematic Terraform Code समझें

Checkov ने जो code identify किया:

resource "azurerm_subnet" "Subnets" {

  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes = each.value.address_prefixes
}

यह resource subnet create कर रहा है।

लेकिन इसमें कोई NSG association दिखाई नहीं दे रही:

Subnet
   │
   ├── Name
   ├── Resource Group
   ├── VNet
   └── Address Prefix
       
   ❌ NSG Association

इसी कारण Checkov ने:

CKV2_AZURE_31

raise किया।

🔁 Step 05 — for_each क्यों Important है?

हमारे subnet module में:

for_each = var.subnets

use किया गया है।

इसका मतलब एक ही resource block से multiple subnets create हो रहे हैं।

Example:

var.subnets
   │
   ├── web
   ├── application
   ├── data
   ├── management
   └── security

इसलिए Checkov ने एक ही policy को multiple resources पर report किया।

यह पाँच अलग-अलग bugs नहीं हैं।

यह एक common module-level security design gap है।

🔐 Step 06 — CKV2_AZURE_31 का Security Meaning

Checkov policy:

CKV2_AZURE_31

का purpose है verify करना कि VNET subnet के साथ Network Security Group security control मौजूद है।

NSG subnet-level network traffic को control करने में मदद करता है।

Conceptually:

Internet / Network Traffic
          │
          ▼
        VNet
          │
          ▼
       Subnet
          │
          ▼
         NSG
          │
     ┌────┴────┐
     ▼         ▼
   Allow      Deny

बिना appropriate NSG controls के subnet unnecessarily exposed हो सकता है।

🧩 Step 07 — Root Cause

हमारा root cause:

Subnet module
      │
      ▼
Creates multiple subnets
      │
      ▼
No NSG association configured
      │
      ▼
Checkov evaluates security policy
      │
      ▼
CKV2_AZURE_31
      │
      ▼
Security Gate FAILED
Root Cause Summary
Root Cause:
Subnet module में NSG association/security control
configure नहीं किया गया था।
❌ Step 08 — इसे सिर्फ Ignore क्यों नहीं करना चाहिए?

एक गलत approach:

Checkov FAIL
      ↓
Ignore Check
      ↓
Pipeline PASS

यह recommended approach नहीं है।

क्योंकि इससे security finding हटती नहीं है।

हमारा objective:

Finding
   ↓
Understand
   ↓
Remediate
   ↓
Validate
   ↓
Pass
🛠️ Step 09 — Remediation Design

सबसे पहले architecture decide करना जरूरी है।

हमारे project में multiple subnet types हैं:

VNet
 │
 ├── Web
 ├── Application
 ├── Data
 ├── Management
 └── Security

हमें decide करना होगा कि:

Option A
---------
हर subnet के लिए अलग NSG


Option B
---------
कुछ subnet groups के लिए common NSG


Option C
---------
Centralized security architecture

Production environment में NSG rules blindly copy नहीं करने चाहिए।

हर subnet की workload requirement के अनुसार rules design करने चाहिए।

🧱 Step 10 — NSG Resource Create करें

Terraform में NSG resource create किया जा सकता है:

resource "azurerm_network_security_group" "subnet_nsg" {

  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

यह केवल example structure है।

Actual production implementation में:

NSG naming
Resource Group
Location
Security Rules
Environment
Subnet purpose

architecture के अनुसार define किए जाएंगे।

🔗 Step 11 — Subnet और NSG Association

Subnet और NSG को associate करने के लिए:

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {

  subnet_id                 = azurerm_subnet.Subnets.id
  network_security_group_id = azurerm_network_security_group.subnet_nsg.id
}

लेकिन हमारे module में:

for_each = var.subnets

use हो रहा है।

इसलिए actual implementation को उसी module design के अनुसार handle करना होगा।

⚠️ Step 12 — पहले Design, फिर Code

Security finding देखकर तुरंत code copy-paste नहीं करना है।

पहले identify करें:

Which subnet?
      ↓
What workload?
      ↓
What traffic is required?
      ↓
What traffic should be denied?
      ↓
Which NSG?
      ↓
Which NSG rules?
      ↓
Which subnet association?

Example:

Web Subnet
   ↓
Internet → HTTPS
   ↓
Allow 443

Internet → SSH
   ↓
Deny

Internet → RDP
   ↓
Deny

यह केवल conceptual example है।

Actual rules application requirement के अनुसार तय होंगे।

🧪 Step 13 — Local Terraform Validation

Code change करने के बाद पहले local validation करें।

Terraform directory में:

cd terraform

फिर:

terraform fmt -recursive

फिर:

terraform init

फिर:

terraform validate

Expected:

Success! The configuration is valid.
🔍 Step 14 — Local Checkov Scan

अब Checkov फिर से चलाएँ:

checkov -d .

या project root से:

checkov -d terraform

पहले result:

Passed checks: 5
Failed checks: 5

Target:

CKV2_AZURE_31

अब remediation के बाद ideally:

CKV2_AZURE_31
      ↓
PASS
🐳 Step 15 — Local Trivy Scan

Checkov के बाद Trivy भी run करें:

trivy config terraform

Expected:

Misconfigurations
        ↓
0

अगर Trivy कोई finding देता है तो उसे भी separately analyze करना होगा।

📋 Step 16 — Terraform Plan

Security checks local में pass होने के बाद:

terraform plan -input=false

यह verify करेगा कि security changes ने Terraform infrastructure design को break नहीं किया।

Expected:

Plan: X to add, X to change, X to destroy
🚀 Step 17 — Git Changes Check करें

अब project root पर वापस जाएँ:

cd ..

Status देखें:

git status

Expected changed files:

terraform/modules/subnet/main.tf

और अगर NSG module बनाया है:

terraform/modules/network-security-group/

जैसे files दिखाई दे सकती हैं।

💾 Step 18 — Changes Commit करें

Files stage करें:

git add .

Commit:

git commit -m "fix: remediate subnet NSG security finding"
📤 Step 19 — Feature Branch पर Push करें

अपनी current feature branch पर push करें:

git push origin feature/nic-infrastructure

अपनी actual branch का नाम check करने के लिए:

git branch --show-current
⚙️ Step 20 — GitHub Actions Automatically Run होगा

Push के बाद:

Git Push
   ↓
GitHub Actions
   ↓
Terraform Validate
   ↓
Checkov
   ↓
Trivy
   ↓
Terraform Plan

अब GitHub Actions में Checkov result देखें।

🧪 Step 21 — अगर Checkov फिर Fail हो

Failure को ऊपर से नीचे पढ़ें।

सबसे पहले:

Check ID

फिर:

FAILED resource

फिर:

File

फिर:

Line number

फिर:

Policy description

Example:

CKV2_AZURE_31
      ↓
module.subnets.azurerm_subnet.Subnets["web"]
      ↓
modules/subnet/main.tf
      ↓
Line 5-15
      ↓
NSG association missing
🧠 Step 22 — Checkov Error पढ़ने का Formula

हर Checkov failure के लिए यह formula follow करें:

1. WHAT?
   ↓
   कौन-सी security policy fail हुई?

2. WHERE?
   ↓
   कौन-सी file/resource में problem है?

3. WHY?
   ↓
   Security requirement क्यों पूरी नहीं हुई?

4. ROOT CAUSE?
   ↓
   Terraform design/code में actual gap क्या है?

5. FIX?
   ↓
   सही architecture क्या है?

6. TEST?
   ↓
   Local Checkov + Terraform validation

7. PUSH?
   ↓
   Feature branch

8. VERIFY?
   ↓
   GitHub Actions
-----
### 📊 Step 23 — इस Incident का Troubleshooting Record

| # | Observation | Meaning | Action |
| :-: | :--- | :--- | :--- |
| **1** | **Checkov failed** | Security gate blocked pipeline | Failure logs inspect किए |
| **2** | **CKV2_AZURE_31** | Subnet NSG requirement missing | Policy identify की |
| **3** | **Multiple subnet failures** | Common module-level issue | `for_each` inspect किया |
| **4** | **`modules/subnet/main.tf`** | Exact source identified | Subnet module inspect किया |
| **5** | **No NSG association** | Root cause identified | NSG architecture required |
| **6** | **Trivy skipped** | Previous gate failed | Checkov fix के बाद rerun होगा |
| **7** | **Terraform Plan skipped** | Pipeline fail-fast behavior | Security gate पहले रखना सही है |
| **8** | **Local validation required** | CI पर blindly test नहीं करना | Checkov/Trivy/Terraform locally run किए |

---

🚦 Step 24 — Pipeline Gate Behavior समझें

हमारी pipeline में:

Terraform Validate
       │
       ▼
   Checkov
       │
       ├── ❌ FAIL
       │      ↓
       │   Pipeline STOP
       │
       └── ✅ PASS
              ↓
           Trivy
              │
              ├── ❌ FAIL
              │      ↓
              │   Pipeline STOP
              │
              └── ✅ PASS
                     ↓
                Terraform Plan

इसका फायदा:

Insecure Terraform
       ↓
   Block Early
       ↓
No Plan
       ↓
No Deployment
🔐 Step 25 — Security Gate का सही उद्देश्य

Security gate का उद्देश्य developer को परेशान करना नहीं है।

इसका उद्देश्य है:

Bad Infrastructure Configuration
            ↓
       Detect Early
            ↓
       Block Pipeline
            ↓
       Fix Security
            ↓
       Re-run
            ↓
       Continue
⚠️ Step 26 — Finding को blindly Suppress न करें

अगर कोई finding business requirement के कारण acceptable है तो suppression possible है।

लेकिन:

FAIL
 ↓
Suppress
 ↓
PASS

को default solution नहीं बनाना चाहिए।

पहले:

Understand
   ↓
Validate
   ↓
Remediate

और केवल justified exception होने पर suppression/documentation करें।

📝 Step 27 — Incident Summary
🔴 Problem
Checkov Security Gate FAILED
🔍 Finding
CKV2_AZURE_31
📍 Location
terraform/modules/subnet/main.tf
🎯 Affected Resources
web
application
data
management
security
🧠 Root Cause
Subnet module में NSG association/security control
configured नहीं था।
🛠️ Resolution
NSG architecture
      ↓
NSG resource
      ↓
NSG rules
      ↓
Subnet ↔ NSG association
      ↓
Checkov validation


# ✅ Final Validation
Terraform fmt
      ↓
Terraform validate
      ↓
Checkov
      ↓
Trivy
      ↓
Terraform plan


# 🏆 Phase 16.1 Key Learning

इस incident से हमने सीखा:

🔍 GitHub Actions logs को पढ़ना
🔐 Checkov security policy समझना
🆔 Check ID identify करना
📍 Exact Terraform resource identify करना
🧩 Module-level security gap पहचानना
🔁 for_each के कारण repeated findings समझना
🛡️ NSG security requirement समझना
🧪 Local security validation करना
🚦 Security Gate behavior समझना
🚀 Feature branch पर fix test करना
📊 CI pipeline में security failure troubleshoot करना



