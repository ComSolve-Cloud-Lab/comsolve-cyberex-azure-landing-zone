# 🚀 Phase 13 — Azure OIDC Troubleshooting & GitHub Actions Pipeline Recovery

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-OIDC-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-CI%2FCD-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Security](https://img.shields.io/badge/Security-Troubleshooting-success?style=for-the-badge)

</p>

> 🎯 **Objective:** इस Phase में हमने GitHub Actions → Microsoft Entra ID → Azure OIDC authentication failure को troubleshoot किया और successfully Terraform pipeline को Azure के साथ authenticate कराया।

---

# 🧭 Phase 13 Overview

इस Phase में हमारा focus नया infrastructure बनाना नहीं था।

हमारा focus था:

```text
❌ Pipeline क्यों fail हुई?
        ↓
🔍 Logs में actual error क्या था?
        ↓
🧠 Error का मतलब क्या था?
        ↓
🔐 Azure OIDC configuration check
        ↓
🔗 Federated Credential verify
        ↓
🔄 Failed Job Re-run
        ↓
✅ Pipeline Successful
```

🏗️ Starting Architecture

हमारा pipeline flow:

🐙 GitHub
     │
     ▼
⚙️ GitHub Actions
     │
     ▼
📥 Checkout Repository
     │
     ▼
🔐 Azure OIDC Login
     │
     ▼
Microsoft Entra ID
     │
     ▼
Federated Credential
     │
     ▼
☁️ Azure
     │
     ▼
Terraform
     │
     ├── terraform fmt
     ├── terraform init
     ├── terraform validate
     └── terraform plan
🚨 Step 01 — Azure Login Failure

Pipeline में Azure Login step पर error आया:

AADSTS700213:
No matching federated identity record found

इसके साथ Azure ने यह भी बताया:

Check your federated identity credential
Subject, Audience and Issuer
🔍 Step 02 — Error को कैसे पढ़ें?

सबसे पहले पूरी log देखने के बजाय actual error line identify करनी चाहिए।

हमारे case में:

No matching federated identity record found

इसका simple मतलब:

GitHub ने Azure को OIDC token भेजा, लेकिन Microsoft Entra ID में उस token के लिए matching Federated Credential नहीं मिला।

🧠 Step 03 — OIDC क्या Check करता है?

GitHub Actions से आने वाले token में important information होती है:

Issuer
Subject
Audience

Azure में Federated Credential भी इन्हीं values के आधार पर trust establish करता है।

Simple flow:

GitHub OIDC Token
       │
       ├── Issuer
       ├── Subject
       └── Audience
       │
       ▼
Microsoft Entra ID
       │
       ▼
Federated Credential Match?
       │
   ┌───┴────┐
   │        │
  YES       NO
   │        │
   ▼        ▼
 Azure    ❌ Login Failed
🔎 Step 04 — GitHub ने कौन सा Subject भेजा?

Pipeline log में हमें actual subject मिला:

repo:Shrikant-Nadgaudaa@247837213/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/nic-infrastructure

इससे हमें पता चला कि GitHub Actions किस repository और किस branch से run हो रहा है।

🧩 Step 05 — Subject को Break करके समझना

Subject को समझें:

repo:
Shrikant-Nadgaudaa@247837213
/
comsolve-cyberex-azure-landing-zone@1338145312
:
ref:
refs/heads/feature/nic-infrastructure

इसमें:

Organization/User
        ↓
Shrikant-Nadgaudaa@247837213


Repository
        ↓
comsolve-cyberex-azure-landing-zone@1338145312


Branch
        ↓
feature/nic-infrastructure

यानी pipeline वास्तव में:

feature/nic-infrastructure

branch से run हुई थी।

🔐 Step 06 — Azure Federated Credential Check

Azure Portal में:

Microsoft Entra ID
        ↓
App registrations
        ↓
Terraform App Registration
        ↓
Certificates & secrets
        ↓
Federated credentials

Existing credential check किया गया।

🔑 Step 07 — Important OIDC Values

हमने इन तीन values को verify किया:

Issuer
https://token.actions.githubusercontent.com
Audience
api://AzureADTokenExchange
Subject

हमारे workflow के लिए:

repo:Shrikant-Nadgaudaa@247837213/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/nic-infrastructure
⚠️ Step 08 — Duplicate Federated Credential Error

Credential दोबारा create करने पर Azure ने error दिया:

The combination of issuer and subject must be unique

इसका मतलब:

Issuer + Subject
        ↓
Already Exists

इसलिए हमने नया duplicate credential create नहीं किया।

हमने existing Federated Credential को verify किया।

🧠 Step 09 — Important Lesson

इस error का मतलब यह नहीं था कि:

❌ Azure App Registration खराब है
❌ Terraform खराब है
❌ GitHub Actions खराब है

Actual problem authentication trust matching से related थी।

इसलिए troubleshooting हमेशा इस order में करें:

1. Read actual error
       ↓
2. Identify failing step
       ↓
3. Check GitHub OIDC values
       ↓
4. Check Azure Federated Credential
       ↓
5. Compare Issuer
       ↓
6. Compare Subject
       ↓
7. Compare Audience
       ↓
8. Re-run workflow
🌿 Step 10 — Branch Important क्यों थी?

हमने workflow में feature branches के लिए trigger रखा:

on:


  push:
    branches:
      - "feature/**"

इसका मतलब:

feature/nic-infrastructure
feature/vnet
feature/subnet
feature/test

जैसी branches पर push होने पर workflow trigger हो सकता है।

🔄 Step 11 — Pipeline को दोबारा कैसे चलाएँ?

अगर code में कोई नया change नहीं किया और problem configuration side पर fix हो गई है, तो नया commit/push जरूरी नहीं है।

GitHub में:

Repository
    ↓
Actions
    ↓
Terraform CI
    ↓
Failed Workflow Run
    ↓
Re-run jobs

ऊपर right side में:

Re-run all jobs
Re-run failed jobs

जैसे options दिखाई दे सकते हैं।

🎯 Step 12 — Re-run Failed Jobs

हमने:

Re-run failed jobs

select किया।

इसका फायदा:

Failed Job
    ↓
Same Workflow
    ↓
Failed Job Again

पूरे workflow को unnecessary तरीके से दोबारा चलाने के बजाय failed jobs को retry किया जा सकता है।

✅ Step 13 — Successful Azure Login

Re-run के बाद Azure Login successfully हुआ:

Run azure/login@v2


Running Azure CLI Login.


Attempting Azure CLI login by using OIDC...

यह important milestone था।

इसका मतलब:

GitHub
   ↓
OIDC Token
   ↓
Microsoft Entra ID
   ↓
Federated Credential
   ↓
Azure Authentication

successfully काम कर रहा था।

🏗️ Step 14 — Terraform Init Successful

Pipeline में:

Run terraform init

successfully execute हुआ।

Output:

Terraform has been successfully initialized!

Modules भी initialize हुए:

subnets
vnet
nics
resource_groups
✅ Step 15 — Terraform Validate

Validation successful:

Success! The configuration is valid.

इसका मतलब Terraform configuration syntactically और structurally valid थी।

📋 Step 16 — Terraform Plan

Terraform plan successfully execute हुआ:

Plan: 10 to add, 0 to change, 0 to destroy.

इसका मतलब:

10 resources → Create
0 resources  → Change
0 resources  → Destroy

Terraform ने infrastructure को modify नहीं किया।

इस stage पर केवल execution plan generate हुआ।

⚠️ Step 17 — Node.js 20 Warning

Pipeline logs में warning भी दिखाई दी:

Node 20 is deprecated

यह हमारी Terraform configuration की failure नहीं थी।

यह GitHub Actions runtime/dependency compatibility warning थी।

Important:

Warning ≠ Pipeline Failure

अगर job green है और Terraform steps successful हैं, तो केवल इस warning की वजह से pipeline को failed नहीं मानना चाहिए।

🧹 Step 18 — Diagnostic Logs

GitHub Actions ने diagnostic information भी दिखाई:

Diagnostic file upload complete
Completed runner diagnostic log upload

और cleanup:

Cleaning up orphan processes

यह GitHub Runner का cleanup/diagnostic process है।

🔄 Step 19 — पूरी Troubleshooting Journey

हमारी actual troubleshooting:

Pipeline Failed
      │
      ▼
Azure Login Error
      │
      ▼
AADSTS700213
      │
      ▼
No Matching Federated Identity
      │
      ▼
Read GitHub OIDC Subject
      │
      ▼
Compare Azure Federated Credential
      │
      ▼
Existing Credential Found
      │
      ▼
Duplicate Credential Error
      │
      ▼
Existing Credential Verify
      │
      ▼
Re-run Failed Jobs
      │
      ▼
Azure Login Successful
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
✅ SUCCESS
🔥 Step 20 — अगर Pipeline Fail हो जाए तो क्या करें?

हर बार नया code लिखने या नया commit करने की जरूरत नहीं होती।

पहले identify करें:

❓ कौन सा Step Fail हुआ?

फिर उसके logs देखें।

Example:

Azure Login
     ↓
Authentication Error

तो Azure OIDC configuration check करें।

अगर:

Terraform Validate
     ↓
Failed

तो Terraform code check करें।

अगर:

Terraform Plan
     ↓
Failed

तो variables, authentication, provider या infrastructure configuration check करें।

🧪 Step 21 — Pipeline Logs पढ़ने का तरीका

GitHub Actions में logs पढ़ते समय हमेशा यह order follow करें:

1️⃣ Job Name
Terraform Validation
2️⃣ Failed Step

Example:

Run Azure Login
3️⃣ Actual Error

Example:

AADSTS700213
4️⃣ Error Meaning
Federated Credential Matching Failure
5️⃣ Root Cause
Issuer / Subject / Audience mismatch
6️⃣ Fix
Azure Federated Credential verify
7️⃣ Re-run
Re-run failed jobs
🏆 Final Successful Pipeline

हमारी final pipeline:

🐙 GitHub
      │
      ▼
⚙️ GitHub Actions
      │
      ▼
📥 Checkout
      │
      ▼
🔐 Azure OIDC Login
      │
      ▼
🧪 Azure Authentication
      │
      ▼
🏗️ Terraform Setup
      │
      ▼
✨ Terraform Format
      │
      ▼
📦 Terraform Init
      │
      ▼
✅ Terraform Validate
      │
      ▼
📋 Terraform Plan
      │
      ▼
☁️ Azure
📚 What We Learned

इस Phase में हमने सीखा:

🔍 GitHub Actions logs कैसे पढ़ें
🚨 Actual error और warning में difference
🔐 Azure OIDC authentication troubleshooting
🧩 Federated Credential matching
🌿 Branch-specific OIDC trust
🔑 Issuer क्या है
🎯 Subject क्या है
👥 Repository/Branch identity कैसे verify करें
🛡️ Audience क्या है
🔄 Failed workflow को कैसे re-run करें
🧪 Terraform Init logs कैसे पढ़ें
✅ Terraform Validate output कैसे समझें
📋 Terraform Plan output कैसे समझें
⚠️ GitHub Actions runtime warnings को कैसे identify करें
🎯 Phase 13 Key Takeaway

Pipeline failure देखकर तुरंत code change नहीं करना है।

पहले:

Read Logs
   ↓
Find Failed Step
   ↓
Read Actual Error
   ↓
Understand Root Cause
   ↓
Fix Configuration / Code
   ↓
Re-run
   ↓
Verify Result

यही real-world DevOps troubleshooting approach है।

🔜 Next Phase — Phase 14

अब authentication और Terraform CI pipeline successfully काम कर रही है।

अगला focus होगा:

🛡️ Security Automation

हम pipeline में security checks जोड़ेंगे:

Git Push
    ↓
GitHub Actions
    ↓
Azure OIDC
    ↓
Terraform fmt
    ↓
Terraform init
    ↓
Terraform validate
    ↓
🔍 Terraform Security Scan
    ↓
🔍 IaC Misconfiguration Scan
    ↓
📋 Terraform Plan
    ↓
✅ Security Gate
🔐 Security Tools

इस project के लिए शुरुआत में:

🐳 Trivy

Container + IaC + filesystem security scanning के लिए।

🔍 Checkov

Terraform / Infrastructure-as-Code security misconfiguration scanning के लिए।

बाद में enterprise security platforms जैसे:

Prisma Cloud
Black Duck
Aqua Security

को समझ सकते हैं।

🚀 Phase 14 Goal

हमारा goal होगा:

Developer
    │
    ▼
Git Push
    │
    ▼
GitHub Actions
    │
    ├── Terraform Format
    ├── Terraform Validate
    ├── Checkov 🔍
    ├── Trivy 🔍
    └── Terraform Plan
             │
             ▼
       Security Gate
             │
        ┌────┴────┐
        ▼         ▼
      PASS       FAIL
        │         │
        ▼         ▼
   Continue     Stop

🎯 Goal: Infrastructure को Azure में deploy करने से पहले automated security validation करना।