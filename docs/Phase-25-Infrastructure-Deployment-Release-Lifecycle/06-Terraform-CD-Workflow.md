# 🔄 Git Pull vs Local Changes — Complete Branch Synchronization Guide

<p align="center">

![Git](https://img.shields.io/badge/Git-Branching-orange?logo=git)
![GitHub](https://img.shields.io/badge/GitHub-Workflow-black?logo=github)
![Best Practice](https://img.shields.io/badge/Best%20Practice-Feature%20Branch-blue)
![Protected Main](https://img.shields.io/badge/Main-Protected-red)

</p>

---

## 🎯 Objective

इस document का उद्देश्य यह समझना है कि:

* Local `main` और remote `origin/main` अलग हों तो क्या करना है।
* Local branch में remote से ज्यादा commits हों तो `git pull` कर सकते हैं या नहीं।
* Local branch में extra files/code हों तो remote changes कैसे लेने हैं।
* नई `feature branch` बनाकर उसमें `origin/main` के latest changes कैसे लेने हैं।
* `git pull`, `git fetch`, `git merge` और `git rebase` का practical relationship क्या है।
* Protected `main` के साथ safest Git workflow क्या है।

---

# 🧠 सबसे पहले Golden Rule

> **Local branch में extra commits/files होना अपने आप में `git pull` को रोकता नहीं है।**

लेकिन यह देखना जरूरी है कि local और remote के बीच relationship क्या है।

तीन common situations होती हैं:

```text
Case 1:
Local पीछे है
        ↓
Remote आगे है
        ↓
git pull --ff-only
```

```text
Case 2:
Local आगे है
        ↓
Remote पीछे है
        ↓
git pull
        ↓
कुछ नया download नहीं होगा
```

```text
Case 3:
Local भी आगे + Remote भी आगे
        ↓
Branches diverged
        ↓
पहले decide करना होगा:
merge / rebase / reset
```

---

# 1️⃣ Case — Local Main Remote से पीछे है

Example:

```text
Remote main:

A ── B ── C ── D
              ↑
          origin/main

Local main:

A ── B ── C
          ↑
        main
```

यहाँ:

```text
Local main       = C
origin/main      = D
```

Local branch पीछे है।

### ✅ Solution

```powershell
git pull --ff-only origin main
```

इससे:

```text
A ── B ── C ── D
              ↑
          main + origin/main
```

दोनों synchronized हो जाते हैं।

---

# 2️⃣ Case — Local Main में Remote से ज्यादा Commits हैं

अब मान ले:

```text
Local main:

A ── B ── C ── D
              ↑
            main
```

Remote:

```text
A ── B ── C
          ↑
      origin/main
```

मतलब:

```text
Local main       = 4 commits
origin/main      = 3 commits
```

### ❓ क्या `git pull` कर सकते हैं?

### Technically: हाँ।

लेकिन यहाँ remote में नया commit नहीं है।

इसलिए:

```powershell
git pull origin main
```

remote से कोई नया commit आने वाला नहीं है।

Git essentially बताएगा कि local branch remote से आगे है।

### Important

`git pull` का मतलब:

```text
git fetch
+
git merge
```

अगर remote में नया commit ही नहीं है, तो merge करने के लिए कुछ नया नहीं है।

---

# 3️⃣ Case — Local में Extra Files हैं, लेकिन Extra Commits नहीं

यह थोड़ा अलग case है।

Example:

```text
Remote main:

A ── B ── C
```

Local:

```text
A ── B ── C
```

लेकिन local working directory में:

```text
new-file.tf
new-document.md
updated-code.tf
```

अभी ये files **commit नहीं हुई हैं**।

```text
Git status

Untracked files:
    new-file.tf

Modified:
    main.tf
```

### ❓ क्या `git pull` कर सकते हैं?

**कर सकते हैं, लेकिन सावधानी जरूरी है।**

अगर remote changes उन same files/lines को touch नहीं करते, Git अक्सर pull कर देगा।

लेकिन अगर local uncommitted changes और remote changes conflict करते हैं, Git pull रोक सकता है।

इसलिए best practice:

```powershell
git status
```

पहले देखो।

फिर जरूरत के हिसाब से:

```text
Commit
या
Stash
या
Discard
```

---

# 4️⃣ Case — Local में Extra Commits + Remote में भी Extra Commits

यह सबसे important situation है।

Example:

```text
                 D ── E
                ↑
              main

A ── B ── C
          \
           F ── G
                ↑
           origin/main
```

यहाँ:

```text
Local main       = D, E
origin/main      = F, G
```

दोनों branches अलग-अलग आगे बढ़ चुकी हैं।

इसे कहते हैं:

> **Branches have diverged**

अब blindly:

```powershell
git pull
```

नहीं करना चाहिए।

पहले decide करो कि local commits का क्या करना है।

Possible options:

```text
1. Merge
2. Rebase
3. Reset
4. Cherry-pick required commits
```

Protected `main` के case में अक्सर safest approach होता है:

```text
Local changes
      ↓
Feature Branch
      ↓
PR
      ↓
Review
      ↓
Approval
      ↓
Merge
```

---

# 5️⃣ अब सबसे Important Question

## ❓ अगर नई Feature Branch बनाएँ तो क्या Remote Main से Pull ले सकते हैं?

### ✅ हाँ, बिल्कुल।

और यही **recommended workflow** है।

मान लो:

```text
origin/main
      │
      ▼
latest main
      │
      ▼
feature/phase-25.06
```

पहले local main को latest remote main से sync करो:

```powershell
git switch main
git fetch origin
git pull --ff-only origin main
```

फिर नई feature branch:

```powershell
git switch -c feature/phase-25.06-cd-workflow
```

अब feature branch latest `main` से बनी है।

---

# 6️⃣ अगर Local Main में Remote Main से ज्यादा Files हों तो?

यहाँ **files और commits को अलग-अलग समझना जरूरी है।**

### Situation A — Extra files committed हैं

Example:

```text
Local main:

A ── B ── C ── D
              ↑
            main

Remote:

A ── B ── C
          ↑
      origin/main
```

यहाँ local में commit `D` है।

अगर तुम:

```powershell
git switch -c feature/test origin/main
```

करते हो, तो नई feature branch **remote main से बनेगी**, इसलिए local-only commit `D` उसमें नहीं आएगा।

यह बहुत useful है।

---

# 7️⃣ अगर Local Main में Extra Files/Changes हैं लेकिन उन्हें Feature Branch में ले जाना है

Example:

```text
Local main
   │
   ├── New Terraform code
   ├── New Markdown file
   └── Configuration changes
```

लेकिन ये changes अभी remote main में नहीं हैं।

तब directly main को push करने की कोशिश मत करो।

Better:

```text
Local main
    │
    │ changes
    ▼
Feature Branch
    │
    ▼
Commit
    │
    ▼
Push
    │
    ▼
Pull Request
    │
    ▼
Review
    │
    ▼
Approval
    │
    ▼
Merge into main
```

---

# 8️⃣ अगर Local Main Remote Main से ज्यादा है और मुझे सिर्फ Remote Main चाहिए?

तब:

```powershell
git fetch origin
git reset --hard origin/main
```

इसका मतलब:

> Local `main` को exactly `origin/main` जैसा बना दो।

### ⚠️ Important

यह local-only commits और uncommitted changes को हटाने/अलग करने वाला destructive operation हो सकता है।

इसलिए पहले:

```powershell
git status
git log --oneline origin/main..main
```

देखना जरूरी है।

जरूरत हो तो backup branch:

```powershell
git branch backup/local-main
```

बनाओ।

---

# 9️⃣ अगर Local Main में Extra Commit है लेकिन उसे बचाना है

Example:

```text
origin/main:

A ── B ── C

local main:

A ── B ── C ── D
```

और `D` में useful documentation/code है।

तब:

```powershell
git switch -c feature/my-change origin/main
```

फिर required commit:

```powershell
git cherry-pick D
```

अब:

```text
origin/main:

A ── B ── C

feature/my-change:

A ── B ── C ── D'
```

फिर:

```text
Push
 ↓
PR
 ↓
Review
 ↓
Approval
 ↓
Merge
```

यह protected `main` के लिए clean तरीका है।

---

# 🔟 हमारे Current Project में क्या हुआ?

हमारे project में अभी:

```text
Local main
      ↓
origin/main
```

Remote `main` पर Phase 25.05 merge हो चुका था।

हमने `fetch` किया और मिला:

```text
b7b66fc..37a885b
main -> origin/main
```

इसका मतलब:

```text
origin/main
    ↓
37a885b
```

आगे है।

और:

```powershell
git log --oneline origin/main..main
```

blank था।

इसका मतलब:

```text
Local main
    ↓
कोई unique commit नहीं
```

इसलिए सही action था:

```powershell
git switch main
git pull --ff-only origin main
```

---

# 1️⃣1️⃣ अभी जो Output आया उसका मतलब

तुम्हारे current output में:

```text
Switched to branch 'main'

Your branch is behind 'origin/main' by 3 commits,
and can be fast-forwarded.
```

यह Git का बहुत clear message है।

मतलब:

```text
Local main
A ── B ── C

Remote main
A ── B ── C ── D ── E ── F
```

इसलिए यहाँ:

```powershell
git pull --ff-only origin main
```

**safe और correct operation है**, क्योंकि Git ने खुद बताया है कि branch fast-forward हो सकती है।

---

# 1️⃣2️⃣ लेकिन एक Important Warning

तुम्हारे output में यह भी आया:

```text
M docs/Phase-25-Infrastructure-Deployment-Release-Lifecycle/06-Terraform-CD-Workflow.md
```

इसका मतलब:

> इस file में local working-tree modification है।

इसलिए अभी blindly `pull` करने से पहले इस modification को ध्यान में रखना चाहिए।

पहले:

```powershell
git status
```

और ideally:

```powershell
git diff -- docs/Phase-25-Infrastructure-Deployment-Release-Lifecycle/06-Terraform-CD-Workflow.md
```

देखो कि local change क्या है।

अगर यह Phase 25.06 का तुम्हारा नया work है, तो इसे खोना नहीं है।

---

# 🏆 Recommended Industry Workflow

जब भी नया Phase शुरू करना हो:

```text
                ┌────────────────────┐
                │ Check Current State│
                └─────────┬──────────┘
                          ↓
                   git status
                          ↓
                 git fetch origin
                          ↓
              Check main synchronization
                          ↓
                 Local main latest?
                    /           \
                  NO             YES
                  ↓               ↓
       git pull --ff-only       Continue
                  \               /
                   \             /
                    ▼           ▼
                  Create Feature Branch
                          ↓
                 Make New Changes
                          ↓
                    git status
                          ↓
                     git add
                          ↓
                  Review staged diff
                          ↓
                     git commit
                          ↓
                     git push
                          ↓
                       PR
                          ↓
                  CI + Code Review
                          ↓
                     Approval
                          ↓
                  Merge → main
```

---

# ⭐ Universal Golden Formula

हर नए feature, code, configuration या documentation change के लिए:

```text
CHECK
  ↓
SYNC MAIN
  ↓
CREATE FEATURE BRANCH
  ↓
MAKE CHANGES
  ↓
REVIEW
  ↓
COMMIT
  ↓
PUSH
  ↓
PULL REQUEST
  ↓
REVIEW + APPROVAL
  ↓
MERGE
  ↓
MAIN
```

### सबसे important बात:

> **`git pull` को इस तरह मत समझो कि “अगर local में कुछ extra है तो pull नहीं कर सकते।”**

सही सवाल यह है:

> **Local और remote की commit history कैसी है — behind, ahead, या diverged?**

और दूसरा:

> **Local working tree में uncommitted changes हैं या नहीं?**

इन्हीं दो चीजों को देखकर सही Git action decide होता है।

---

# 🚀 Phase 25.06 — Pre-Implementation Git Workflow

## 🎯 Objective

Phase 25.06 का नया code add करने से पहले यह सुनिश्चित करना है कि local repository का `main` branch latest `origin/main` के साथ synchronized हो।

इसके बाद Phase 25.06 के लिए एक **नई feature branch** बनाई जाएगी।

हम existing `main` branch में direct changes नहीं करेंगे।

---

# 🔐 Golden Rule

```text
origin/main
    ↓
Local main sync
    ↓
New Feature Branch
    ↓
Phase 25.06 Changes
```

**Protected `main` branch पर direct development नहीं करना है।**

---

# 🧪 Step 1 — Existing Changes Cross-Check

सबसे पहले verify करेंगे कि:

* Phase 25.05 CD foundation merged है
* `terraform-cd.yml` का existing foundation सही है
* `main` branch clean है
* कोई unwanted local change pending नहीं है
* Remote `origin/main` latest है

---

# 🔄 Step 2 — Remote Main से Latest Code लेना

**Pehle sirf check karenge ki local main aur remote origin/main already sync hain ya nahi.**

```text
git status

git branch --show-current

git fetch origin --prune

git log --oneline main..origin/main

git log --oneline origin/main..main
```
हम पहले remote repository से latest information fetch करेंगे।

```powershell
git fetch origin --prune
git switch main
git pull --ff-only origin main
git status
```

### Expected Result

```text
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

इसका मतलब local `main` और remote `origin/main` synchronized हैं।

---

# 🌿 Step 3 — Phase 25.06 की नई Feature Branch बनाना

Latest `main` से नई branch बनाई जाएगी।

```powershell
git switch -c feature/phase-25.06-terraform-cd-workflow
git branch
git status
```

Expected:

```text
* feature/phase-25.06-terraform-cd-workflow
  main
```

अब हमारा काम नई feature branch में होगा।

---

# 📁 Step 4 — Phase 25.06 Changes

अब इसी नई branch में:

```text
docs/
└── Phase-25-Infrastructure-Deployment-Release-Lifecycle/
    └── 06-Terraform-CD-Workflow.md
```

file तैयार की जाएगी।

इसके साथ Phase 25.06 के requirement के अनुसार:

```text
.github/
└── workflows/
    └── terraform-cd.yml
```

में required CD workflow changes किए जाएंगे।

---

# 🔧 Step 5 — Workflow Development

Current CD foundation:

```text
Checkout
   ↓
Azure OIDC Login
   ↓
Azure Verification
   ↓
Terraform Setup
   ↓
Terraform Init
   ↓
Terraform Plan
```

Phase 25.06 में इसे आगे बढ़ाया जाएगा:

```text
Checkout
   ↓
Azure OIDC Login
   ↓
Azure Verification
   ↓
Terraform Setup
   ↓
Terraform Init
   ↓
Terraform Plan
   ↓
Deployment Approval
   ↓
Terraform Apply
```

---

# 🧪 Step 6 — Local Change Validation

Changes करने के बाद सबसे पहले working tree check करेंगे:

```powershell
git status
git diff
git diff --cached
```

इसके बाद YAML structure और Terraform workflow को review किया जाएगा।

---

# 📦 Step 7 — Commit

जब changes properly reviewed और tested हों:

```powershell
git add .github/workflows/terraform-cd.yml
git add "docs/Phase-25-Infrastructure-Deployment-Release-Lifecycle/06-Terraform-CD-Workflow.md"

git commit -m "feat: implement Terraform CD workflow"
```

---

# 🚀 Step 8 — Feature Branch Push

नई feature branch को remote पर push करेंगे:

```powershell
git push -u origin feature/phase-25.06-terraform-cd-workflow
```

इससे remote पर automatically branch create हो जाएगी।

---

# 🔀 Step 9 — Pull Request

इसके बाद:

```text
feature/phase-25.06-terraform-cd-workflow
                 ↓
                PR
                 ↓
               main
```

PR में:

* CI checks
* Terraform validation
* Security scan
* Code review
* Required approval

complete होने के बाद ही merge किया जाएगा।

---

# 🎯 Expected Result

Phase 25.06 development शुरू करने से पहले:

```text
✅ origin/main latest
✅ local main synchronized
✅ main clean
✅ New feature branch created
✅ Phase 25.06 work isolated
```

इसके बाद ही नया **Terraform CD Workflow** code implement किया जाएगा।

---

# 📋 Practical Command Sequence

### 1️⃣ Latest Main

```powershell
git fetch origin --prune
git switch main
git pull --ff-only origin main
git status
```

### 2️⃣ New Phase 25.06 Branch

```powershell
git switch -c feature/phase-25.06-terraform-cd-workflow
git branch
git status
```

### 3️⃣ Then Development

```text
06-Terraform-CD-Workflow.md
            +
terraform-cd.yml
            ↓
        Test
            ↓
         Commit
            ↓
          Push
            ↓
           PR
```

---

## 🏁 Phase 25.06 Starting Point

**पहले repository को latest `origin/main` पर synchronize करेंगे।**

उसके बाद:

**`feature/phase-25.06-terraform-cd-workflow`**

नाम की नई branch बनाएंगे और उसी में Phase 25.06 का नया code डालेंगे।

---
# 🚀 Phase 25.06 — Terraform CD Workflow

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Actions-black?logo=github)
![Azure](https://img.shields.io/badge/Azure-Cloud-blue?logo=microsoftazure)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?logo=terraform)
![OIDC](https://img.shields.io/badge/Azure-OIDC-green)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Deployment-orange)

</p>

---

## 🎯 Objective

इस Phase का objective existing **Terraform CD Pipeline** को एक proper infrastructure deployment workflow में convert करना है।

Phase 25.05 में CD pipeline ने successfully:

* Azure OIDC Authentication
* Terraform Init
* Terraform Plan

perform किया।

इस Phase में CD workflow को आगे बढ़ाकर:

```text
Terraform Plan
      ↓
Deployment Approval
      ↓
Terraform Apply
      ↓
Azure Infrastructure Deployment
```

implement किया जाएगा।

---

# 🔄 CD Workflow Architecture

```text
                GitHub Repository
                       │
                       │
                 Push to main
                       │
                       ▼
              ┌─────────────────┐
              │   CD Pipeline   │
              └─────────────────┘
                       │
                       ▼
              Checkout Repository
                       │
                       ▼
                Azure OIDC Login
                       │
                       ▼
                 Terraform Init
                       │
                       ▼
                 Terraform Plan
                       │
                       ▼
              Deployment Approval
                       │
                 ┌─────┴─────┐
                 │           │
               Reject      Approve
                 │           │
                 ▼           ▼
               STOP     Terraform Apply
                               │
                               ▼
                     Azure Infrastructure
```

---

# 🧩 Step 1 — CD Pipeline Trigger

CD pipeline `main` branch में changes आने पर execute होगा।

```yaml
on:

  push:
    branches:
      - main
```

इसका मतलब:

```text
Feature Branch
      ↓
Pull Request
      ↓
Review + Approval
      ↓
Merge into main
      ↓
CD Pipeline Trigger
```

---

# 🧩 Step 2 — GitHub Actions Permissions

Azure OIDC authentication के लिए GitHub Actions को required permissions दी जाएंगी।

```yaml
permissions:

  contents: read
  id-token: write
```

### Purpose

| Permission        | Purpose                   |
| ----------------- | ------------------------- |
| `contents: read`  | Repository code checkout  |
| `id-token: write` | Azure OIDC authentication |

---

# 🧩 Step 3 — Repository Checkout

Pipeline सबसे पहले repository का latest code checkout करेगा।

```yaml
- name: Checkout Repository
  uses: actions/checkout@v4
```

इसके बाद pipeline को latest `main` branch का Terraform code मिलेगा।

---

# 🧩 Step 4 — Azure OIDC Authentication

Pipeline Azure में password या client secret के बिना authenticate करेगा।

```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    client-id: ${{ vars.AZURE_CLIENT_ID }}
    tenant-id: ${{ vars.AZURE_TENANT_ID }}
    subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
```

Flow:

```text
GitHub Actions
      │
      │ OIDC Token
      ▼
Microsoft Entra ID
      │
      ▼
Azure App Registration
      │
      ▼
Azure Subscription
```

---

# 🧩 Step 5 — Azure Authentication Verification

Azure login successful है या नहीं यह verify किया जाएगा।

```yaml
- name: Verify Azure Login
  run: az account show
```

Expected result:

```text
Azure Subscription
Tenant
Subscription ID
Account Information
```

---

# 🧩 Step 6 — Terraform Setup

GitHub Actions runner पर Terraform setup किया जाएगा।

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
```

---

# 🧩 Step 7 — Terraform Init

Terraform backend और providers initialize किए जाएंगे।

```yaml
- name: Terraform Init
  run: terraform init
```

Expected:

```text
Terraform has been successfully initialized!
```

---

# 🧩 Step 8 — Terraform Plan

Deployment से पहले Terraform infrastructure changes calculate करेगा।

```yaml
- name: Terraform Plan
  run: terraform plan -input=false
```

Example:

```text
Plan: 16 to add, 0 to change, 0 to destroy.
```

### Important

`terraform plan` resources create नहीं करता।

यह केवल बताता है:

> Apply करने पर Azure में क्या change होगा।

---

# 🧩 Step 9 — Deployment Approval

Terraform Plan successful होने के बाद deployment को approval gate से गुजरना चाहिए।

```text
Terraform Plan
      ↓
Deployment Approval
      ↓
Approve
      ↓
Terraform Apply
```

अगर approval नहीं मिलता:

```text
Terraform Plan
      ↓
STOP
```

इससे accidental deployment का risk कम होता है।

---

# 🧩 Step 10 — Terraform Apply

Approval मिलने के बाद Terraform actual deployment करेगा।

```yaml
- name: Terraform Apply
  run: terraform apply -auto-approve -input=false
```

यह command Azure infrastructure को actual state में bring करेगी।

Example:

```text
Terraform will perform the following actions:

  + create resource_group
  + create virtual_network
  + create subnet
  + create public_ip
  + create network_interface

Plan: 16 to add, 0 to change, 0 to destroy.

Apply complete!
```

---

# ⚠️ Important Deployment Rule

`terraform apply` को बिना approval के directly execute नहीं करना है।

Preferred architecture:

```text
Plan
 ↓
Approval
 ↓
Apply
```

यह production infrastructure के लिए safer deployment model है।

---

# 🧩 Step 11 — Azure Infrastructure Deployment

Terraform Apply successful होने के बाद Azure resources create/update होंगे।

Example:

```text
Terraform
   │
   ├── Resource Group
   ├── VNet
   ├── Subnet
   ├── Public IP
   ├── NIC
   └── Other Infrastructure
          │
          ▼
        Azure
```

---

# 🔐 Security Model

Complete CD authentication flow:

```text
GitHub Actions
      │
      │ OIDC
      ▼
Microsoft Entra ID
      │
      ▼
App Registration
      │
      ▼
Federated Identity Credential
      │
      ▼
Azure Subscription
      │
      ▼
Terraform
```

No long-lived Azure Client Secret is required.

---

# 📋 Complete Phase 25.06 Flow

```text
                    ┌───────────────┐
                    │  main branch  │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │ CD Trigger    │
                    └───────┬───────┘
                            │
                            ▼
                    Checkout Code
                            │
                            ▼
                     Azure OIDC Login
                            │
                            ▼
                     Terraform Init
                            │
                            ▼
                     Terraform Plan
                            │
                            ▼
                  ┌───────────────────┐
                  │ Deployment        │
                  │ Approval          │
                  └─────────┬─────────┘
                            │
                         APPROVE
                            │
                            ▼
                    Terraform Apply
                            │
                            ▼
                  Azure Infrastructure
                            │
                            ▼
                       Validation
```

---

# 🔍 What to Validate

* CD pipeline is triggered only after changes reach `main`
* GitHub Actions successfully authenticates with Azure using OIDC
* Terraform initialization completes successfully
* Terraform Plan completes successfully
* Terraform Plan output is reviewed before deployment
* Deployment approval is required before Terraform Apply
* Terraform Apply executes only after approval
* Azure infrastructure is created/updated successfully

---

# ✅ Best Practice

* `main` branch remains protected
* Direct push to `main` should not be used
* CD should trigger from `main`
* Azure authentication should use OIDC
* Terraform Plan should execute before Apply
* Production Apply should have an approval gate
* Terraform State must be maintained using the configured backend
* CI and CD responsibilities should remain separate

```text
CI = Validate + Security + Plan

CD = Deploy
```

---

# 🧪 Validation Test

### Test 1 — CD Trigger

Merge approved Pull Request into `main`.

Expected:

```text
Terraform CD
      ↓
Workflow Started
```

### Test 2 — Terraform Plan

Check workflow logs.

Expected:

```text
Terraform Init → SUCCESS
Terraform Plan → SUCCESS
```

### Test 3 — Deployment Approval

Verify that Apply is blocked until approval is provided.

Expected:

```text
Plan
 ↓
Waiting for Approval
```

### Test 4 — Terraform Apply

Approve the deployment.

Expected:

```text
Terraform Apply
      ↓
SUCCESS
```

### Test 5 — Azure Validation

Check Azure Portal / Azure CLI.

Expected:

```text
Terraform-managed resources
        ↓
Created / Updated Successfully
```

---

# 🎯 Expected Result

Phase 25.06 के completion पर Terraform CD workflow इस प्रकार काम करना चाहिए:

```text
main
 ↓
CD
 ↓
Azure OIDC
 ↓
Terraform Init
 ↓
Terraform Plan
 ↓
Deployment Approval
 ↓
Terraform Apply
 ↓
Azure Infrastructure
```

---

# 📋 Evidence

* GitHub Actions CD workflow execution screenshot
* Azure OIDC authentication success
* Terraform Init success
* Terraform Plan output
* Deployment approval evidence
* Terraform Apply output
* Azure Resource Group evidence
* Azure resources deployment evidence

---

# 🏁 Phase Completion

Phase 25.06 successfully complete माना जाएगा जब:

* [ ] CD workflow configured
* [ ] Main branch trigger validated
* [ ] Azure OIDC authentication validated
* [ ] Terraform Init validated
* [ ] Terraform Plan validated
* [ ] Deployment Approval configured
* [ ] Terraform Apply validated
* [ ] Azure infrastructure deployment validated
* [ ] Deployment evidence captured

---

## 🚀 Next Phase

**Phase 25.07 — Main-to-CD Trigger**

इसमें हम specifically validate करेंगे कि:

```text
PR Merge → main
       ↓
CD Automatically Trigger
       ↓
Terraform Deployment
```

और पूरा **GitHub → CI → PR → Approval → main → CD → Azure** lifecycle practically test करेंगे।

---

### 📊 Command Decision Table

| क्रम | Scenario | Local स्थिति | Remote स्थिति | क्या करना है | Main Command |
| :-: | :--- | :--- | :--- | :--- | :--- |
| **1** | Fully Sync | Same | Same | कुछ नहीं | `git status` |
| **2** | Local पीछे | Behind | Ahead | Remote changes लो | `git pull --ff-only origin main` |
| **3** | Local आगे | Ahead | Behind | Local commits inspect करो | `git log --oneline origin/main..main` |
| **4** | दोनों आगे | Ahead | Ahead | Diverged — पहले decision | `git log --oneline --left-right main...origin/main` |
| **5** | सिर्फ file modified | Uncommitted | Same | Change save करो | `git status` |
| **6** | नई file added | Untracked | Same | Add + commit/stash | `git status` |
| **7** | Local extra commit | Ahead | Behind | Feature branch/PR या reset | `git log --oneline origin/main..main` |
| **8** | New feature शुरू करनी है | Latest चाहिए | Latest | Main sync → feature branch | `git switch -c feature/<name>` |
| **9** | Local commits नहीं चाहिए | Extra commits | Remote अलग | Backup → reset | `git reset --hard origin/main` |
| **10** | Old feature branch | Outdated | Ahead | Delete or rebase | `git branch -d feature/<name>` |

---

# 🔄 Git Local vs Remote Synchronization — All Scenarios & Commands

<p align="center">

![Git](https://img.shields.io/badge/Git-Branching-orange?logo=git)
![GitHub](https://img.shields.io/badge/GitHub-Workflow-black?logo=github)
![Best Practice](https://img.shields.io/badge/Best%20Practice-Feature%20Branch-blue)
![Protected Main](https://img.shields.io/badge/Main-Protected-red)

</p>

---

# 📌 Scenario 1 — Local और Remote बिल्कुल Sync हैं

```text
Local main

A ── B ── C
          ↑
        main

Remote main

A ── B ── C
          ↑
      origin/main
```

### स्थिति

```text
Local main       = Remote main
Local आगे        = ❌
Remote आगे       = ❌
```

दोनों में कोई difference नहीं है।

### क्या करें?

नई feature के लिए सीधे नई branch बनाओ।

---

# 📌 Scenario 2 — Local Main Remote से पीछे है

```text
Local main

A ── B ── C
          ↑
        main


Remote main

A ── B ── C ── D ── E
                    ↑
                origin/main
```

### स्थिति

```text
Local आगे        = ❌
Local पीछे       = ✅
Remote आगे       = ✅
Remote पीछे      = ❌
```

मतलब remote में नए commits हैं।

### क्या करें?

पहले local `main` को update करो।

```text
origin/main
     ↓
local main
     ↓
fast-forward
```

---

# 📌 Scenario 3 — Local Main Remote से आगे है

```text
Remote main

A ── B ── C
          ↑
      origin/main


Local main

A ── B ── C ── D ── E
                    ↑
                  main
```

### स्थिति

```text
Local आगे        = ✅
Local पीछे       = ❌
Remote आगे       = ❌
Remote पीछे      = ✅
```

मतलब local में ऐसे commits हैं जो remote `main` में नहीं हैं।

### Important

यह जरूरी नहीं कि `git pull` करना पड़े।

क्योंकि remote में local के लिए कोई नया commit नहीं है।

अगर ये commits गलती से local `main` पर बने हैं और `main` protected है, तो उन्हें सीधे push नहीं करना।

Better:

```text
Local commit
     ↓
Feature branch
     ↓
PR
     ↓
Approval
     ↓
Merge
```

---

# 📌 Scenario 4 — Local और Remote दोनों आगे हैं

```text
                 D ── E
                ↑
              main

A ── B ── C
          \
           F ── G
                ↑
            origin/main
```

### स्थिति

```text
Local आगे        = ✅
Remote आगे       = ✅
```

लेकिन दोनों की history अलग हो गई है।

इसे कहते हैं:

> **Diverged Branch**

### यहाँ blindly `git pull` नहीं करना चाहिए।

पहले decide करो:

```text
Merge
Rebase
Cherry-pick
Reset
```

---

# 📌 Scenario 5 — Local में सिर्फ File Change हुई है, Commit नहीं हुआ

```text
Remote main

A ── B ── C
          ↑
      origin/main


Local

A ── B ── C
          ↑
        main

Working Tree:
    modified: main.tf
```

### स्थिति

Git commit history same है।

लेकिन working directory में changes हैं।

```text
Commit difference = ❌
File difference   = ✅
```

### पहले check करो

```powershell
git status
```

फिर decide करो:

```text
Change रखना है?
    ↓
Commit / Stash
```

या

```text
Change नहीं चाहिए?
    ↓
Discard
```

### Important

Uncommitted changes के साथ `pull` कभी-कभी हो सकता है, लेकिन अगर remote changes उन्हीं files/lines को touch करते हैं तो conflict/abort हो सकता है।

**Best Practice: पहले local work को सुरक्षित करो।**

---

# 📌 Scenario 6 — Local में नई File Add हुई है, Commit नहीं हुआ

```text
Remote main

A ── B ── C


Local Working Tree

A ── B ── C

New:
    terraform-cd.yml
```

### स्थिति

```text
Commit difference = ❌
Working tree      = ✅
New file          = untracked
```

पहले:

```powershell
git status
```

अगर file रखनी है:

```powershell
git add <file>
git commit -m "feat: add new configuration"
```

या temporarily side में रखना है:

```powershell
git stash
```

फिर remote changes ले सकते हो।

---

# 📌 Scenario 7 — Local में Extra File/Code है और Commit भी हो चुका है

```text
Remote main

A ── B ── C


Local main

A ── B ── C ── D
              ↑
        extra local commit
```

### स्थिति

```text
Local आगे = ✅
Remote आगे = ❌
```

अगर `D` useful है:

```text
D को Feature Branch में रखो
        ↓
PR
        ↓
Review
        ↓
Merge
```

अगर `D` नहीं चाहिए:

```text
Local main को origin/main पर reset
```

लेकिन reset करने से पहले backup/verification जरूरी है।

---

# 📌 Scenario 8 — नई Feature Branch बनाकर Remote Main का Latest Code लेना है

यह **सबसे recommended scenario** है।

```text
origin/main
     │
     ▼
latest main
     │
     ▼
feature/phase-25.06
```

पहले local `main` को latest करो:

```text
main
 ↓
fetch
 ↓
check
 ↓
pull --ff-only
```

फिर:

```text
latest main
     ↓
feature branch
```

---

# 📌 Scenario 9 — Local Main में Extra Commits हैं लेकिन मुझे Latest Remote Main चाहिए

```text
Local:

A ── B ── C ── D

Remote:

A ── B ── C ── E ── F
```

यह **diverged** situation है।

अगर local `D` की जरूरत नहीं है:

```text
Local main
    ↓
backup
    ↓
reset --hard origin/main
```

अगर `D` की जरूरत है:

```text
origin/main
    ↓
new feature branch
    ↓
cherry-pick D
```

---

# 📌 Scenario 10 — Feature Branch पुरानी है और Main में नए Changes आ चुके हैं

```text
main:

A ── B ── C ── D ── E
                    ↑
                  main


feature:

A ── B ── C ── F ── G
                    ↑
                 feature
```

Feature branch को latest main के साथ update करना है।

Options:

```text
Merge main → feature
```

या project policy के अनुसार:

```text
Rebase feature onto main
```

Feature branch को update करना normal है।

---

# 📊 अब पूरा Command Decision Table

| क्रम | Scenario                 | Local स्थिति  | Remote स्थिति | क्या करना है               | Main Command                                        |
| ---: | ------------------------ | ------------- | ------------- | -------------------------- | --------------------------------------------------- |
|    1 | Fully Sync               | Same          | Same          | कुछ नहीं                   | `git status`                                        |
|    2 | Local पीछे               | Behind        | Ahead         | Remote changes लो          | `git pull --ff-only origin main`                    |
|    3 | Local आगे                | Ahead         | Behind        | Local commits inspect करो  | `git log --oneline origin/main..main`               |
|    4 | दोनों आगे                | Ahead         | Ahead         | Diverged — पहले decision   | `git log --oneline --left-right main...origin/main` |
|    5 | सिर्फ file modified      | Uncommitted   | Same          | Change save करो            | `git status`                                        |
|    6 | नई file added            | Untracked     | Same          | Add + commit/stash         | `git status`                                        |
|    7 | Local extra commit       | Ahead         | Behind        | Feature branch/PR या reset | `git log --oneline origin/main..main`               |
|    8 | New feature शुरू करनी है | Latest चाहिए  | Latest        | Main sync → feature branch | `git switch -c feature/<name>`                      |
|    9 | Local commits नहीं चाहिए | Extra commits | Remote अलग    | Backup → reset             | `git reset --hard origin/main`                      |
|   10 | Old feature branch       | Behind main   | Main ahead    | Feature update             | `git merge main` / `git rebase main`                |

---

# 🧭 Universal Step-by-Step Command Sequence

## Step 1 — Current Branch Check

```powershell
git branch --show-current
```

**Meaning:** अभी तुम किस branch पर हो?

---

## Step 2 — Working Tree Check

```powershell
git status
```

**Meaning:** कोई modified/untracked/uncommitted file है या नहीं?

---

## Step 3 — Remote Information Update

```powershell
git fetch origin --prune
```

**Meaning:** Remote की latest information local Git में update करो।

> `fetch` तुम्हारे local files को modify नहीं करता।

---

## Step 4 — Remote से Local Main पीछे है या नहीं

```powershell
git log --oneline main..origin/main
```

**Meaning:**

> ऐसे commits दिखाओ जो `origin/main` में हैं लेकिन local `main` में नहीं।

### Output आया:

```text
abc1234 commit
```

तो:

```text
Remote main आगे है
```

### Blank आया:

```text
(no output)
```

तो remote में local main से कोई extra commit नहीं है।

---

## Step 5 — Local Main Remote से आगे है या नहीं

```powershell
git log --oneline origin/main..main
```

**Meaning:**

> ऐसे commits दिखाओ जो local `main` में हैं लेकिन `origin/main` में नहीं।

### Output आया:

```text
xyz5678 commit
```

तो:

```text
Local main आगे है
```

### Blank आया:

```text
(no output)
```

तो local में remote से कोई extra commit नहीं है।

---

# 🟢 अगर दोनों Commands Blank हैं

```powershell
git log --oneline main..origin/main
git log --oneline origin/main..main
```

दोनों blank:

```text
             main
               │
               ▼
A ── B ── C
               ▲
               │
          origin/main
```

### Result

> **Local main और Remote main 100% synchronized हैं।**

अब:

```powershell
git switch -c feature/phase-25.06
```

---

# 🟡 अगर सिर्फ पहला Command Output देता है

```powershell
git log --oneline main..origin/main
```

Output है।

लेकिन:

```powershell
git log --oneline origin/main..main
```

blank है।

### Result

```text
Remote आगे
Local पीछे
```

अब:

```powershell
git pull --ff-only origin main
```

---

# 🔵 अगर सिर्फ दूसरा Command Output देता है

```powershell
git log --oneline main..origin/main
```

blank है।

और:

```powershell
git log --oneline origin/main..main
```

Output देता है।

### Result

```text
Local आगे
Remote पीछे
```

**Blindly pull करने की जरूरत नहीं।**

पहले local commit को inspect करो।

---

# 🔴 अगर दोनों Commands Output देते हैं

```text
main..origin/main
        ↓
Remote-only commits

origin/main..main
        ↓
Local-only commits
```

### Result

```text
Branches Diverged
```

अब:

```text
❌ Blind git pull
❌ Direct push main

✅ Analyze
✅ Backup if required
✅ Merge / Rebase / Cherry-pick / Reset
```

---

# 🟣 अगर `git status` में सिर्फ Modified File है

Example:

```text
M docs/Phase-25.06.md
```

मतलब:

```text
File changed
लेकिन commit नहीं हुआ
```

### अगर change रखना है:

```powershell
git add docs/Phase-25.06.md
git commit -m "docs: update phase 25.06"
```

### अगर temporarily रखना है:

```powershell
git stash push -m "WIP Phase 25.06"
```

### अगर change नहीं चाहिए:

```powershell
git restore docs/Phase-25.06.md
```

⚠️ `restore` local changes हटा सकता है।

---

# 🟠 अगर `git status` में नई File है

Example:

```text
Untracked files:
    .github/workflows/terraform-cd.yml
```

### रखना है:

```powershell
git add .github/workflows/terraform-cd.yml
git commit -m "feat: add Terraform CD workflow"
```

### Temporary रखना है:

```powershell
git stash -u
```

---

# 🏆 Protected Main के लिए हमारा Standard Workflow

हर नए Phase के लिए यही sequence follow करेंगे:

```text
1. git switch main
        ↓
2. git status
        ↓
3. git fetch origin --prune
        ↓
4. Check:
   main..origin/main
        +
   origin/main..main
        ↓
5. अगर पीछे है:
   git pull --ff-only origin main
        ↓
6. Main latest
        ↓
7. git switch -c feature/phase-XX-<name>
        ↓
8. Make Changes
        ↓
9. git status
        ↓
10. git add
        ↓
11. git diff --cached
        ↓
12. git commit
        ↓
13. git push -u origin feature/<name>
        ↓
14. Pull Request
        ↓
15. CI
        ↓
16. Code Review
        ↓
17. Approval
        ↓
18. Merge → main
```

---

# 🚨 सबसे Important Rules

| Rule                       | क्या करना है                                               |
| -------------------------- | ---------------------------------------------------------- |
| नया code                   | Feature branch                                             |
| नई file                    | Feature branch                                             |
| Documentation change       | Feature branch                                             |
| Terraform change           | Feature branch                                             |
| Protected main             | Direct push नहीं                                           |
| Remote main पीछे/आगे check | `git fetch`                                                |
| Local पीछे                 | `git pull --ff-only`                                       |
| Local आगे                  | पहले local commits inspect                                 |
| दोनों आगे                  | Diverged — पहले decision                                   |
| Uncommitted changes        | पहले save/stash/commit                                     |
| नई feature शुरू            | Latest `main` से branch                                    |
| Main पर accidental commit  | Backup → feature branch/PR                                 |
| Remote branch बनाना        | `git push -u origin feature/...` से automatically बन जाएगी |

---

# ⭐ याद रखने वाला Formula

```text
STATUS
   ↓
FETCH
   ↓
COMPARE
   ↓
┌─────────────────────────────┐
│ Local पीछे?                 │
│ → Pull                       │
├─────────────────────────────┤
│ Local आगे?                  │
│ → Inspect                    │
├─────────────────────────────┤
│ दोनों आगे?                  │
│ → Diverged → Decide         │
├─────────────────────────────┤
│ सिर्फ uncommitted changes?  │
│ → Save / Stash / Commit     │
└─────────────────────────────┘
   ↓
LATEST MAIN
   ↓
FEATURE BRANCH
   ↓
CHANGE
   ↓
COMMIT
   ↓
PUSH
   ↓
PR
   ↓
REVIEW
   ↓
APPROVAL
   ↓
MERGE
```

## 🎯 Golden Rule

> **`git pull` का decision सिर्फ इस बात से नहीं होता कि local में ज्यादा files हैं या नहीं।**
>
> पहले दो चीजें देखो:
>
> **1. Commit history — Local vs Remote**
> **2. Working tree — Uncommitted changes हैं या नहीं**
>
> उसके बाद ही `pull`, `merge`, `rebase`, `stash`, `reset` या `cherry-pick` decide करो।

---

# 🛡️ Azure Landing Zone — Security Governance & CI/CD Pipeline Documentation

---

### 🎯 Phase 20.2 Goals

| Control | Target Status |
| :--- | :--- |
| **GitHub Actions CI** | ![Required](https://img.shields.io/badge/Status-REQUIRED-blue?style=flat-square) |
| **Terraform Format** | ![Required](https://img.shields.io/badge/Status-REQUIRED-blue?style=flat-square) |
| **Terraform Validate** | ![Required](https://img.shields.io/badge/Status-REQUIRED-blue?style=flat-square) |
| **Trivy IaC Scan** | ![Required](https://img.shields.io/badge/Status-REQUIRED-blue?style=flat-square) |
| **Terraform Plan** | ![Required](https://img.shields.io/badge/Status-REQUIRED-blue?style=flat-square) |
| **Failed CI** | ![Merge Blocked](https://img.shields.io/badge/Behavior-MERGE_BLOCKED-red?style=flat-square) |
| **Successful CI** | ![Merge Allowed](https://img.shields.io/badge/Behavior-MERGE_ALLOWED-brightgreen?style=flat-square) |
| **Direct Main Push** | ![Blocked](https://img.shields.io/badge/Behavior-BLOCKED-red?style=flat-square) |

---

### 🧪 Step 24 — Final Validation Checklist

| Validation | Expected | Status |
| :--- | :-: | :--- |
| **Feature branch created** | ✅ | ![Passed](https://img.shields.io/badge/State-PASSED-brightgreen?style=flat-square) |
| **Pull Request created** | ✅ | ![Passed](https://img.shields.io/badge/State-PASSED-brightgreen?style=flat-square) |
| **GitHub Actions executed** | ✅ | ![Passed](https://img.shields.io/badge/State-PASSED-brightgreen?style=flat-square) |
| **Exact CI check identified** | ✅ | ![Passed](https://img.shields.io/badge/State-PASSED-brightgreen?style=flat-square) |
| **Required Status Check configured** | ⏳ | ![Pending](https://img.shields.io/badge/State-PENDING-yellow?style=flat-square) |
| **CI failure blocks merge** | ⏳ | ![Pending](https://img.shields.io/badge/State-PENDING-yellow?style=flat-square) |
| **CI success allows merge** | ⏳ | ![Pending](https://img.shields.io/badge/State-PENDING-yellow?style=flat-square) |
| **Main branch protected** | ⏳ | ![Pending](https://img.shields.io/badge/State-PENDING-yellow?style=flat-square) |
| **PR approval required** | ⏳ | ![Pending](https://img.shields.io/badge/State-PENDING-yellow?style=flat-square) |
| **Force push disabled** | ⏳ | ![Pending](https://img.shields.io/badge/State-PENDING-yellow?style=flat-square) |

---

### 📋 OIDC Configuration Fields Reference

आपके स्क्रीन पर अब जो फ़ील्ड्स बचे हैं, उनको इसी नए immutable-subject फ़ॉर्मेट में फ़िल करना है:

| Field | क्या select/enter करना है |
| :--- | :--- |
| **Issuer** | `https://token.actions.githubusercontent.com` |
| **Organization** | `Shrikant-Nadgaudaa` |
| **Organization ID** | `247837213` |
| **Repository** | `comsolve-cyberex-azure-landing-zone` |
| **Repository ID** | `1338145312` |
| **Entity type** | Branch / Pull request — workflow के अनुसार |
| **Subject identifier** | Auto-generated रहने दो |
| **Name** | `github-actions-oidc` |
| **Audience** | `api://AzureADTokenExchange` |

---

### 🔐 Azure OIDC Federated Credential Configuration

Azure के **Add a credential ➔ GitHub Actions deploying Azure resources** फ़ॉर्म में यह मान भरें:

| Azure Field | Value |
| :--- | :--- |
| **Issuer** | `https://token.actions.githubusercontent.com` |
| **Organization** | `Shrikant-Nadgaudaa` |
| **Organization ID** | `247837213` |
| **Repository** | `comsolve-cyberex-azure-landing-zone` |
| **Repository ID** | `1338145312` |

---

### 🎯 Phase Execution — Proof of Concept

| Test Verification | Status |
| :--- | :--- |
| **Azure OIDC Authentication** | ![Passed](https://img.shields.io/badge/Status-PASSED-brightgreen?style=flat-square) |
| **Azure Subscription Access** | ![Passed](https://img.shields.io/badge/Status-PASSED-brightgreen?style=flat-square) |
| **Terraform Initialization** | ![Started](https://img.shields.io/badge/Status-STARTED-blue?style=flat-square) |
| **Terraform Error Detection** | ![Passed](https://img.shields.io/badge/Status-PASSED-brightgreen?style=flat-square) |
| **Pipeline Failure on Error** | ![Passed](https://img.shields.io/badge/Status-PASSED-brightgreen?style=flat-square) |

---

### 🔄 Successful Pipeline Workflow

```mermaid
graph TD
    A[Correct Terraform] --> B[Push to Feature Branch]
    B --> C[Create Pull Request]
    C --> D[Azure OIDC Login ✅]
    D --> E[Terraform Validation ✅]
    E --> F[Trivy Security Scan ✅]
    F --> G[Terraform Plan ✅]
    G --> H[Required Status Check Passed ✅]

---