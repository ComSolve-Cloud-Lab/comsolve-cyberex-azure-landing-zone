# 🔐 Phase 11 — GitHub → Azure OIDC Authentication

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Actions-181717?style=for-the-badge&logo=github)
![Azure](https://img.shields.io/badge/Microsoft-Azure-0078D4?style=for-the-badge&logo=microsoftazure)
![OIDC](https://img.shields.io/badge/OIDC-Secure%20Authentication-success?style=for-the-badge)
![Terraform](https://img.shields.io/badge/Terraform-Automation-7B42BC?style=for-the-badge&logo=terraform)

</p>

> 🎯 **Objective:** GitHub Actions को Azure से securely authenticate करना — बिना Client Secret के।

---

# 🧭 Phase 11 Overview

इस Phase में हम सीखेंगे:

- 🔐 GitHub OIDC क्या है
- 🔑 Federated Credential कैसे काम करता है
- 🐙 GitHub Repository Variables कैसे बनाते हैं
- ⚙️ GitHub Actions में Azure Login कैसे configure करते हैं
- ☁️ Azure Authentication को Terraform के साथ कैसे use करते हैं
- 🚨 Authentication errors को कैसे troubleshoot करते हैं
- 🛡️ Client Secret के बिना secure CI authentication

---

# 🏗️ Complete Architecture

```text
                    🐙 GitHub
                       │
                       ▼
                GitHub Actions
                       │
                       ▼
                  🔐 OIDC Token
                       │
                       ▼
              Microsoft Entra ID
                       │
                Federated Trust
                       │
                       ▼
             App Registration / SP
                       │
                  Contributor
                       │
                       ▼
               ☁️ Azure Subscription
                       │
                       ▼
                   Terraform
                       │
             ┌─────────┼─────────┐
             ▼         ▼         ▼
            RG        VNet       NIC
```

---

# 🧩 Step 00 — Complete Terraform CI YAML

अब हमारी complete workflow इस प्रकार होगी:

```text

# ==============================================================================
      # ------------------------------------------------------------------------


      - name: Checkout Repository


        uses: actions/checkout@v4


      # ------------------------------------------------------------------------
      # Step 02 — Azure OIDC Login
      # ------------------------------------------------------------------------


      - name: Azure Login


        uses: azure/login@v2


        with:


          client-id: ${{ vars.AZURE_CLIENT_ID }}


          tenant-id: ${{ vars.AZURE_TENANT_ID }}


          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}


      # ------------------------------------------------------------------------
      # Step 03 — Verify Azure Login
      # ------------------------------------------------------------------------


      - name: Verify Azure Login


        run: az account show


      # ------------------------------------------------------------------------
      # Step 04 — Verify Azure Subscription
      # ------------------------------------------------------------------------


      - name: Verify Azure Subscription


        run: az account show --query "{subscription:id, tenant:tenantId, user:user.name}"


      # ------------------------------------------------------------------------
      # Step 05 — Setup Terraform
      # ------------------------------------------------------------------------


      - name: Setup Terraform


        uses: hashicorp/setup-terraform@v3


      # ------------------------------------------------------------------------
      # Step 06 — Terraform Format Check
      # ------------------------------------------------------------------------


      - name: Terraform Format Check


        run: terraform fmt -check -recursive


      # ------------------------------------------------------------------------
      # Step 07 — Terraform Init
      # ------------------------------------------------------------------------


      - name: Terraform Init


        run: terraform init


      # ------------------------------------------------------------------------
      # Step 08 — Terraform Validate
      # ------------------------------------------------------------------------


      - name: Terraform Validate


        run: terraform validate


      # ------------------------------------------------------------------------
      # Step 09 — Terraform Plan
      # ------------------------------------------------------------------------


      - name: Terraform Plan


        run: terraform plan -input=false

```

---

# 🐙 Step 01 — GitHub Repository Settings खोलें

```text

अपने GitHub Repository में जाएँ:

Repository
   ↓
Settings
   ↓
Secrets and variables
   ↓
Actions
```

यहाँ आपको दो options मिलेंगे:

🔐 Secrets

📦 Variables

---

# 📦 Step 02 — Repository Variables बनाएं

हम sensitive credentials store नहीं करेंगे।

Variables में जाएँ:

Path:

```text

Settings
   ↓
Secrets and variables
   ↓
Actions
   ↓
Variables
   ↓
New repository variable
``` 
अब ये 3 variables बनाएं:

- Variable Name	Value

- AZURE_CLIENT_ID : ------->	App Registration → Application (client) ID

- AZURE_TENANT_ID : ------->    Azure → Directory (tenant) ID

- AZURE_SUBSCRIPTION_ID  : -------->	Azure Subscription ID



🧠 **याद रखें**

```text

Client ID
    ↓
कौन-सी Application Azure से login करेगी?


Tenant ID
    ↓
किस Microsoft Entra Directory में login करना है?


Subscription ID
    ↓
किस Azure Subscription में काम करना है?

```

```text

🔑 Client ID

कौन-सी Azure Application authenticate करेगी?

यह App Registration का:

Application (client) ID

है।

🏢 Tenant ID
किस Microsoft Entra ID Directory में authentication होगा?

यह:

Directory (tenant) ID

है।

☁️ Subscription ID
किस Azure Subscription में Terraform resources manage करेगा?

यह:

Azure Subscription ID

है।
```

---


# 🔐 Step 03 — Secrets और Variables में Difference

**🔒 Secrets**

Sensitive information के लिए:

```text

Client Secret
Password
API Token
Private Key

```
---

**📦 Variables**

```text

Non-sensitive configuration के लिए:

Client ID
Tenant ID
Subscription ID

```

**🛡️ लेकिन हमारे current OIDC architecture में:**

❌ Client Secret की जरूरत नहीं

क्योंकि GitHub Actions OIDC token के जरिए Azure authentication करेगा।

```text

GitHub OIDC
      ↓
Microsoft Entra ID
      ↓
Federated Credential

```
---

# ⚙️ Step 04 — GitHub Workflow में OIDC Permission दें

अपनी YAML workflow file खोलें:

```text

.github/
└── workflows/
    └── terraform-ci.yml

Workflow में यह permission जरूरी है:

permissions:

  id-token: write

  contents: read
  ```
  ---

**🧠 इसका मतलब**

```text
contents: read
        ↓
GitHub Repository को checkout करने की permission


id-token: write
        ↓
GitHub Actions को OIDC token लेने की permission

⭐ OIDC authentication का सबसे important हिस्सा id-token: write है।
```
---

**🧠 contents: read क्या करता है?**

```text

contents: read
       ↓
GitHub Repository को checkout/read करने की permission

इससे:

actions/checkout@v4

repository को runner पर checkout कर सकता है।

```
---

**🔐 id-token: write क्या करता है?**

```text

यह सबसे important permission है।

id-token: write
       ↓
GitHub Actions OIDC Token request कर सकता है
```

यही token Azure authentication में इस्तेमाल होगा।

---

# 🔑 Step 05 — Azure Login Action Add करें

Terraform commands से पहले Azure Login step रखें:

```text

 name: Azure Login

  uses: azure/login@v2

  with:


    client-id: ${{ vars.AZURE_CLIENT_ID }}


    tenant-id: ${{ vars.AZURE_TENANT_ID }}


    subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}

```
---

**🧠 यहाँ क्या हो रहा है?**
```text
GitHub Actions
      ↓
GitHub OIDC Token
      ↓
Microsoft Entra ID
      ↓
Federated Credential Check
      ↓
Azure Authentication

अगर Federated Credential match हो गया:

✅ GitHub → Azure Login Successful

```

---

# 🧪 Step 06 — Azure Login Test करें

Azure Login के तुरंत बाद temporary test step डालें:

- name: Verify Azure Login

  run: az account show

इससे GitHub Runner बताएगा कि वह किस Azure account/subscription से authenticated है।

इसका purpose है verify करना कि GitHub Runner Azure से successfully authenticated है।

Expected output में Azure account/subscription information दिखाई देगी।

Expected:

Subscription
Tenant
User / Service Principal

**🎯 इसका purpose**

हम पहले यह verify कर रहे हैं:

```text

GitHub
  ↓
OIDC
  ↓
Azure Login
  ↓
SUCCESS

```

इसके बाद ही Terraform चलाना चाहिए।

---

# 🧪 Step 07 — Azure Subscription Verify करें

```text

और detailed verification के लिए:

- name: Verify Azure Subscription
  run: az account show --query "{subscription:id, tenant:tenantId, user:user.name}"

इससे specifically check कर सकते हैं:

Subscription ID
Tenant ID
Authenticated Identity

```

---

# 🏗️ Step 08 — Terraform Authentication समझें

Azure Login successful होने के बाद Terraform AzureRM provider के जरिए Azure से communicate कर सकता है।

Complete flow:

```text

GitHub Actions
      │
      ▼
Azure Login
      │
      ▼
Azure Authentication
      │
      ▼
Terraform
      │
      ▼
AzureRM Provider
      │
      ▼
Azure Resources
```

***🧠 Important***
```text

Local machine पर हम normally:

az login

करते हैं।

```
लेकिन GitHub Actions का Runner temporary environment होता है।

इसलिए:

```text

❌ GitHub Runner पर manually az login नहीं

हमारा सही तरीका:

GitHub Actions
      ↓
OIDC
      ↓
Microsoft Entra ID
      ↓
azure/login@v2
      ↓
Terraform

```

---

# 🔍 Step 09 — GitHub Actions में Pipeline Check करें

अब GitHub पर जाएँ:

```text

Repository
   ↓
Actions
   ↓
Terraform CI
   ↓
Latest Workflow Run
```

यहाँ हर step का status देखेंगे:

✓ Checkout Repository


✓ Setup Terraform


✓ Azure Login


✓ Terraform Format Check


✓ Terraform Init


✓ Terraform Validate


✓ Terraform Plan

***🎯 Pipeline में क्या देखना है?***

हर step के सामने:

**🟢 Success**
**🔴 Failed**
**🟡 Running**

देखें।

विशेष रूप से:

```text

Azure Login
     ↓
     PASS


Terraform Init
     ↓
     PASS


Terraform Validate
     ↓
     PASS


Terraform Plan
     ↓
     PASS
```
---


# 🚨 Step 10 — Authentication Failure Troubleshooting

अगर यह error आए:

AADSTS70021

या:

No matching federated identity record found

तो सबसे पहले Azure में Federated Credential check करें।

Path:

```text

Azure Portal
   ↓
Microsoft Entra ID
   ↓
App registrations
   ↓
Shrikant_Nadgauda_GitHub_Actions
   ↓
Certificates & secrets
   ↓
Federated credentials
```

**इन values को verify करें:**

Issuer

Organization

Organization ID

Repository

Repository ID

Entity Type

Branch

Audience


---

# 🔎 Step 11 — Federated Credential कैसे Match होता है?

GitHub Actions Azure को identity information देता है।

Azure Federated Credential उस information को verify करता है।

```text

Conceptually:

GitHub
  │
  ├── Organization
  ├── Repository
  ├── Branch
  ├── Issuer
  └── Audience
        │
        ▼
Microsoft Entra ID
        │
        ▼
Federated Credential
        │
        ├── Match ✅
        │
        └── No Match ❌

अगर values match नहीं हुईं:

❌ Azure Authentication Failed

```

---

# 🚨 Step 12 — az login Error को समझें

अगर GitHub Actions में यह error आए:

```text

Please run 'az login' to setup account.
```

तो तुरंत अपने laptop पर az login करने की जरूरत नहीं है।

पहले check करें:

```text

GitHub Workflow
       ↓
Azure Login step मौजूद है?
       ↓
id-token: write है?
       ↓
Client ID सही है?
       ↓
Tenant ID सही है?
       ↓
Subscription ID सही है?
       ↓
Federated Credential सही है?
```

***❌ गलत Flow***

```text

GitHub Runner
      ↓
terraform plan
      ↓
az login required ❌
```

***✅ सही Flow***
```text
GitHub Runner
      ↓
OIDC Token
      ↓
azure/login@v2
      ↓
Azure Authentication
      ↓
terraform plan
      ↓
SUCCESS ✅

``` 

# 🔐Client Secret क्यों नहीं इस्तेमाल कर रहे?

Traditional authentication:

```text

GitHub
   │
   ├── Client ID
   ├── Tenant ID
   ├── Subscription ID
   └── Client Secret 🔑
```

इसमें long-lived secret manage करना पड़ता है।

```text

हमारा architecture:

GitHub
   │
   ▼
OIDC Token
   │
   ▼
Microsoft Entra ID
   │
   ▼
Federated Credential
   │
   ▼
Temporary Azure Authentication
   │
   ▼
Terraform
```

---

# 🛡️ OIDC के Benefits


✅ No Client Secret

✅ No Password

✅ No long-lived credential

✅ No secret rotation

✅ Branch-based trust

✅ Repository-based trust

✅ Better CI/CD security

---

# 🏆 Phase 11 — Final Architecture

```text
                    🐙 GitHub
                       │
                       ▼
                GitHub Actions
                       │
                       ▼
                  🔐 OIDC Token
                       │
                       ▼
              Microsoft Entra ID
                       │
                Federated Trust
                       │
                       ▼
             App Registration / SP
                       │
                  Contributor
                       │
                       ▼
               ☁️ Azure Subscription
                       │
                       ▼
                   Terraform
                       │
             ┌─────────┼─────────┐
             ▼         ▼         ▼
            RG        VNet       NIC
```

***🔐 सबसे important rule***

❌ Client Secret GitHub Repository में नहीं

❌ Password code में नहीं

❌ Azure credentials Terraform code में नहीं

❌ Secrets को Git में commit नहीं करना

✅ GitHub OIDC

✅ Federated Credential

✅ Repository Variables

✅ Branch-based trust

✅ Temporary authentication

***🎯 Phase 11 का लक्ष्य: GitHub Actions को secure, secretless और branch-aware तरीके से Azure से authenticate करना।***

---

🚀 Phase 11 Final Goal

Phase 11 complete होने के बाद हमारा authentication flow:

```text

Developer
    │
    │ git push
    ▼
Feature Branch
    │
    ▼
GitHub Actions
    │
    ▼
OIDC Token
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
Terraform Plan
```
***🔐 Security Rules***

⚠️ इन rules को हमेशा follow करें:

❌ Client Secret GitHub Repository में commit नहीं करना


❌ Password code में नहीं रखना


❌ Azure credentials Terraform code में hard-code नहीं करना


❌ Secrets को Git में commit नहीं करना


❌ terraform.tfvars में secrets रखकर GitHub पर push नहीं करना

इसके बजाय:

✅ GitHub OIDC


✅ Federated Credential


✅ GitHub Repository Variables


✅ Branch-based Trust


✅ Short-lived Authentication

📚 What We Learned

इस Phase में हमने सीखा:

🔐 OIDC क्या है

🔑 Federated Credential क्या करता है

🐙 GitHub Actions Azure से कैसे authenticate करता है

📦 GitHub Repository Variables क्या हैं

🔒 GitHub Secrets कब इस्तेमाल करने चाहिए

⚙️ azure/login@v2 कैसे काम करता है

🪪 id-token: write क्यों जरूरी है

☁️ Azure Login को Terraform के साथ कैसे use करते हैं

🚨 Authentication failures को कैसे troubleshoot करते हैं

🛡️ Client Secret के बिना secure CI/CD authentication

---
# 🔜 Next Phase
# 🚀 Phase 12 — Secure Terraform Plan Pipeline

अगले Phase में हम बनाएँगे:

```text

Feature Branch
      ↓
GitHub Actions
      ↓
OIDC Login
      ↓
Terraform fmt
      ↓
Terraform init
      ↓
Terraform validate
      ↓
Security Scan
      ↓
Terraform Plan
      ↓
Plan Artifact
      ↓
Pull Request Review

इसके बाद deployment flow:

main
  ↓
Approval
  ↓
Terraform Apply
  ↓
☁️ Azure Infrastructure
```


<p align="center">
🔐 Secure Authentication → 🏗️ Terraform → ☁️ Azure

Infrastructure as Code • Secure CI/CD • GitHub OIDC

</p> ```