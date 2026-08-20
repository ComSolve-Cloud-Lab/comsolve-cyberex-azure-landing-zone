# 🚀 Phase 09 — GitHub Actions Terraform CI Execution

<p align="center">

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-Automated-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-CI-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-Infrastructure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![DevSecOps](https://img.shields.io/badge/DevOps-CI-success?style=for-the-badge)

</p>

> 🎯 **Objective:** Understand the complete execution flow of the first Terraform GitHub Actions CI pipeline and troubleshoot pipeline failures.

---

# 🧭 Phase 09 Overview

हमने Phase 08 में GitHub Actions की पहली Terraform CI pipeline बनाई थी।

अब Phase 09 में हम समझेंगे कि:

```text
GitHub Actions
      │
      ▼
Runner
      │
      ▼
Checkout Code
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
Terraform Plan
      │
      ▼
❌ / ✅ Pipeline Result
```
---

# 🖥️ Step 01 — GitHub Runner

Pipeline में हमने लिखा:

runs-on: ubuntu-latest

इसका मतलब:

GitHub हमारे workflow को Ubuntu environment में run करेगा।

Runner temporary होता है।

```text

GitHub
   │
   ▼
Temporary Ubuntu Runner
   │
   ├── Git
   ├── Terraform
   └── Required Actions

Pipeline complete होने के बाद यह runner permanent server की तरह हमारे पास नहीं रहता।

```
---

# 📥 Step 02 — Checkout Repository

हमारे workflow में:

uses: actions/checkout@v4

यह GitHub repository का code runner में download करता है।

हमारे case में:

GitHub Repository
       │
       ▼
Ubuntu Runner
       │
       ▼
comsolve-cyberex-azure-landing-zone

इसलिए runner Terraform files को access कर पाया।
---

# 🔐 Step 03 — GITHUB_TOKEN Permissions

Pipeline में हमने रखा:

permissions:
  contents: read

इसका मतलब:

Workflow को repository contents पढ़ने की permission है।

हम अभी repository में कोई modification नहीं करवा रहे।

यह Least Privilege principle का हिस्सा है।
---

# 🏗️ Step 04 — Terraform Setup

Workflow में:

uses: hashicorp/setup-terraform@v3

इससे GitHub runner में Terraform CLI available हो गया।

अब runner ये commands चला सकता है:

terraform fmt

terraform init

terraform validate

terraform plan
---


# 🎨 Step 05 — Terraform Format Check

Pipeline ने execute किया:

terraform fmt -check -recursive

यह check करता है कि Terraform code properly formatted है या नहीं।

Important:

terraform fmt
        ↓
Code को modify करता है


terraform fmt -check
        ↓
सिर्फ check करता है

CI pipeline में -check useful है क्योंकि pipeline developer के code को silently modify नहीं करती।
---

# 🔧 Step 06 — Terraform Init

Pipeline ने execute किया:

terraform init

Output में:

Initializing the backend...
Initializing modules...
Initializing provider plugins...

दिखा।

इसका मतलब Terraform ने successfully:

Backend
   │
   ▼
Modules
   │
   ▼
Providers
   │
   ▼
Dependency Lock File

initialize किया।
---

# 📦 Step 07 — Terraform Modules
```text

Pipeline output में हमारे modules दिखाई दिए:

- resource_groups in modules/resource-group
- nics in modules/nic
- subnets in modules/subnet
- vnet in modules/vnet

इसका मतलब Terraform ने हमारे module structure को successfully identify किया।

Architecture:

terraform/
│
├── main.tf
│
└── modules/
    │
    ├── resource-group
    │
    ├── vnet
    │
    ├── subnet
    │
    └── nic
```
---


# ☁️ Step 08 — AzureRM Provider

Pipeline ने:

hashicorp/azurerm

provider download किया।

हमारे case में:

AzureRM Provider
       │
       ▼
v5.1.0

Terraform इसी provider के माध्यम से Azure resources को understand करता है।
---

# 🔒 Step 09 — .terraform.lock.hcl

Terraform ने dependency lock file को भी use किया:

.terraform.lock.hcl

इसका purpose है:

Terraform provider versions और checksums को lock करना।

इससे अलग-अलग environments में unexpected provider version changes का risk कम होता है।
---

# 🔍 Step 10 — Terraform Validate

Pipeline output:

Success! The configuration is valid.

🔥 इसका मतलब बहुत important है।

Terraform ने हमारी configuration successfully validate कर ली।

इस stage पर Terraform ने check किया कि configuration structurally valid है।

Terraform Code
      │
      ▼
terraform validate
      │
      ▼
✅ Configuration Valid
---

# 📋 Step 11 — Terraform Plan

अब pipeline का सबसे important stage:

terraform plan

यह stage Azure infrastructure में क्या change होगा उसका plan बनाता है।

Concept:

Terraform Code
      │
      ▼
Terraform Plan
      │
      ▼
Compare Desired Configuration
       +
Current Infrastructure State
      │
      ▼
Proposed Changes

Example:

Plan: 3 to add, 0 to change, 0 to destroy.

का मतलब:

3 resources → Create
0 resources → Modify
0 resources → Destroy
---

# ⚠️ Step 12 — हमारी Pipeline यहाँ क्यों रुकी?

हमारे pipeline output में:

Run terraform plan


var.nic_location

दिखा।

यह एक important Terraform concept है।

हमारे Terraform code में:

var.nic_location

एक input variable है।

लेकिन GitHub Actions runner को अभी इसका value नहीं मिला।
---

# 🧠 Local Machine और GitHub Runner में Difference

Local machine पर हमारे पास हो सकता है:

terraform.tfvars

या environment variables।

लेकिन GitHub Actions runner एक fresh temporary environment है।

इसलिए:

```text

💻 Local Machine


Terraform
   │
   ├── Code
   ├── Variables
   └── tfvars

और:

☁️ GitHub Runner


Terraform
   │
   └── Fresh Environment

दोनों automatically same नहीं होते।
```
---

# 🔐 Why This Is Important?

हम GitHub repository में sensitive values blindly commit नहीं करना चाहते।

Examples:

❌ Password
❌ Client Secret
❌ Access Token
❌ Private Key
❌ Sensitive Credentials

इसलिए future pipeline में हम secure mechanisms use करेंगे:

GitHub Secrets
       +
GitHub OIDC
       +
Azure Service Principal
---

# 🚨 Important Learning

अभी pipeline का fail होना कोई disaster नहीं है।

Actually यह हमारे learning के लिए बहुत अच्छा है। 🔥

हमारी pipeline ने successfully ये stages complete किए:

✅ Runner
✅ Checkout
✅ Terraform Setup
✅ Terraform Format
✅ Terraform Init
✅ Terraform Modules
✅ Terraform Provider
✅ Terraform Validate

और पहली बार हमें यहाँ issue मिला:

⚠️ Terraform Plan
       │
       ▼
var.nic_location

इसका मतलब:

CI pipeline successfully Terraform तक पहुँच गई है।

# 🧩 Complete Execution Flow


                    🐙 GitHub
                       │
                       ▼
                ⚙️ GitHub Actions
                       │
                       ▼
                🖥️ Ubuntu Runner
                       │
                       ▼
                📥 Checkout Code
                       │
                       ▼
              🏗️ Setup Terraform
                       │
                       ▼
              🎨 Terraform Format
                       │
                       ▼
                🔧 Terraform Init
                       │
                       ▼
             📦 Load Terraform Modules
                       │
                       ▼
             ☁️ Load AzureRM Provider
                       │
                       ▼
             🔍 Terraform Validate
                       │
                       ▼
                📋 Terraform Plan
                       │
                       ▼
              ⚠️ Missing Variable
                 nic_location 

---

🏆 Current Phase Status
```text

Stage	Status
GitHub Actions	✅ PASS
Ubuntu Runner	✅ PASS
Repository Checkout	✅ PASS
Terraform Setup	✅ PASS
Terraform Format	✅ PASS
Terraform Init	✅ PASS
Terraform Modules	✅ PASS
AzureRM Provider	✅ PASS
Terraform Validate	✅ PASS
Terraform Plan	⚠️ Variable Input Required
Terraform Apply	⏳ Not Implemented
```

# 🔥 What We Learned

इस Phase के बाद हमें ये समझ आना चाहिए:

1️⃣ GitHub Actions क्या करता है?

Code → Runner → Commands → Result

2️⃣ Runner क्या है?

Temporary machine जहाँ workflow execute होता है।

3️⃣ Checkout क्यों?

Repository code runner में लाने के लिए।

4️⃣ Terraform Init क्यों?

Terraform providers, modules और backend initialize करने के लिए।

5️⃣ Terraform Validate क्यों?

Configuration सही है या नहीं check करने के लिए।

6️⃣ Terraform Plan क्यों?

Infrastructure changes का preview देखने के लिए।

7️⃣ Pipeline क्यों रुकी?

क्योंकि:

var.nic_location

का value GitHub runner को उपलब्ध नहीं हुआ।
---

🚀 Next Phase

🔐 Phase 10 — Secure Terraform Variables & Azure Authentication

अगले Phase में हम सीखेंगे:

GitHub Actions
      │
      ▼
🔐 GitHub Secrets
      │
      ▼
☁️ Azure Authentication
      │
      ▼
Terraform
      │
      ▼
terraform plan

और इसके बाद:

🔐 Security Scanning
🔍 IaC Security
🕵️ Secret Detection

को pipeline में integrate करेंगे।

🏁 Phase 09 Conclusion

💡 Pipeline fail होना failure नहीं है।

असली DevOps learning तब शुरू होती है जब pipeline fail होती है और हम उसके logs पढ़कर root cause समझते हैं।

CODE
  ↓
PIPELINE
  ↓
LOGS
  ↓
ERROR
  ↓
ROOT CAUSE
  ↓
FIX
  ↓
PIPELINE PASS

🔥 This is DevOps.
---

भाई, तेरे current log के हिसाब से **`fmt`, `init`, और `validate` तीनों successfully pass हुए हैं**। `plan` पर `var.nic_location` के कारण input मांग रहा है; अगला practical step इसी को **GitHub-safe तरीके से variable/secrets handling** के साथ solve करना होगा।
---

# 🛑 पहले: जो 5 घंटे से pipeline चल रही है उसे बंद करो

तेरी pipeline यहाँ अटकी है:

Run terraform plan


var.nic_location

क्योंकि Terraform variable का input माँग रहा है और GitHub runner interactive input का इंतज़ार कर रहा है।
```text

अभी यही करो 👇

GitHub में:

Repository
   ↓
Actions
   ↓
Terraform Validation
   ↓
Running workflow
```

जिस run के सामने Cancel workflow दिख रहा है, उस पर click करो।

फिर:

Cancel workflow
      ↓
Confirm

अगर कई runs हैं

हर पुराने Running run को cancel कर दो।

या Actions page पर जाकर प्रत्येक running workflow खोलकर:

⋮ / Cancel workflow

कर सकते हो।

⚠️ अभी नई pipeline मत चलाना। पहले पुराने stuck runs cancel करो।
---

अब हम तेरे actual GitHub log को पढ़ेंगे।

```text

तेरा workflow broadly ऐसा है:

Step 13
   ↓
Setup a Job
   ↓
Step 14
   ↓
Checkout Repository
   ↓
Step 15
   ↓
Setup Terraform
   ↓
Step 16
   ↓
Terraform Format
   ↓
Step 17
   ↓
Terraform Init
   ↓
Step 18
   ↓
Terraform Validate
   ↓
Step 19
   ↓
Terraform Plan
   ↓
⚠️ var.nic_location

```
---

# 🟢 STEP 13 — Setup a Job

GitHub Actions log में सबसे पहले दिखाई देता है:

Current runner version: '2.336.0'
इसका मतलब क्या है?

GitHub ने हमारे workflow को execute करने के लिए एक runner दिया।

GitHub Actions
      ↓
Runner
      ↓
Workflow Execute

### Runner basically एक temporary machine/environment है जहाँ हमारे commands चलेंगे।

अगली important line
Operating System

इसके बाद GitHub बताता है कि runner कौन-सा OS use कर रहा है।

हमारे case में:

Ubuntu

है।

इसलिए बाद में log में दिखाई देता है:

shell: /usr/bin/bash

अगली important चीज

GITHUB_TOKEN Permissions

यह GitHub द्वारा workflow को दिया गया temporary authentication token है।

हमारे workflow में अगर:

permissions:
  contents: read

है तो workflow repository का content पढ़ सकता है।

GitHub Repository
       ↓
GITHUB_TOKEN
       ↓
Read Repository

यहाँ principle है:

🔐 जितनी permission जरूरी है, उतनी ही दो।
---

# 🟢 STEP 14 — Checkout Repository

अब log में आता है:

Run actions/checkout@v4

यह बहुत important line है।

हमारी YAML में कुछ ऐसा है:

- name: Checkout Repository
  uses: actions/checkout@v4
uses का मतलब?
uses:

का मतलब है:

किसी existing GitHub Action को use करो।

यहाँ:

actions/checkout@v4

GitHub की official checkout action है।

इसका काम

हमारा repository:

Shrikant-Nadgaudaa/
comsolve-cyberex-azure-landing-zone

GitHub पर है।

Runner खाली environment से शुरू होता है।

Checkout action:

GitHub Repository
       ↓
actions/checkout@v4
       ↓
Runner के अंदर Repository

ले आती है।

Log में यह दिखाई दिया
Syncing repository:
Shrikant-Nadgaudaa/comsolve-cyberex-azure-landing-zone

इसका मतलब:

✅ सही repository मिल गई।

फिर:
Fetching the repository

मतलब GitHub runner repository का content fetch कर रहा है।

फिर:
Checking out the ref

यह भी important है।

ref का मतलब broadly Git reference है:

branch
tag
commit

हमारे case में जिस branch/commit से workflow trigger हुआ, वही checkout हुआ।

और फिर:

git log -1 --format=%H

से commit SHA निकाला गया।

तेरे log में:

495b6a82ccd8b44a59893a5349fcf3e0a55b9143

इसका मतलब pipeline exact commit पर काम कर रही है।

🔥 यह बहुत important DevOps concept है।
---

# 🟢 STEP 15 — Setup Terraform

अब आता है:

Run hashicorp/setup-terraform@v3

हमारी YAML में:

- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
इसका काम?

GitHub runner में Terraform CLI उपलब्ध कराना।

Flow:

Ubuntu Runner
      ↓
setup-terraform@v3
      ↓
Terraform CLI
      ↓
terraform commands available

अब runner ये commands चला सकता है:

terraform fmt
terraform init
terraform validate
terraform plan
Log में यह आया:
/usr/bin/unzip

इसका मतलब Terraform package runner में extract किया जा रहा है।

एक warning भी आई:
Node 20 is being deprecated.
This workflow is running with Node 24 by default.

भाई अभी इससे pipeline fail नहीं हुई है।

यह warning है, error नहीं।

मतलब GitHub Actions के underlying runtime में Node version transition चल रहा है।

अभी इसे देखकर panic करने की जरूरत नहीं है। 😄
---

# 🟢 STEP 16 — Terraform Format

अब:

Run terraform fmt -check -recursive
terraform fmt

Terraform files को standard formatting में रखता है।

-check

यहाँ important है।

terraform fmt

➡️ code format कर सकता है।

लेकिन:

terraform fmt -check

➡️ सिर्फ check करता है कि formatting सही है या नहीं।

-recursive

इसका मतलब:

terraform/
   ↓
main.tf
variables.tf
modules/
   ↓
resource-group/
vnet/
subnet/
nic/

सभी nested Terraform directories को भी check करो।

इसलिए:

terraform fmt -check -recursive

हमारे पूरे Terraform codebase की formatting check कर रहा है।

और यह successfully pass हुआ। ✅
---

# 🟢 STEP 17 — Terraform Init

अब सबसे important Terraform command:

Run terraform init

इसके बाद:

Initializing the backend...
Backend क्या है?

Terraform state कहाँ रखी जाएगी, यह backend decide करता है।

अभी अगर हमने remote backend properly configure नहीं किया है तो Terraform local/default state mechanism use कर सकता है।

```text

आगे हम:

Azure Storage Account
        ↓
Blob Container
        ↓
Terraform Remote State

करेंगे।
```
---

# 🔥 यह बाद के phase में बहुत important होगा।

फिर:
Initializing modules...

तेरे log में:

- resource_groups in modules/resource-group
- nics in modules/nic
- subnets in modules/subnet
- vnet in modules/vnet

आया।

इसका मतलब Terraform ने हमारे modules पहचान लिए।

```text

terraform/main.tf
       │
       ├── resource_groups
       ├── vnet
       ├── subnets
       └── nics
```
---


फिर:
Initializing provider plugins...

अब Terraform को Azure provider चाहिए।

इसलिए:

hashicorp/azurerm

provider initialize हुआ।

फिर:
Installing hashicorp/azurerm v5.1.0

मतलब Terraform AzureRM provider version 5.1.0 install कर रहा है।

और:

Installed hashicorp/azurerm v5.1.0

✅ Successfully installed.
---

# 🟢 STEP 18 — Terraform Validate

अब:

Run terraform validate

और result:

Success! The configuration is valid.

🔥 इसका मतलब:

Terraform Configuration
          ↓
       Validate
          ↓
         ✅

हमारे Terraform syntax/configuration structure में कोई validation error नहीं मिला।

ध्यान रखना:

terraform validate यह guarantee नहीं करता कि Azure में deployment definitely successful होगा।

यह मुख्यतः configuration validity check करता है।
----

# 🔴 STEP 19 — Terraform Plan

अब असली कहानी यहाँ शुरू होती है। 😎

Log:

Run terraform plan

फिर:

terraform plan

और:

shell: /usr/bin/bash -e {0}
shell

Command किस shell में execute होगी।

हमारे case में:

/usr/bin/bash
-e

Bash का error behavior है।

अगर command failure return करती है तो shell/workflow failure की तरफ जा सकता है।

⚠️ फिर आया:
env:


  TERRAFORM_CLI_PATH:
/home/runner/work/_temp/...

यह GitHub runner के temporary environment में Terraform CLI की location से संबंधित environment variable है।

यह हमारी problem नहीं है।

# 🚨 असली problem

फिर:

var.nic_location

बस यहीं Terraform रुक गया।

Terraform basically पूछ रहा है:

भाई nic_location की value क्या है?

😂

# 🧠 ऐसा क्यों हुआ?

हमारे Terraform code में कहीं:

var.nic_location

use हो रहा है।

लेकिन GitHub Actions runner को उसकी value नहीं मिली।

Local machine पर शायद Terraform को value किसी .tfvars या दूसरे input source से मिल रही थी।

लेकिन GitHub runner:

Fresh Environment

है।

इसलिए उसे automatically तुम्हारे local machine की values नहीं मिलतीं।
---

🔥 यही हमारी अगली Learning है

```text

अब हमें समझना है:

Terraform Variables
        ↓
GitHub Actions
        ↓
Environment Variables
        ↓
Secrets
        ↓
Azure Authentication

और आगे:

GitHub OIDC
      ↓
Microsoft Entra ID
      ↓
Azure
```

यही proper production-style approach होगी।

🟡 अभी क्या NOT करना है

अभी यह मत करना:

❌ Azure credentials code में डालना

❌ Client Secret main.tf में डालना

❌ Password GitHub में plain text डालना

❌ Secret को terraform.tfvars में commit करना

हम इसे proper तरीके से करेंगे।
---


# 🧭 Phase 09 Current Position

```text

अभी हमारा flow:

✅ Setup Job
      ↓
✅ Checkout Repository
      ↓
✅ Setup Terraform
      ↓
✅ terraform fmt
      ↓
✅ terraform init
      ↓
✅ terraform validate
      ↓
⚠️ terraform plan
      ↓
   var.nic_location

और यही Phase 09 का सबसे अच्छा learning point है।
```
----

# 🛑 पुराने Runs अभी Cancel करो

GitHub में:

Repository
   ↓
Actions
   ↓
Terraform Validation
   ↓
Running Run
   ↓
Cancel workflow

सभी पुराने stuck runs cancel कर दो।

नई run अभी मत चलाना।

पहले हम nic_location को सही तरीके से handle करेंगे।
---

# ℹ️ GitHub का दूसरा Message

तुमने जो देखा:

Upcoming change to GitHub App installation token format

यह GitHub का upcoming platform change notice है।

इसका मतलब यह नहीं है कि तुम्हारी current Terraform pipeline इसी वजह से fail हुई।

तुम्हारी actual pipeline यहाँ रुकी:

terraform plan
      ↓
var.nic_location

इसलिए अभी उस GitHub App token warning को ignore कर सकते हैं।
---

# 🎯 Phase 09 का Final Lesson

```text 

भाई इस पूरी pipeline को एक लाइन में ऐसे याद रख:

📦 Code
 ↓
🐙 GitHub
 ↓
⚙️ Actions
 ↓
🖥️ Runner
 ↓
📥 Checkout
 ↓
🏗️ Terraform Setup
 ↓
🎨 Format
 ↓
🔧 Init
 ↓
🔍 Validate
 ↓
📋 Plan
 ↓
🔐 Variables / Authentication
```
----


और अब अगला असली मज़ा: terraform plan को बिना interactive prompt के चलाना, nic_location को GitHub Actions में सही तरीके से देना, और उसके बाद Azure authentication + security scanning जोड़ना। 🔥



# 🔐 Phase 09 — GitHub Actions → Azure OIDC Authentication

<p align="center">

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Microsoft Azure](https://img.shields.io/badge/Microsoft%20Azure-Cloud-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![OIDC](https://img.shields.io/badge/OIDC-Keyless%20Authentication-6F42C1?style=for-the-badge)
![Terraform](https://img.shields.io/badge/Terraform-Automation-844FBA?style=for-the-badge&logo=terraform&logoColor=white)

</p>

> 🎯 **Objective:** GitHub Actions को Azure से securely authenticate करना ताकि Terraform बिना किसी local `az login` और बिना long-lived Client Secret के Azure resources का plan/apply कर सके।

---

# 🧭 Phase 09 Overview

इस Phase में हम सीखेंगे:

- 🔐 Azure App Registration
- 👤 Service Principal
- 🔑 Federated Identity Credential
- 🐙 GitHub Actions OIDC
- ☁️ Azure Login
- 🏗️ Terraform Authentication
- 📋 Terraform Plan

---

# 🧠 1. सबसे पहले Problem समझो

हमारी GitHub Actions pipeline यहाँ तक successfully पहुँच रही थी:

```text
GitHub Actions
      │
      ▼
Checkout Repository
      │
      ▼
Setup Terraform
      │
      ▼
terraform fmt
      │
      ▼
terraform init
      │
      ▼
terraform validate
      │
      ▼
terraform plan
      │
      ▼
❌ Azure Authentication

```
Pipeline में यह error आया:

ERROR: Please run 'az login' to setup account.

इसका मतलब Terraform को Azure से बात करनी है लेकिन GitHub Runner के पास Azure credentials नहीं हैं।
---

# 💡 2. Local Machine और GitHub Runner में Difference

हमारे Local Computer पर:

Azure CLI
    │
    ▼
az login
    │
    ▼
Azure Account
    │
    ▼
Terraform
    │
    ▼
Azure

लेकिन GitHub Actions में:

GitHub Runner
      │
      ▼
Terraform
      │
      ▼
Azure

GitHub Runner एक temporary machine है।

उसे हमारे local computer का:

❌ Azure Login

❌ Azure Session

❌ Azure CLI Token

नहीं मिलता।

इसलिए हमें GitHub और Azure के बीच secure trust बनाना होगा।
---

# 🔐 3. Solution — GitHub OIDC

हम यहाँ OIDC (OpenID Connect) authentication इस्तेमाल करेंगे।

सबसे important बात:

GitHub Actions को Azure से authenticate करने के लिए हम long-lived Client Secret पर depend नहीं करेंगे।

```text

Flow:

                    🐙 GitHub
                       │
                       │ OIDC Token
                       ▼
              GitHub Actions Runner
                       │
                       ▼
              Microsoft Entra ID
                       │
                       │ Verify Token
                       ▼
             Federated Credential
                       │
                       ▼
              Service Principal
                       │
                       ▼
             Azure Subscription
                       │
                       ▼
                  Terraform
                       │
                       ▼
                Azure Resources
```
---

# ⭐ 4. OIDC क्यों बेहतर है?

```text

Traditional तरीका:

GitHub
  │
  ▼
Client ID + Client Secret
  │
  ▼
Azure

Problem:

🔴 Secret rotate करना पड़ेगा

🔴 Secret leak हो सकता है

🔴 Long-lived credential

🔴 GitHub Secret management

OIDC:

GitHub
  │
  ▼
Short-lived OIDC Token
  │
  ▼
Microsoft Entra ID
  │
  ▼
Azure Access Token

इसलिए:

✅ No long-lived Client Secret

✅ Short-lived authentication

✅ Better security

✅ GitHub Actions friendly

✅ Terraform automation के लिए ideal

🏢 5. हमारा Azure App Registration


हमने पहले ही App Registration बनाई है:

Application Name:
Shrikant_Nadgauda_GitHub_Actions

Application / Client ID:

666a02fd-9186-4647-bcac-b9fd1943a1e7

Tenant ID:

402a28d6-9ea1-462e-8338-dc09423ff348

Subscription ID:

7cf9c45e-0a1e-4828-9c98-3e8f25397732

```
---

# 🔎 6. App Registration Verify करो

Azure Portal में जाओ:

Azure Portal
   ↓
Microsoft Entra ID
   ↓
App registrations
   ↓
Shrikant_Nadgauda_GitHub_Actions

Overview में verify करो:

Application (client) ID

Directory (tenant) ID

Object ID
---

# 👤 7. Service Principal का मतलब

App Registration का Azure में एक Service Principal होता है।

Simple language में:

App Registration
      │
      ▼
Service Principal
      │
      ▼
Azure में Identity

हमने Service Principal को Subscription पर:

Contributor

role दिया है।

इसका मतलब Terraform इस identity के माध्यम से Azure resources manage कर सकता है।
---

# 🔐 8. Contributor Role Verify करो

Azure Portal:

Subscriptions
   ↓
Azure Subscription
   ↓
Access control (IAM)
   ↓
Role assignments

Search करो:

Shrikant_Nadgauda_GitHub_Actions

Expected:

Role:
Contributor


Scope:
Subscription

# 🔗 9. Federated Identity Credential बनाना

अब Azure App Registration खोलो:

App registrations
   ↓
Shrikant_Nadgauda_GitHub_Actions
   ↓
Certificates & secrets
   ↓
Federated credentials
   ↓
Add credential

# 🐙 10. Federated Credential Scenario

Select:

GitHub Actions deploying Azure resources

यह option GitHub Actions के OIDC authentication के लिए है।
---

# 🌐 11. Issuer

Issuer में:

https://token.actions.githubusercontent.com

रहेगा।

यह GitHub का OIDC token issuer है।
---

# 🏷️ 12. Organization

यहाँ अपना GitHub organization/user name डालना है।

हमारे repository के हिसाब से:

Shrikant-Nadgaudaa
---

# 📦 13. Repository

Repository:

comsolve-cyberex-azure-landing-zone

पूरा GitHub URL नहीं डालना है।

❌ गलत:

https://github.com/Shrikant-Nadgaudaa/comsolve-cyberex-azure-landing-zone

✅ सही:

comsolve-cyberex-azure-landing-zone
---

# 🌿 14. Entity Type

हमारी CI pipeline feature branch से चलती है।

इसलिए Federated Credential को हमारी GitHub workflow की identity के साथ match करना होगा।

अगर credential केवल एक branch के लिए बनाया जाता है तो:

Entity Type:
Branch

और branch:

main

या जिस branch को specifically Azure access देना हो।

# ⚠️ 15. Feature Branch के लिए Important Concept

हमारी pipeline:

on:


  push:
    branches:
      - "feature/**"


  pull_request:
    branches:
      - main

इसका मतलब:

feature/*
    ↓
Terraform Validation

और:

Pull Request
    ↓
main
    ↓
Terraform Validation

Security Principle

Azure में वही GitHub identity allow करनी चाहिए जिसे वास्तव में Azure access चाहिए।

इसलिए OIDC में:

Repository
+
Branch / Entity

को restrict करना security के लिए बेहतर है।
---

# 📝 16. Credential Name

Example:

github-actions-terraform

Description:

OIDC trust for GitHub Actions Terraform automation

Audience:

api://AzureADTokenExchange
---

# 🔐 17. OIDC Trust का मतलब

अब Azure कह रहा है:

"अगर GitHub से आने वाला OIDC token मेरी configured repository/branch identity से match करता है, तो मैं इस application को authenticate करने दूँगा।"

Flow:

GitHub Repository
       │
       │ OIDC Token
       ▼
Microsoft Entra ID
       │
       │ Check
       ├── Organization
       ├── Repository
       └── Branch / Entity
       │
       ▼
Service Principal
       │
       ▼
Azure Subscription
---

# 🐙 18. GitHub Workflow में Azure Login

अब हमारी Terraform pipeline में Azure Login step add होगा।

```text

Concept:

- name: Azure Login
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    
```

यहाँ ध्यान दो:

Client Secret ❌
Password ❌

नहीं है।

हम OIDC authentication use कर रहे हैं।
---

🔑 19. GitHub Repository Variables / Secrets

GitHub Repository में:

Settings
   ↓
Secrets and variables
   ↓
Actions

हम required Azure identifiers configure करेंगे।

Conceptually:

AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID

इन values को workflow में direct hard-code करने के बजाय GitHub configuration से reference करना बेहतर है।
---

# 🔥 20. Azure Login के बाद Terraform

अब pipeline का flow होगा:

Checkout
   ↓
Setup Terraform
   ↓
Terraform Format
   ↓
Terraform Init
   ↓
Terraform Validate
   ↓
Azure Login 🔐
   ↓
Terraform Plan
   ↓
Azure ☁️

# 🏗️ 21. Terraform को Azure Authentication कैसे मिलता है?

Terraform AzureRM provider Azure authentication information Azure environment से obtain कर सकता है।

हमारा flow:

GitHub OIDC
     ↓
azure/login
     ↓
Azure Authentication Context
     ↓
Terraform AzureRM Provider
     ↓
Azure Resource Manager API

इसलिए Terraform को अलग से:

az login

करने की जरूरत नहीं होगी।

# 🧪 22. Terraform Plan

हमारा command:

terraform plan -input=false

क्यों?

-input=false

का मतलब:

Terraform interactive input के लिए runner को wait नहीं करेगा।

अगर कोई required variable missing है:

❌ Pipeline fail

होगी।

यह:

5 घंटे तक wait

नहीं करेगी। 😄
---

# 🔍 23. Successful Pipeline का Expected Flow

GitHub Actions में:

✅ Checkout Repository


✅ Setup Terraform


✅ Terraform Format Check


✅ Terraform Init


✅ Terraform Validate


✅ Azure Login


✅ Terraform Plan


🎉 Pipeline Successful
---

# 🧠 24. अभी तक हमने क्या सीख लिया?

हमारी CI pipeline अब:

GitHub
   │
   ▼
GitHub Actions
   │
   ├── Checkout
   │
   ├── Terraform Setup
   │
   ├── Format
   │
   ├── Init
   │
   ├── Validate
   │
   ├── Azure Authentication
   │
   └── Plan
   │
   ▼
Azure
---

# 🛡️ 25. Security Architecture

हमारा authentication model:

                🔐 SECURITY LAYER


GitHub Repository
       │
       │ OIDC
       ▼
Federated Identity
       │
       ▼
Microsoft Entra ID
       │
       ▼
Service Principal
       │
       │ Contributor
       ▼
Azure Subscription

Security Benefits

✅ No hard-coded password

✅ No long-lived Client Secret

✅ OIDC based authentication

✅ Repository identity validation

✅ Branch restriction possible

✅ Azure RBAC

✅ Short-lived authentication

# 📌 26. Important Difference

❌ Local Authentication

az login

terraform plan

यह हमारे personal/local session पर depend करता है।

✅ CI/CD Authentication
```text 
GitHub Actions
      ↓
OIDC
      ↓
Azure Login
      ↓
Terraform

यह automation के लिए designed है।
```
---

# 🎯 27. Phase 09 Final Architecture

```text
                    🐙 GITHUB
                       │
                       │ Push / Pull Request
                       ▼
               GitHub Actions
                       │
                       ▼
              Checkout Repository
                       │
                       ▼
                Setup Terraform
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
                 🔐 Azure Login
                       │
                       │ OIDC
                       ▼
              Microsoft Entra ID
                       │
                       ▼
             Federated Credential
                       │
                       ▼
              Service Principal
                       │
                  Contributor
                       │
                       ▼
              Azure Subscription
                       │
                       ▼
                Terraform Plan
                       │
                       ▼
                  ☁️ AZURE
```
---

# 🏆 Phase 09 Outcome

इस Phase के बाद हमें यह समझ आना चाहिए:

GitHub Actions को Azure से connect करने के लिए local az login की जरूरत नहीं है।

हम:

GitHub OIDC
     +
Microsoft Entra ID
     +
Federated Identity Credential
     +
Service Principal
     +
Azure RBAC

का उपयोग करके secure authentication बना सकते हैं।
---

# 🧠 याद रखने वाला Golden Rule
GitHub = Code

GitHub Actions = Automation

OIDC = Authentication

Entra ID = Identity

Service Principal = Azure Identity

RBAC = Permission

Terraform = Infrastructure Automation

Azure = Infrastructure


🔥 यही पूरा GitHub Actions + Azure Terraform CI/CD architecture का foundation है।
---

# 🚀 Next Phase
Phase 10 — Terraform Plan Automation & Pull Request Security