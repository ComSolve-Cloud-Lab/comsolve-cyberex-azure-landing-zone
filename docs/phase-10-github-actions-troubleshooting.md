# 🛠️ Phase 10 — GitHub Actions & Terraform Troubleshooting Playbook

<p align="center">

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Troubleshooting](https://img.shields.io/badge/Troubleshooting-Production%20Ready-success?style=for-the-badge)

</p>

---

# 🎯 Phase Objective

इस Phase का उद्देश्य केवल pipeline बनाना नहीं है।

हम सीखेंगे:

- 🔍 Pipeline logs को पढ़ना
- 🧠 Failure का Root Cause निकालना
- 🛠️ Terraform errors troubleshoot करना
- 🌐 GitHub Runner environment समझना
- 🔐 Azure authentication issues समझना
- ⏱️ Pipeline unnecessarily लंबे समय तक क्यों चलती है
- 🧩 Missing files / `.gitignore` issues पहचानना
- 📦 Terraform variables GitHub Runner तक क्यों नहीं पहुँचते
- 🔄 Pipeline failure के बाद सही तरीके से re-run करना
- 🚨 Failed stage identify करना
- 📊 हर pipeline step में क्या देखना चाहिए
- 🔒 Secrets और OIDC authentication issues समझना

---

# 🏗️ Troubleshooting Mindset

सबसे important rule:

> ❌ Error देखकर तुरंत code change मत करो।

पहले:

```text
Observe
   ↓
Identify failed step
   ↓
Read complete log
   ↓
Find first real error
   ↓
Understand Root Cause
   ↓
Fix
   ↓
Test locally
   ↓
Push
   ↓
Run Pipeline Again
   ↓
Verify
```
---

# 📁 Step 01 — Phase 10 Folder Structure

Project root:

```text

comsolve-cyberex-azure-landing-zone/
│
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
│
├── docs/
│   ├── Phase 01...
│   ├── Phase 02...
│   ├── ...
│   ├── phase-09...
│   └── phase-10-github-actions-troubleshooting.md
│
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── outputs.tf
│   │
│   └── modules/
│       ├── resource-group/
│       ├── vnet/
│       ├── subnet/
│       └── nic/
│
└── README.md
```

---

# 📂 Step 02 — Phase 10 File Create करना

Project root पर:

New-Item docs\phase-10-github-actions-troubleshooting.md -ItemType File

Verify:

Get-ChildItem docs

---

# 🚀 Step 03 — हमारे Actual Issues

> 📌 **Purpose:** इस section में Phase 07–09 के दौरान आए वास्तविक issues, उनके root causes और troubleshooting lessons को document किया गया है।

> 🎯 **Goal:** Future projects में इन issues को जल्दी identify और resolve करना।

इस project में हमने कई practical issues face किए।

मुख्य issues:

| # | Issue | Root Cause | Resolution | Lesson Learned |
|---:|---|---|---|---|
| 1 | NIC module validation error | Module output name mismatch | Module output और parent reference match किया | Module inputs/outputs हमेशा verify करें |
| 2 | Terraform plan pipeline में अटकना | Required variable runner environment में available नहीं थी | Variable handling ठीक की | CI runner को local machine जैसा assume नहीं करना |
| 3 | `terraform.tfvars` GitHub पर दिखाई नहीं दी | `.gitignore` में `*.tfvars` था | Git tracking और `.gitignore` review किया | Sensitive files को blindly commit नहीं करना |
| 4 | Azure authentication failure | Runner authenticated नहीं था | GitHub OIDC/Federated Credential configure किया | CI/CD में non-interactive authentication जरूरी है |
| 5 | Pipeline कई घंटे चलती रही | `terraform plan` interactive input का wait | `-input=false` use किया | CI pipeline में interactive commands avoid करें |
| 6 | Multiple workflow runs running | हर push पर workflow trigger हुआ | Workflow runs cancel/stop किए और trigger strategy review की | Workflow triggers carefully design करें |
| 7 | Node 20 warning | GitHub Actions runtime deprecation notice | Actions versions/runtime compatibility review की | Warnings को ignore नहीं करना चाहिए |
| 8 | `.terraform.lock.hcl` changes | Provider dependency resolution | Lock file changes review करके commit किए | Provider versions reproducible रखें |
---

# 🧩 Step 04 — NIC Module में आया Issue

```text

हमारा root module:

module "nics" {


  source = "./modules/nic"


  nic_name            = var.nic_name
  location            = var.nic_location
  resource_group_name = var.resource_groups["network"].name
  subnet_id           = module.subnets.subnet_ids["web"]


}

Pipeline/Local validation में error आया:

Error: Unsupported attribute


module.subnets is an object


This object does not have an attribute named "subnet_ids".
```
---

# 🔍 Step 05 — NIC Error को कैसे पढ़ें?

Error में सबसे important line:

```text

This object does not have an attribute named "subnet_ids".

```
---

इसका मतलब:

```text

root main.tf
     │
     ▼
module.subnets.subnet_ids
     │
     ▼
Terraform कह रहा है:
"subnet_ids नाम का output मुझे नहीं मिला"
```
---

# 🧠 Step 06 — Root Cause

Terraform modules parent-child structure में काम करते हैं।

Parent module:

module.subnets.subnet_ids

तभी काम करेगा जब child module में:

output "subnet_ids" {
  ...
}

exist करता हो।

अगर child में output का नाम:

output "subnets" { }

है,

तो parent में:

module.subnets.subnet_ids

गलत होगा।

---

# 🛠️ Step 07 — NIC Issue Resolution

```text

Debugging process:

Error
 ↓
Check parent main.tf
 ↓
Check module.subnets
 ↓
Check modules/subnet/outputs.tf
 ↓
Compare output name
 ↓
Correct reference
 ↓
terraform validate

```
Validation:

terraform validate

Expected:

Success! The configuration is valid.

---

# ⭐ Lesson

Terraform module का output name और parent module का reference बिल्कुल match होना चाहिए।

Example:

Child Module
     │
     ▼
output "subnet_ids"
     │
     ▼
Parent Module
     │
     ▼
module.subnets.subnet_ids

---

# 📦 Step 08 — terraform.tfvars GitHub पर क्यों नहीं दिखी?

हमने local machine पर:

terraform/terraform.tfvars

बनाई थी।

लेकिन:

git ls-files terraform/terraform.tfvars

का output खाली आया।

इसका मतलब:

Git इस file को track नहीं कर रहा था।

---

# 🔍 Step 09 — Root Cause

हमारे .gitignore में था:

#==========================================
#Terraform variable files
#==========================================


*.tfvars
*.tfvars.json

इसका मतलब:

*.tfvars
    ↓
सभी Terraform variable files
    ↓
Git ignore करेगा

इसलिए:

terraform.tfvars

GitHub पर नहीं गई।

---

# 🔐 Step 10 — .tfvars को Ignore क्यों करते हैं?

क्योंकि इसमें sensitive information हो सकती है:

Subscription IDs

Client IDs

Passwords

Secrets

Environment values

इसलिए production environment में सामान्य practice:

terraform.tfvars
        ↓
.gitignore
        ↓
Never commit secrets

⚠️ Important Security Rule

अगर .tfvars में secrets हैं:

❌ GitHub पर push मत करो

❌ Git history में commit मत करो

❌ Public repository में मत रखो

हम आगे:

GitHub Secrets
        +
OIDC
        +
Azure

का use करेंगे।

---

# ⏱️ Step 11 — Pipeline 5 घंटे क्यों चलती रही?

यह हमारे सबसे important real-world issues में से एक था।

Pipeline इस step पर रुकी:

Run terraform plan


terraform plan


var.nic_location

और लगभग:

5 hours

तक running रही।

---

# 🧠 Step 12 — इसका मतलब क्या है?

Terraform पूछ रहा था:

var.nic_location

मतलब Terraform को इस variable की value चाहिए।

Local machine पर हमारे पास:

terraform.tfvars

थी।

लेकिन GitHub Runner पर वह file मौजूद नहीं थी।

Flow:

Local Machine
     │
     ├── terraform.tfvars
     │
     ▼
Terraform
     │
     ▼
Value available

लेकिन GitHub:

GitHub Runner
     │
     ├── terraform code
     ├── workflow
     ├── .terraform.lock.hcl
     │
     └── terraform.tfvars ❌

इसलिए:

terraform plan
      ↓
var.nic_location
      ↓
Terraform waits for input
      ↓
GitHub Runner waits
      ↓
Workflow remains Running

---

# 🚨 Step 13 — सबसे Important Lesson

CI/CD pipeline में interactive commands avoid करने चाहिए।

गलत:

terraform plan

Better:

terraform plan -input=false

इससे Terraform user input के लिए wait नहीं करेगा।

अगर required variable missing है:

Pipeline
   ↓
Terraform plan
   ↓
Missing variable
   ↓
Immediate failure ❌

यह अच्छा है।

क्योंकि:

Fast Failure

हमें जल्दी Root Cause दिखाता है।


---


# 🛠️ Step 14 — Pipeline Hang Fix

Workflow में:

- name: Terraform Plan
  run: terraform plan -input=false

Use करें।

अब:

Missing variable
      ↓
No interactive prompt
      ↓
Terraform exits
      ↓
GitHub Actions = FAILED


# 🔐 Step 15 — Azure Authentication Error

बाद में pipeline में error आया:

Error: unable to build authorizer for Resource Manager API

और:

could not configure AzureCli Authorizer

फिर:

Please run 'az login'

---

#  🧠 Step 16 — इसका मतलब

Terraform Azure से बात करना चाहता था:

Terraform
    │
    ▼
AzureRM Provider
    │
    ▼
Azure Resource Manager

लेकिन GitHub Runner में Azure authentication नहीं थी।

Local machine पर:

az login

से login हो सकता है।

लेकिन GitHub Runner एक fresh temporary machine है।

वहाँ:

❌ आपका local Azure login

❌ आपका local session

❌ आपका local credential

available नहीं होता।

# 🏗️ Step 17 — Correct Architecture

हम eventually use करेंगे:

GitHub Actions
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
      ▼
Azure Subscription
      │
      ▼
Terraform

इसमें:

❌ Client Secret नहीं

❌ Password नहीं

❌ az login manually नहीं

---

# 🔍 Step 18 — Pipeline Logs कैसे पढ़ें?

GitHub Actions में:

Repository
   ↓
Actions
   ↓
Workflow
   ↓
Workflow Run
   ↓
Job
   ↓
Step
   ↓
Logs

हर step का log पढ़ना चाहिए।

# 📊 Step 19 — Setup Job में क्या देखना है?

Example:

Current runner version

Operating System

Runner Image

GITHUB_TOKEN Permissions

इनसे पता चलता है:

कौन-सा runner?

कौन-सा OS?

कौन-सी permissions?

# 🔎 Step 20 — Checkout Repository

Log:

Run actions/checkout@v4

फिर:

Syncing repository

और:

Checking out the ref

यह verify करता है कि:

GitHub Repository
      ↓
Runner
      ↓
Code downloaded

हो गया।

अगर यहाँ fail:

Repository access

Token

Permissions

Branch

Checkout configuration

check करें।

---


# 🧰 Step 21 — Setup Terraform

Log:

Run hashicorp/setup-terraform@v3

यह GitHub Runner में Terraform CLI उपलब्ध करता है।

Verify:

Terraform executable
Terraform version

अगर यहाँ issue:

Terraform version

Action version

Runner compatibility

check करें।

---

# 🎨 Step 22 — Terraform Format

Command:

terraform fmt -check -recursive

Meaning:

fmt
 ↓
Terraform formatting check

-check:

अगर formatting गलत है
        ↓
Pipeline fail

-recursive:

Root
 +
Modules
 +
Subdirectories

सब check होंगे।

# 📦 Step 23 — Terraform Init

Command:

terraform init

Important logs:

Initializing the backend...

मतलब Terraform backend initialize कर रहा है।

फिर:

Initializing modules...

मतलब:

resource_groups
nics

subnets

vnet

जैसे modules load हो रहे हैं।

फिर:

Initializing provider plugins...

यह:

azurerm

provider install/restore करता है।

---

# 🔒 Step 24 — .terraform.lock.hcl

Log में:

Reusing previous version...
Installing hashicorp/azurerm...

दिख सकता है।

.terraform.lock.hcl provider version selection को lock करता है।

इसका purpose:

Developer Machine
       +
GitHub Runner
       +
CI/CD
       ↓
Consistent Provider Version


# ✅ Step 25 — Terraform Validate

Command:

terraform validate

यह check करता है:

Syntax

Configuration structure

Module references

Variable definitions

Resource configuration

Example:

Success! The configuration is valid.

मतलब:

Terraform configuration structurally valid

⚠️ इसका मतलब Azure deployment successful नहीं है।

---

# 📋 Step 26 — Terraform Plan

Command:

terraform plan -input=false

यह सबसे important stage है।

Terraform compare करता है:

Terraform Configuration
        +
Current Azure State
        ↓
Execution Plan

और बताता है:

+ Create
~ Change
- Destroy

Example:

Plan: 3 to add, 0 to change, 0 to destroy.

मतलब:

3 resources create होंगे

0 modify होंगे

0 delete होंगे

---

# 🚨 Step 27 — अगर Plan पर Pipeline Fail हो जाए

सबसे पहले यह मत देखो:

Process completed with exit code 1

यह सिर्फ final result है।

ऊपर scroll करो।

Search करो:

Error:

या:

│ Error:

या:

failed

या:

permission


# 🧠 Step 28 — First Real Error Rule

Golden Rule:

🔥 Log में सबसे नीचे दिखने वाला error हमेशा Root Cause नहीं होता।

Example:

Error A
   ↓
Error B
   ↓
Error C
   ↓
Process exited with code 1

पहले:

Error A

समझो।

क्योंकि B और C कभी-कभी A के consequences होते हैं।

---

# 🔍 Step 29 — Failure Classification

```text

Pipeline failure को category में divide करो:

                  Pipeline Failure
                         │
       ┌─────────────────┼─────────────────┐
       │                 │                 │
       ▼                 ▼                 ▼
    GitHub             Terraform         Azure
       │                 │                 │
       ▼                 ▼                 ▼
 Permissions          Syntax           Authentication
 Checkout             Variables        RBAC
 Branch               Modules          Subscription
 Secrets              Provider         Resource

```
---

# 🐙 Step 30 — GitHub Related Failures

Check:

Repository

Branch

Permissions

Actions settings

Secrets

Variables

Workflow syntax

Common errors:

Checkout failed

Permission denied

Workflow not triggered

Secret not found

---

# 🏗️ Step 31 — Terraform Related Failures

```text

Check:

terraform fmt
terraform init
terraform validate
terraform plan

Common:

Unsupported attribute
Missing variable
Invalid resource
Provider error
Module error
```
---

# ☁️ Step 32 — Azure Related Failures

```text 

Check:

Authentication
Subscription
RBAC
Resource Provider
Quota
Region
Resource name

Typical:

AuthorizationFailed
AuthenticationFailed
ResourceGroupNotFound
SubscriptionNotFound
```

---

# 🔐 Step 33 — Authentication Troubleshooting

हमारे project का target:

GitHub
   │
   ▼
OIDC
   │
   ▼
Microsoft Entra ID
   │
   ▼
Federated Credential
   │
   ▼
Service Principal
   │
   ▼
Azure

```text

अगर authentication fail:

Check 1
Client ID
Check 2
Tenant ID
Check 3
Subscription ID
Check 4
Federated Credential
Check 5
Subject Identifier
Check 6
Azure RBAC
```
---


# 🛑 Step 34 — Running Pipeline को कैसे रोकें?

अगर workflow गलती से बहुत लंबे समय तक running हो:

```text

GitHub
  ↓
Actions
  ↓
Workflow
  ↓
Running Job
  ↓
Cancel workflow

इससे current run stop हो जाता है।
```
---


# 🔁 Step 35 — Multiple Runs क्यों बन गए?

```text

हमारे workflow में:

on:


  push:
    branches:
      - "feature/**"

इसका मतलब:

Feature branch पर हर push
        ↓
New workflow run

अगर 5 बार push:

Push 1 → Run 1
Push 2 → Run 2
Push 3 → Run 3
Push 4 → Run 4
Push 5 → Run 5

इसलिए कई runs simultaneously दिख सकते हैं।

```
---

# 🧹 Step 36 — Old Runs को कैसे Handle करें?

```text

Running run खोलो:

Actions
   ↓
Workflow Run
   ↓
Cancel workflow

फिर latest corrected commit push करो।

```
---

# ⚠️ Step 37 — Node 20 Warning

Logs में आया:

Node 20 is being deprecated.

यह Terraform error नहीं है।

यह GitHub Actions runtime warning है।

Meaning:

GitHub Action
     ↓
Node runtime
     ↓
Future runtime change

इसे देखकर तुरंत Terraform code बदलने की जरूरत नहीं।


---


# 🧠 Step 38 — Warning vs Error

बहुत important distinction:

🟡 Warning

Node 20 is being deprecated

Pipeline continue कर सकती है।

🔴 Error
Error: ...
Process completed with exit code 1

Pipeline fail होती है।

🟢 Success
Success!
Process completed with exit code 0

---

# 📊 Step 39 — Pipeline Logs Reading Checklist

हर run में:

☐ Runner सही है?
☐ Repository checkout हुआ?
☐ Correct branch checkout हुई?
☐ Terraform setup हुआ?
☐ terraform fmt successful?
☐ terraform init successful?
☐ Modules initialize हुए?
☐ Provider install हुआ?
☐ terraform validate successful?
☐ Required variables available हैं?
☐ Azure authentication successful है?
☐ terraform plan complete हुआ?
☐ कोई unexpected destroy तो नहीं?

---

# 🧪 Step 40 — Local Debugging First

Pipeline में push करने से पहले:

cd terraform

फिर:

terraform fmt -recursive

फिर:

terraform init

फिर:

terraform validate

फिर:

terraform plan -input=false

---

#  🎯 Step 41 — Local vs GitHub Difference

सबसे important concept:

```text

LOCAL MACHINE
     │
     ├── Azure Login
     ├── terraform.tfvars
     ├── Environment Variables
     └── Cached Credentials

लेकिन:

GITHUB RUNNER
     │
     ├── Fresh Machine
     ├── Repository Checkout
     ├── Workflow Environment
     └── Explicit Authentication Required

इसलिए:

"मेरे laptop पर काम कर रहा है"

का मतलब यह नहीं:

"GitHub Actions में भी काम करेगा।"

```

---


# 🔥 Step 42 — Our Troubleshooting Workflow

```text

अब से किसी भी pipeline issue के लिए:

                 🚨 FAILURE
                     │
                     ▼
               Open Actions
                     │
                     ▼
               Open Run Logs
                     │
                     ▼
             Identify Failed Step
                     │
                     ▼
             Read Complete Log
                     │
                     ▼
             Find First Error
                     │
                     ▼
              Identify Category
                     │
          ┌──────────┼──────────┐
          ▼          ▼          ▼
       GitHub     Terraform    Azure
          │          │          │
          └──────────┼──────────┘
                     ▼
                 Root Cause
                     │
                     ▼
                    Fix
                     │
                     ▼
             Test Locally
                     │
                     ▼
                   Commit
                     │
                     ▼
                    Push
                     │
                     ▼
               Pipeline Retry
                     │
                     ▼
                 Verify Logs
```

---

# 🧠 Step 43 — Golden Rules
Rule 01

❌ Error देखकर तुरंत code मत बदलो।

पहले log पढ़ो।

Rule 02

🔍 Failed step identify करो।

पूरी pipeline को एक साथ debug मत करो।

Rule 03

🎯 First real error खोजो।

Final exit code 1 को Root Cause मत समझो।

Rule 04

🧪 Local reproduction करो।

अगर possible हो तो वही command local चलाओ।

Rule 05

🚫 CI/CD में interactive commands avoid करो।

Example:

terraform plan -input=false
Rule 06

---

# 🔐 Secrets को Git में commit मत करो।

Use:

GitHub Secrets
+
OIDC
+
Azure Entra ID
Rule 07

# ⚡ Fast Failure अच्छा है।

Pipeline:

Fail in 30 seconds

बेहतर है:

Hang for 5 hours

---

# 🏆 Step 44 — What We Learned

इस Phase के बाद हमें पता है:

```text

GitHub Actions
      ↓
Runner
      ↓
Checkout
      ↓
Terraform Setup
      ↓
Terraform Format
      ↓
Terraform Init
      ↓
Terraform Validate
      ↓
Terraform Plan
      ↓
Azure Authentication
      ↓
Terraform Apply

और हर stage पर:

क्या हो रहा है?
क्या log देखना है?
क्या failure हो सकता है?
Root Cause कैसे निकालना है?

अब हम यह समझ सकते हैं।
```

---


# 🚀 Step 45 — Next Phase

अब हमारा foundation तैयार है।

अगले चरण में:

```text

Phase 11
   │
   ▼
🔐 GitHub OIDC Authentication
   │
   ▼
Microsoft Entra ID
   │
   ▼
Federated Credential
   │
   ▼
Azure Login
   │
   ▼
Terraform
   │
   ▼
Azure Subscription

इसके बाद:

Terraform Plan
       ↓
Pull Request
       ↓
Approval
       ↓
Merge to main
       ↓
Terraform Apply
       ↓
Azure Infrastructure 🚀
```

---

# 🎓 Final Takeaway

सबसे important चीज जो इस Phase से सीखनी है:

CI/CD Engineer का काम सिर्फ pipeline लिखना नहीं है।

```text 

Pipeline क्यों fail हुई?

Pipeline कहाँ fail हुई?

Pipeline क्यों hang हुई?

Runner के अंदर क्या हुआ?

Terraform को कौन-सी value चाहिए?

Azure authentication क्यों fail हुई?

कौन-सा error Root Cause है?

और सही fix क्या है?


यही असली DevOps Troubleshooting है।
```

---


# 🏁 Phase 10 Complete

```text 

हमने सीखा:
✅ NIC module error troubleshooting
✅ Terraform output/reference mismatch
✅ .tfvars और .gitignore
✅ Missing Terraform variables
✅ Pipeline hang troubleshooting
✅ terraform plan -input=false
✅ GitHub Runner behavior
✅ Azure authentication problem
✅ GitHub Actions logs reading
✅ Failed step identification
✅ Warning vs Error
✅ Multiple workflow runs
✅ Workflow cancellation
✅ Terraform Init/Validate/Plan troubleshooting
✅ Root Cause Analysis
✅ Local vs CI environment differences
✅ Production-style troubleshooting mindset
<p align="center">
🚀 From "Pipeline Failed" → "I Know Why It Failed"
🛠️ Observe → Diagnose → Fix → Test → Automate
</p> ```