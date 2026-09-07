# 🚀 Phase 25.05 — CD Pipeline Architecture

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Actions-black?logo=github)
![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoftazure)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform)
![OIDC](https://img.shields.io/badge/Azure-OIDC-0078D4?logo=microsoftazure)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Pipeline-success)
![Status](https://img.shields.io/badge/Status-In%20Progress-yellow)

</p>

---

## 🎯 1. Objective

इस phase का objective है existing **Terraform CI Pipeline** के बाद एक अलग **Terraform CD Pipeline** की architecture तैयार करना।

CI pipeline केवल code को validate करती है:

```text
Terraform fmt
      ↓
Terraform init
      ↓
Terraform validate
      ↓
Trivy Security Scan
      ↓
Terraform plan
```

CD pipeline का responsibility infrastructure deployment lifecycle को handle करना होगा:

```text
main branch
     ↓
CD Pipeline
     ↓
Azure OIDC Authentication
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

> ⚠️ इस phase में हम केवल **CD Pipeline Architecture और workflow foundation** तैयार करेंगे।
>
> `terraform apply` अभी intentionally execute नहीं किया जाएगा।

---

# 🏗️ 2. Current Infrastructure Flow

हमारे project में अब तक lifecycle यह है:

```text
Developer
   │
   ▼
Feature Branch
   │
   ▼
Terraform CI
   │
   ├── Terraform Format
   ├── Terraform Init
   ├── Terraform Validate
   ├── Trivy Scan
   └── Terraform Plan
   │
   ▼
Pull Request
   │
   ▼
Code Review
   │
   ▼
Approval
   │
   ▼
Feature → main
   │
   ▼
         🔵 CD PIPELINE
   │
   ▼
Azure Infrastructure Deployment
```

---

# 🔄 3. CI vs CD

## 🔵 CI — Continuous Integration

CI का काम है:

```text
Code
 ↓
Validate
 ↓
Security Scan
 ↓
Plan
```

CI infrastructure को deploy नहीं करेगी।

हमारी existing CI:

```text
.github/workflows/terraform-ci.yml
```

---

## 🟢 CD — Continuous Deployment

CD का काम होगा:

```text
main
 ↓
Azure Login
 ↓
Terraform Init
 ↓
Terraform Plan
 ↓
Approval
 ↓
Terraform Apply
```

CD का purpose है approved Terraform code को Azure environment में deploy करना।

---

# 📂 4. GitHub Repository Structure

हमारे repository में workflow structure:

```text
comsolve-cyberex-azure-landing-zone
│
├── .github
│   └── workflows
│       │
│       ├── terraform-ci.yml
│       │
│       └── terraform-cd.yml
│
├── terraform
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── locals.tf
│   └── outputs.tf
│
├── terraform/modules
│
└── docs
    └── Phase-25-Infrastructure-Deployment-Release-Lifecycle
```

---

# 🧭 5. CD Pipeline Architecture

Final architecture:

```text
                     GitHub Repository
                            │
                            │
                     feature/vnet
                            │
                            ▼
                       CI Pipeline
                            │
                            ▼
                         Pull Request
                            │
                            ▼
                       Code Approval
                            │
                            ▼
                       Merge → main
                            │
                            ▼
                  ┌─────────────────────┐
                  │   Terraform CD      │
                  │     Pipeline        │
                  └──────────┬──────────┘
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
                             ▼
                    Terraform Apply
                             │
                             ▼
                  Azure Infrastructure
```

---

# 🛠️ 6. Step 1 — Verify Feature Branch Merge

सबसे पहले confirm करना है कि हमारा previous phase successfully complete हुआ है।

### GitHub Path

```text
GitHub Repository
        ↓
Pull requests
        ↓
Closed
        ↓
PR #6
```

Expected message:

```text
Pull request successfully merged and closed
```

### इसका मतलब

```text
feature/vnet
      ↓
main
```

successfully merge हो चुका है।

---

# 🛠️ 7. Step 2 — Verify main Branch

अब repository के main branch पर जाएँ।

### Path

```text
Repository
   ↓
Code
   ↓
Branch
   ↓
main
```

Branch selector में:

```text
main
```

select करें।

---

## 🔍 Check

Repository में Terraform code दिखाई देना चाहिए:

```text
terraform/
.github/
docs/
```

---

## 🎯 Expected Result

`main` branch में merged Terraform code available होना चाहिए।

---

# 🛠️ 8. Step 3 — Verify Existing CI Workflow

अब existing CI workflow verify करेंगे।

### GitHub Path

```text
Repository
   ↓
Actions
   ↓
Terraform CI
```

Latest successful workflow open करें।

---

## 🔍 Check

CI में following steps successful होने चाहिए:

```text
✅ Checkout Repository
✅ Azure Login
✅ Verify Azure Login
✅ Verify Azure Subscription
✅ Setup Terraform
✅ Terraform Format Check
✅ Terraform Init
✅ Terraform Validate
✅ Trivy IaC Security Scan
✅ Terraform Plan
```

---

# 🧠 9. Step 4 — Understand Why CD Is Separate

CI और CD को अलग रखना important है।

अगर एक ही workflow में यह हो:

```text
Validate
 ↓
Plan
 ↓
Apply
```

तो हर code push के बाद infrastructure automatically change हो सकता है।

Production-style architecture में:

```text
CI
 ↓
Validation
 ↓
Approval
 ↓
CD
 ↓
Deployment
```

रखना ज्यादा controlled approach है।

---

# 🛠️ 10. Step 5 — Create CD Workflow File

अब actual CD workflow file create करेंगे।

### Local Repository Path

```text
PS D:\Projects3\comsolve-cyberex-azure-landing-zone
```

VS Code में:

```text
.github
   ↓
workflows
```

के अंदर नई file बनाएं:

```text
terraform-cd.yml
```

Final path:

```text
.github/workflows/terraform-cd.yml
```

---

# 📝 11. Step 6 — CD Workflow Foundation

अभी केवल foundation बनाएँ।

File:

```text
.github/workflows/terraform-cd.yml
```

Basic structure:

```yaml
# ==============================================================================
# Terraform CD Pipeline
# ==============================================================================

name: Terraform CD

on:

  push:
    branches:
      - main

permissions:

  contents: read
  id-token: write

jobs:

  terraform-cd:

    name: Terraform CD
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: terraform

    steps:

      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}

      - name: Verify Azure Login
        run: az account show

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -input=false
```

---

# 🧠 12. Step 7 — Understand CD Trigger

इस section का सबसे important हिस्सा:

```yaml
on:

  push:
    branches:
      - main
```

इसका मतलब:

```text
Developer
    ↓
Feature Branch
    ↓
Pull Request
    ↓
Approval
    ↓
Merge
    ↓
main
    ↓
CD Trigger
```

यानि CD pipeline **main branch में push होने पर execute होगी**।

---

# 🔐 13. Step 8 — GitHub OIDC Permission

CD workflow में:

```yaml
permissions:

  contents: read
  id-token: write
```

है।

इनका मतलब:

### `contents: read`

GitHub repository का code checkout करने की permission।

### `id-token: write`

GitHub Actions को Azure OIDC token request करने की permission।

Flow:

```text
GitHub Actions
      ↓
OIDC Token
      ↓
Microsoft Entra ID
      ↓
Federated Identity Credential
      ↓
Azure Login
```

---

# 🔐 14. Step 9 — Azure OIDC Authentication

CD में वही existing Azure App Registration use किया जाएगा।

Existing values:

```text
Client ID
666a02fd-9186-4647-bcac-b9fd1943a1e7

Tenant ID
402a28d6-9ea1-462e-8338-dc09423ff348

Subscription ID
7cf9c45e-0a1e-4828-9c98-3e8f25397732
```

Workflow में values hard-code नहीं करनी हैं।

हम existing GitHub Variables use करेंगे:

```yaml
${{ vars.AZURE_CLIENT_ID }}

${{ vars.AZURE_TENANT_ID }}

${{ vars.AZURE_SUBSCRIPTION_ID }}
```

---

# 🧠 15. Step 10 — Why Existing OIDC Can Be Reused

हमारे project में Azure authentication already configured है।

Existing architecture:

```text
GitHub
   │
   │ OIDC
   ▼
Microsoft Entra App Registration
   │
   ▼
Federated Identity Credential
   │
   ▼
Azure Subscription
```

इसलिए CD के लिए नया App Registration बनाना जरूरी नहीं है।

---

# 🛠️ 16. Step 11 — Terraform Working Directory

Workflow में:

```yaml
defaults:
  run:
    working-directory: terraform
```

का मतलब है कि सभी Terraform commands:

```text
terraform/
```

directory से execute होंगी।

इसलिए:

```yaml
terraform init
```

असल में execute होगा:

```text
cd terraform
terraform init
```

इसी तरह:

```yaml
terraform plan
```

execute होगा:

```text
cd terraform
terraform plan
```

---

# 🛠️ 17. Step 12 — Terraform Init

CD pipeline में:

```yaml
- name: Terraform Init
  run: terraform init
```

run होगा।

Purpose:

```text
Terraform
   ↓
Provider Download
   ↓
Backend Initialization
   ↓
State Configuration
```

यह deployment नहीं करता।

---

# 🛠️ 18. Step 13 — Terraform Plan

CD pipeline में:

```yaml
- name: Terraform Plan
  run: terraform plan -input=false
```

run होगा।

Plan यह बताता है:

```text
Resources to Add
Resources to Change
Resources to Destroy
```

Example:

```text
Plan: 16 to add, 0 to change, 0 to destroy.
```

---

# ⚠️ 19. Important — Plan ≠ Apply

यह बहुत important distinction है।

```text
terraform plan
```

केवल proposed infrastructure changes दिखाता है।

जबकि:

```text
terraform apply
```

actual Azure resources create/change/delete करता है।

इस phase में:

```text
❌ terraform apply
```

अभी नहीं होगा।

---

# 🛡️ 20. Step 14 — Deployment Approval Architecture

Final CD lifecycle में deployment approval रहेगा:

```text
main
 ↓
CD
 ↓
Terraform Init
 ↓
Terraform Plan
 ↓
⏸️ Deployment Approval
 ↓
Terraform Apply
```

Approval का purpose:

```text
Plan Review
    ↓
Human Approval
    ↓
Infrastructure Deployment
```

यह accidental deployment का risk कम करता है।

---

# 🏢 21. Step 15 — GitHub Environment

Deployment approval के लिए GitHub Environment use किया जा सकता है।

### GitHub Path

```text
Repository
   ↓
Settings
   ↓
Environments
```

यहाँ environment create किया जा सकता है:

```text
production
```

या project naming के अनुसार:

```text
azure-production
```

इस environment पर deployment protection rules configure किए जा सकते हैं।

---

# 🔐 22. Step 16 — Environment Protection Concept

Architecture:

```text
Terraform Plan
      ↓
production Environment
      ↓
Required Approval
      ↓
Terraform Apply
```

इससे:

```text
Code Merge
```

और

```text
Infrastructure Deployment
```

दो अलग controlled stages बनते हैं।

---

# 🧩 23. Step 17 — Final CD Architecture

Final architecture:

```text
┌──────────────────────┐
│ Feature Branch       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Terraform CI         │
│                      │
│ fmt                  │
│ init                 │
│ validate             │
│ Trivy                │
│ plan                 │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Pull Request         │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Code Review          │
│ + Approval           │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Merge → main         │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Terraform CD         │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Azure OIDC Login     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Terraform Init       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Terraform Plan       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Deployment Approval  │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Terraform Apply      │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Azure Infrastructure │
└──────────────────────┘
```

---

# 🔍 24. What to Validate

### 1. Repository

Verify:

```text
.github/workflows/
```

exists.

### 2. CI Workflow

Verify:

```text
terraform-ci.yml
```

exists and is successful.

### 3. CD Workflow

Verify:

```text
terraform-cd.yml
```

is created.

### 4. Main Branch

Verify:

```text
feature/vnet → main
```

merge successful है।

### 5. Trigger

Verify CD workflow:

```yaml
push:
  branches:
    - main
```

use कर रहा है।

### 6. Authentication

Verify:

```text
Azure OIDC
```

existing App Registration के साथ configured है।

### 7. Terraform

Verify:

```text
terraform init
terraform plan
```

CD architecture में included हैं।

### 8. Apply

Verify कि इस phase में:

```text
terraform apply
```

अभी execute नहीं हो रहा।

---

# ✅ Best Practice

* CI और CD को अलग workflows में रखें।
* `main` को CD trigger रखें।
* Azure authentication के लिए OIDC use करें।
* Client ID / Tenant ID / Subscription ID hard-code न करें।
* GitHub Variables/Secrets का use करें।
* Terraform state को remote backend में रखें।
* CD में पहले `plan` generate करें।
* Production deployment से पहले approval रखें।
* `terraform apply` को uncontrolled तरीके से execute न करें।
* Feature branch से direct deployment न करें।
* `main` को controlled deployment source रखें।

---

# 🧪 Validation Test

Local repository में verify करें:

```powershell
cd D:\Projects3\comsolve-cyberex-azure-landing-zone
```

Workflow file check:

```powershell
Get-ChildItem .github\workflows
```

Expected:

```text
terraform-ci.yml
terraform-cd.yml
```

Git status:

```powershell
git status
```

Expected:

```text
terraform-cd.yml
```

new/uncommitted file के रूप में दिखाई दे सकती है।

---

# 🎯 Expected Result

इस phase के अंत में architecture यह होना चाहिए:

```text
Feature Branch
      ↓
CI
      ↓
Pull Request
      ↓
Approval
      ↓
Merge → main
      ↓
CD Trigger
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
```

लेकिन current phase में actual deployment:

```text
Terraform Apply
```

**execute नहीं किया जाएगा।**

---

# 📋 Evidence

इस phase के लिए निम्न evidence capture करें:

* [ ] `main` branch showing merged Terraform code
* [ ] PR #6 showing `Merged`
* [ ] GitHub Actions → successful CI workflow
* [ ] `.github/workflows/terraform-cd.yml`
* [ ] CD workflow trigger configuration
* [ ] Azure OIDC login configuration
* [ ] Terraform working directory configuration
* [ ] Terraform Init stage
* [ ] Terraform Plan stage
* [ ] GitHub Environment configuration, if created

---

# 🏁 Phase Completion Criteria

Phase 25.05 तब complete माना जाएगा जब:

```text
✅ PR successfully merged
        ↓
✅ main branch verified
        ↓
✅ Existing CI verified
        ↓
✅ CD workflow created
        ↓
✅ main branch trigger configured
        ↓
✅ Azure OIDC configured
        ↓
✅ Terraform Init configured
        ↓
✅ Terraform Plan configured
        ↓
✅ Deployment Approval architecture defined
        ↓
⏭️ Terraform Apply → Next Phase
```

---

# 🚀 Next Phase

## Phase 25.06 — Terraform CD Workflow

अगले phase में हम actual:

```text
terraform-cd.yml
        ↓
Azure Login
        ↓
Terraform Init
        ↓
Terraform Plan
        ↓
Artifact / Plan Handling
        ↓
Deployment Approval
        ↓
Terraform Apply
```

को **one-by-one practical तरीके से configure और test** करेंगे।

> **Phase 25.05 का main purpose:**
> `main → CD → Plan → Approval → Apply` का controlled deployment architecture establish करना है।

---

# 🚀 Git Best Practice — New File / Code Change Workflow

<p align="center">

![Git](https://img.shields.io/badge/Git-Version%20Control-orange?logo=git)
![GitHub](https://img.shields.io/badge/GitHub-Feature%20Branch-black?logo=github)
![Pull Request](https://img.shields.io/badge/Workflow-Pull%20Request-blue)
![Branch Protection](https://img.shields.io/badge/Main-Protected-red)

</p>

---

## 🎯 Objective

जब भी project में:

* नई file बनानी हो
* Existing code में changes करने हों
* नया Terraform module add करना हो
* नया GitHub Actions workflow बनाना हो
* Documentation update करनी हो
* कोई नया feature implement करना हो

तो **सीधे `main` branch पर काम नहीं करना है।**

हमेशा:

```text
main
  │
  │ create feature branch
  ▼
feature/<change-name>
  │
  │ code / file changes
  ▼
git add
  │
  ▼
git commit
  │
  ▼
git push
  │
  ▼
GitHub Pull Request
  │
  ▼
Code Review
  │
  ▼
Approval
  │
  ▼
Merge → main
```

---

# ⭐ Golden Rule

> **नई file / नया code / कोई भी change = पहले Feature Branch.**

### ❌ गलत तरीका

```text
main
 │
 ├── नई file बनाई
 ├── code change किया
 ├── git add
 ├── git commit
 └── git push origin main
```

Protected `main` होने की वजह से direct push reject भी हो सकता है और governance भी टूटती है।

### ✅ सही तरीका

```text
main
 │
 └── feature/new-change
          │
          ├── change
          ├── add
          ├── commit
          ├── push
          └── Pull Request
                    │
                    ├── Review
                    ├── Approval
                    └── Merge → main
```

---

# 🧠 सबसे पहले क्या करना है?

जब भी नया काम शुरू करो, सबसे पहले यह check करो:

```powershell
git branch
git status
```

और ideally:

```text
* main
```

और:

```text
Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
```

इसका मतलब:

```text
Local main
     │
     └── synchronized with origin/main ✅
```

इसके बाद **नई feature branch बनाओ।**

---

# 🛠️ Real Example — Phase 25.05 CD Pipeline

इस example में हमें नई GitHub Actions file बनानी थी:

```text
.github/workflows/terraform-cd.yml
```

पहले user ने पूछा:

> "Direct local से main में push कर दूँ क्या?
> या remote में branch बनाकर local main push करूँ?"

## हमारा सही decision

**Remote पर manually branch बनाने की जरूरत नहीं थी।**

सबसे clean तरीका:

```text
Local main
    ↓
Local feature branch
    ↓
Change
    ↓
Commit
    ↓
Push feature branch
    ↓
Remote feature branch automatically create
    ↓
Pull Request
```

यानी:

> **पहले local में feature branch बनाओ, फिर उसे GitHub पर push करो।**

---

# 📌 Step 1 — Main की स्थिति check

Actual command:

```powershell
git branch
git status
```

Actual स्थिति:

```text
backup/local-main
* main
```

और:

```text
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

## इसका मतलब

```text
main
 │
 ├── Local main ✅
 ├── origin/main के साथ synchronized ✅
 └── कोई pending change नहीं ✅
```

इसलिए feature branch बनाने के लिए यह perfect starting point था।

---

# 📌 Step 2 — नई Feature Branch बनाना

Phase 25.05 के लिए हमने branch बनाई:

```powershell
git switch -c feature/phase-25.05-cd-pipeline
```

Output:

```text
Switched to a new branch 'feature/phase-25.05-cd-pipeline'
```

फिर:

```powershell
git branch
```

Output:

```text
backup/local-main
* feature/phase-25.05-cd-pipeline
main
```

## इसका मतलब

अब हम `main` पर नहीं हैं।

```text
main
 │
 └── feature/phase-25.05-cd-pipeline
             ↑
          यहाँ काम होगा
```

---

# 📌 Step 3 — New File की स्थिति Check

नई file बनाई गई:

```text
.github/workflows/terraform-cd.yml
```

फिर:

```powershell
git status
```

Output:

```text
On branch feature/phase-25.05-cd-pipeline

Untracked files:

.github/workflows/terraform-cd.yml
```

## `Untracked` का मतलब

Git को file दिखाई दे रही है लेकिन Git अभी उस file को track नहीं कर रहा।

```text
Working Directory
       │
       └── terraform-cd.yml
                │
                └── Untracked
```

इस stage पर यह normal है।

---

# 📌 Step 4 — File को Staging Area में Add करना

Command:

```powershell
git add .github/workflows/terraform-cd.yml
```

फिर:

```powershell
git status
```

Output:

```text
Changes to be committed:

new file:
.github/workflows/terraform-cd.yml
```

## अब क्या हुआ?

Git workflow:

```text
Working Directory
       │
       │ git add
       ▼
Staging Area
       │
       └── terraform-cd.yml ✅
```

अभी commit नहीं हुआ था।

---

# 📌 Step 5 — Commit

Command:

```powershell
git commit -m "feat: add Terraform CD pipeline foundation"
```

Actual output:

```text
[feature/phase-25.05-cd-pipeline 52d372a]
feat: add Terraform CD pipeline foundation

create mode 100644 .github/workflows/terraform-cd.yml
```

## इसका मतलब

Git ने नया commit बनाया:

```text
52d372a
```

और commit message:

```text
feat: add Terraform CD pipeline foundation
```

अब change local Git history में सुरक्षित है।

---

# 📌 Step 6 — Working Tree Clean Check

Command:

```powershell
git status
```

Output:

```text
On branch feature/phase-25.05-cd-pipeline
nothing to commit, working tree clean
```

## इसका मतलब

```text
terraform-cd.yml
       │
       └── committed ✅

Working Directory
       │
       └── clean ✅
```

---

# 📌 Step 7 — Commit Verify

Command:

```powershell
git log -1 --oneline
```

Actual output:

```text
52d372a (HEAD -> feature/phase-25.05-cd-pipeline)
feat: add Terraform CD pipeline foundation
```

इससे confirm हुआ:

* सही branch पर हैं ✅
* सही commit बना है ✅
* नया CD workflow commit हो चुका है ✅

---

# 📌 Step 8 — Current Branch Verify

Command:

```powershell
git branch --show-current
```

Output:

```text
feature/phase-25.05-cd-pipeline
```

इससे confirm:

```text
हम main पर नहीं हैं
हम feature branch पर हैं ✅
```

---

# 📌 Step 9 — Remote Check

Command:

```powershell
git remote -v
```

Output:

```text
origin
https://github.com/Shrikant-Nadgaudaa/comsolve-cyberex-azure-landing-zone.git
```

GitHub ने message दिया:

```text
This repository moved.

Please use the new location:

https://github.com/ComSolve-Cloud-Lab/comsolve-cyberex-azure-landing-zone.git
```

### इसका मतलब

Repository अब organization के अंदर है:

```text
ComSolve-Cloud-Lab
        │
        └── comsolve-cyberex-azure-landing-zone
```

लेकिन पुराना remote URL अभी redirect हो रहा है।

**Push successful है**, इसलिए immediate problem नहीं है।

---

# 📌 Step 10 — Feature Branch GitHub पर Push

Command:

```powershell
git push -u origin feature/phase-25.05-cd-pipeline
```

Actual output:

```text
[new branch]
feature/phase-25.05-cd-pipeline
        ->
origin/feature/phase-25.05-cd-pipeline
```

और:

```text
branch 'feature/phase-25.05-cd-pipeline'
set up to track
'origin/feature/phase-25.05-cd-pipeline'
```

## सबसे important point

हमने GitHub पर manually branch create नहीं की।

इस command ने:

```text
Local Branch
     │
     │ git push -u
     ▼
GitHub Remote Branch
```

automatically बना दी:

```text
origin/feature/phase-25.05-cd-pipeline
```

---

# 🏗️ पूरा Actual Workflow

हमारे Phase 25.05 में exactly यह हुआ:

```text
                 MAIN
                  │
                  │
                  ▼
       feature/phase-25.05-cd-pipeline
                  │
                  │
          Create terraform-cd.yml
                  │
                  ▼
              UNTRACKED
                  │
                  │ git add
                  ▼
               STAGED
                  │
                  │ git commit
                  ▼
              COMMITTED
              52d372a
                  │
                  │ git push -u
                  ▼
       GitHub Remote Branch
                  │
                  ▼
    feature/phase-25.05-cd-pipeline
                  │
                  ▼
           Pull Request
                  │
                  ▼
             Code Review
                  │
                  ▼
              Approval
                  │
                  ▼
             Merge → main
```

---

# 🔥 Universal Rule — हर नए काम के लिए

अब से किसी भी नए task पर यह sequence याद रखना:

## 1️⃣ Main Check

```powershell
git switch main
git pull --ff-only origin main
git status
```

Expected:

```text
Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
```

> अगर `main` protected है तो direct changes/push नहीं करने हैं।

---

## 2️⃣ Feature Branch

```powershell
git switch -c feature/<meaningful-name>
```

Examples:

```text
feature/phase-25.06-cd-workflow
feature/terraform-storage
feature/add-bastion
feature/update-network-module
feature/fix-vnet-routing
```

---

## 3️⃣ Make Changes

अब:

```text
New File
Existing File
Terraform Code
GitHub Actions
Documentation
Configuration
```

जो काम करना है करो।

---

## 4️⃣ Check

```powershell
git status
```

---

## 5️⃣ Stage

Specific file:

```powershell
git add <file>
```

या related changes के लिए:

```powershell
git add .
```

> `git add .` तभी use करो जब working directory में मौजूद सभी changes commit में शामिल करने हैं।

---

## 6️⃣ Review Staged Changes

```powershell
git diff --cached
```

यह बहुत अच्छी practice है।

इससे commit करने से पहले देख सकते हो कि exactly क्या commit होने वाला है।

---

## 7️⃣ Commit

```powershell
git commit -m "feat: <short meaningful description>"
```

Examples:

```text
feat: add Terraform CD pipeline foundation
feat: add Azure VNet module
fix: correct subnet configuration
docs: update branch protection guide
```

---

## 8️⃣ Verify

```powershell
git status
git log -1 --oneline
git branch --show-current
```

---

## 9️⃣ Push Feature Branch

```powershell
git push -u origin feature/<branch-name>
```

GitHub पर remote branch automatically create हो जाएगी।

---

# 🔐 फिर GitHub पर

```text
Feature Branch
      ↓
Pull Request
      ↓
CI Checks
      ↓
Terraform Validation
      ↓
Security Scan
      ↓
Code Review
      ↓
Approval
      ↓
Merge
      ↓
main
```

**Protected `main` में direct push नहीं।**

---

# 🚫 क्या नहीं करना है?

### ❌ यह avoid करो

```powershell
git switch main
# changes
git add .
git commit
git push origin main
```

### ❌ यह भी जरूरी नहीं

पहले GitHub website पर manually branch बनाना:

```text
GitHub → New Branch
```

फिर local `main` को उसमें push करना।

हमारे normal workflow में यह unnecessary है।

---

# ⭐ Best Practice Cheat Sheet

| Situation                     | क्या करना है           |
| ----------------------------- | ---------------------- |
| नया feature                   | Feature branch         |
| नई file                       | Feature branch         |
| Terraform change              | Feature branch         |
| GitHub Actions change         | Feature branch         |
| Documentation change          | Feature branch         |
| Bug fix                       | Feature branch         |
| Main update                   | PR द्वारा              |
| Production deployment         | Controlled CD workflow |
| Direct main push              | ❌ Avoid                |
| Manual remote branch creation | ❌ Usually unnecessary  |

---

# 🧠 याद रखने का सबसे आसान Formula

```text
CHECK
  ↓
BRANCH
  ↓
CHANGE
  ↓
ADD
  ↓
REVIEW
  ↓
COMMIT
  ↓
PUSH
  ↓
PR
  ↓
REVIEW + APPROVAL
  ↓
MERGE → MAIN
```

### 🔥 One-Line Rule

> **"Main से branch बनाओ → branch में काम करो → commit करो → push करो → PR बनाओ → review/approval लो → main में merge करो."**

यही हमारा **standard Git workflow** रहेगा।

---

# 🛡️ SonarQube — Complete Architecture, Working, Installation & CI/CD Integration

<p align="center">

![SonarQube](https://img.shields.io/badge/SonarQube-Code%20Quality%20%26%20Security-orange?style=for-the-badge)

![Docker](https://img.shields.io/badge/Docker-Container-blue?style=for-the-badge)

![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-black?style=for-the-badge)

![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?style=for-the-badge)

</p>

---

# 1. 🎯 SonarQube क्या है?

**SonarQube एक Static Code Analysis और Code Quality/Security platform है।**

Simple language में:

> SonarQube आपके code को run किए बिना उसे पढ़ता है और बताता है कि code में quality, maintainability और security से related problems कहाँ हैं।

इसे आप ऐसे समझो:

```text
Developer
   ↓
Code
   ↓
SonarQube
   ↓
Code Analysis
   ↓
┌──────────────────────────────┐
│ Bugs                         │
│ Vulnerabilities              │
│ Security Hotspots            │
│ Code Smells                  │
│ Duplications                 │
│ Maintainability              │
│ Reliability                  │
│ Quality Gate                 │
└──────────────────────────────┘
```

SonarQube केवल security scanner नहीं है।

यह मुख्यतः:

```text
Code Quality
      +
Code Security
      +
Maintainability
      +
Quality Gate
```

provide करता है।

---

# 2. 🔥 SonarQube क्या-क्या Detect करता है?

## 2.1 🐛 Bugs

Code में ऐसी problem जो incorrect behavior पैदा कर सकती है।

Example:

```python
if user is None:
    print(user.name)
```

यह runtime problem पैदा कर सकता है।

SonarQube ऐसी संभावित problems identify कर सकता है।

---

# 2.2 🔐 Vulnerabilities

ऐसी coding problems जो attacker के लिए security risk बन सकती हैं।

Example:

```python
query = "SELECT * FROM users WHERE id=" + user_input
```

Potential SQL Injection जैसी समस्या हो सकती है।

SonarQube इसे security issue के रूप में identify कर सकता है।

---

# 2.3 🚨 Security Hotspots

Security-sensitive code जहाँ developer/security team को manual review करना चाहिए।

Example:

```text
Cryptography
Authentication
Authorization
Randomness
Password handling
Security configuration
```

हर Security Hotspot जरूरी नहीं कि actual vulnerability हो।

इसलिए इसका purpose है:

```text
SonarQube
    ↓
Potentially risky code
    ↓
Human Security Review
```

---

# 2.4 🧹 Code Smells

Code technically चल सकता है लेकिन maintain करना खराब या difficult हो सकता है।

Example:

```python
def process():
    # 500 lines of code
```

या:

```text
Duplicate logic
Huge functions
Complex conditions
Unused code
Poor naming
Bad structure
```

---

# 2.5 📋 Code Duplication

SonarQube duplicate code identify करता है।

Example:

```text
File A
------
validate_user()
login_user()


File B
------
validate_user()
login_user()
```

अगर बहुत ज्यादा duplicate code है तो maintainability खराब होती है।

---

# 3. 🧠 SonarQube का सबसे important concept — Quality Gate

यह SonarQube का बहुत important feature है।

Quality Gate एक **Go / No-Go decision** है।

Example:

```text
SonarQube Analysis
        ↓
Quality Gate
        ↓
   ┌─────────────┐
   │             │
 PASSED        FAILED
   │             │
   ↓             ↓
Continue       Stop
```

Example rules:

```text
New Bugs = 0
New Vulnerabilities = 0
Security Hotspots reviewed = 100%
Code Coverage >= 80%
Duplicated Code < 3%
```

अगर conditions satisfy नहीं होतीं:

```text
QUALITY GATE = FAILED
```

और pipeline को fail कराया जा सकता है।

SonarQube officially CI/CD pipeline को Quality Gate के आधार पर fail/block करने का capability देता है।

---

# 4. 🏗️ SonarQube Architecture

SonarQube को ऐसे समझो:

```text
                 ┌─────────────────────┐
                 │      Developer      │
                 └──────────┬──────────┘
                            │
                            ↓
                    GitHub Repository
                            │
                            ↓
                    GitHub Actions
                            │
                            ↓
                    Sonar Scanner
                            │
                            ↓
              ┌──────────────────────────┐
              │       SonarQube          │
              │                          │
              │  Code Analyzer           │
              │  Rules Engine            │
              │  Security Engine         │
              │  Quality Gate             │
              └────────────┬─────────────┘
                           │
                           ↓
                     SonarQube DB
                           │
                           ↓
                       Dashboard
```

---

# 5. 🔍 SonarQube में Scanner क्या करता है?

यह बहुत important है।

SonarQube Server खुद repository में जाकर code scan नहीं करता।

Pipeline/Developer machine पर **Scanner** चलता है।

Architecture:

```text
Source Code
    ↓
SonarScanner
    ↓
Analysis Data
    ↓
SonarQube Server
    ↓
Rules Engine
    ↓
Results
```

Official documentation भी बताती है कि server install होने के बाद analysis करने वाली machines पर scanner install/configure करना होता है।

---

# 6. 🧩 SonarQube के Main Components

```text
SonarQube
│
├── Web Server
│
├── Compute Engine
│
├── Elasticsearch
│
├── Database
│
└── Scanner
```

### Web Server

Dashboard और API provide करता है।

Normally:

```text
http://localhost:9000
```

---

### Compute Engine

Scanner द्वारा भेजे गए analysis को process करता है।

```text
Scanner
   ↓
Analysis Report
   ↓
Compute Engine
   ↓
Analysis Result
```

---

### Elasticsearch

SonarQube internally search/indexing के लिए Elasticsearch use करता है।

---

### Database

Projects, configuration और analysis information store होती है।

Production installation में external supported database use करना recommended है।

---

# 7. 💻 हमारे PC पर कैसे Install करेंगे?

तुम्हारे case में मैं **Docker installation recommend करता हूँ।**

क्यों?

क्योंकि:

```text
Manual Installation
Java
+
Database
+
Configuration
+
Service
+
Dependencies
```

की तुलना में Docker में:

```text
Docker
   ↓
SonarQube Container
   ↓
localhost:9000
```

बहुत आसान है।

Sonar की official documentation भी Docker-based installation support करती है। Docker image के लिए port `9000` expose किया जाता है और local browser से `http://localhost:9000` access किया जा सकता है।

---

# 8. 🖥️ Local Lab Architecture

हमारा lab ऐसा रहेगा:

```text
                    Windows PC
                        │
                        │
                   Docker Desktop
                        │
                        ↓
              ┌───────────────────┐
              │    SonarQube      │
              │    Container      │
              │                   │
              │   Port: 9000      │
              └─────────┬─────────┘
                        │
                        ↓
                 localhost:9000
```

Browser:

```text
http://localhost:9000
```

---

# 9. ⚙️ Local Installation

## Step 1 — Docker Check

PowerShell:

```powershell
docker --version
```

और:

```powershell
docker ps
```

अगर Docker Desktop running है तो आगे चलेंगे।

---

# 10. 📦 SonarQube Container

Learning/lab purpose के लिए SonarQube Community Build का Docker image use कर सकते हैं।

Official documentation local evaluation के लिए Docker container का example देती है।

Basic command:

```powershell
docker run -d `
  --name sonarqube `
  -p 9000:9000 `
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true `
  sonarqube:latest
```

यह क्या करेगा?

```text
docker run
    ↓
SonarQube container create
    ↓
Container port 9000
    ↓
Windows host port 9000
```

---

# 11. 🔎 Container Check

```powershell
docker ps
```

Expected:

```text
CONTAINER ID
IMAGE
STATUS
PORTS
NAMES

sonarqube
```

Logs देखने के लिए:

```powershell
docker logs -f sonarqube
```

जब SonarQube properly start हो जाए तो browser खोलो:

```text
http://localhost:9000
```

Official documentation भी default local URL `http://localhost:9000` बताती है।

---

# 12. 🔐 First Login

Initial login:

```text
Username:
admin

Password:
admin
```

पहली login के बाद password change करना चाहिए।

---

# 13. ⚠️ Lab और Production में Difference

यह बहुत important है।

ऊपर वाला:

```text
sonarqube:latest
```

हमारे **learning/lab** के लिए है।

Production architecture अलग होना चाहिए।

Production:

```text
GitHub Actions
      ↓
SonarScanner
      ↓
SonarQube Server
      ↓
PostgreSQL
```

Database को persistent रखना जरूरी है।

Sonar की Docker documentation persistent volumes जैसे `sonarqube_data`, `sonarqube_logs` और `sonarqube_extensions` की recommendation देती है।

---

# 14. 🗄️ Database क्यों?

SonarQube analysis results store करने के लिए database use करता है।

Production architecture:

```text
              SonarQube
                  │
          ┌───────┴────────┐
          │                │
    Application        Database
          │                │
          │            PostgreSQL
          │
     Elasticsearch
```

Small local testing में embedded H2 database से evaluation किया जा सकता है, लेकिन production के लिए supported external database architecture use करना चाहिए।

---

# 15. 📊 SonarQube Dashboard

Login करने के बाद:

```text
Projects
   ↓
Create Project
   ↓
Analyze Project
   ↓
Dashboard
```

Dashboard पर तुम्हें चीजें दिखेंगी:

```text
Bugs
Vulnerabilities
Security Hotspots
Code Smells
Duplications
Coverage
Quality Gate
```

---

# 16. 🔑 Project क्या है?

SonarQube में repository को एक project के रूप में register कर सकते हैं।

Example:

```text
GitHub Repository

comsolve-cyberex-azure-landing-zone
```

SonarQube:

```text
Project Key:

comsolve-cyberex-azure-landing-zone
```

---

# 17. 🔐 Sonar Token

Pipeline को SonarQube में authenticate करना होगा।

Architecture:

```text
GitHub Actions
       │
       │ SONAR_TOKEN
       ↓
SonarQube
```

Token को कभी भी YAML में hard-code नहीं करना।

गलत:

```yaml
SONAR_TOKEN: abc123456
```

सही:

```yaml
SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

---

# 18. 🧪 Terraform के साथ SonarQube

यह तुम्हारे project के लिए interesting part है।

तुम्हारा repo:

```text
comsolve-cyberex-azure-landing-zone
```

Terraform:

```text
terraform/
├── main.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── outputs.tf
└── modules/
```

SonarQube Terraform code को analyze कर सकता है। Sonar की current documentation में Terraform को supported IaC analysis technologies में शामिल किया गया है।

---

# 19. 🆚 Trivy vs SonarQube

यह सबसे important comparison है।

## Trivy

तुम्हारे CI में already:

```text
Terraform
    ↓
Trivy
    ↓
IaC Misconfiguration
```

Focus:

```text
Security Misconfiguration
Vulnerabilities
Secrets
Dependencies
Containers
IaC
```

---

## SonarQube

```text
Code
 ↓
SonarQube
 ↓
Quality + Security
```

Focus:

```text
Bugs
Vulnerabilities
Security Hotspots
Code Smells
Duplication
Maintainability
Quality Gate
```

---

# 20. 🏆 दोनों साथ क्यों?

```text
                 Terraform Code
                       │
              ┌────────┴────────┐
              │                 │
           Trivy            SonarQube
              │                 │
              ↓                 ↓
        IaC Security      Code Quality
        Misconfiguration  Code Security
              │                 │
              └────────┬────────┘
                       ↓
                  Quality Gate
```

इसलिए:

> **Trivy और SonarQube competitors नहीं हैं।**

दोनों complementary security/quality layers हैं।

---

# 21. ☁️ SonarQube Cloud vs Local SonarQube

तुमने पूछा था कि SaaS में पैसे लगेंगे।

Current Sonar ecosystem में **SonarQube Cloud का Free/OSS option मौजूद है**, लेकिन exact eligibility/plan features अलग हो सकते हैं; Sonar ने 2026 में Free OSS Plan introduce किया है।

लेकिन learning के लिए:

```text
Local SonarQube
      ↓
Docker
      ↓
Free Lab
```

बहुत अच्छा है।

---

# 22. 💰 हम Local क्यों करेंगे?

तुम्हारे current project में:

```text
GitHub
   ↓
GitHub Actions
   ↓
Azure
```

अगर SonarQube Cloud लगाते हैं:

```text
GitHub
   ↓
GitHub Actions
   ↓
Internet
   ↓
SonarQube Cloud
```

Local setup:

```text
GitHub Actions
      ↓
Internet
      ↓
Your SonarQube
```

लेकिन यहाँ एक major issue है:

> GitHub-hosted runner `localhost` को तुम्हारे personal PC के localhost के रूप में access नहीं कर सकता।

यानी:

```text
Your PC

localhost:9000
     ↑
     │
SonarQube
```

लेकिन:

```text
GitHub Runner
      X
localhost:9000
```

GitHub runner का `localhost` **GitHub runner itself** है, तुम्हारा PC नहीं।

इसलिए local SonarQube को GitHub-hosted Actions runner से directly access नहीं कर सकते।

---

# 23. 🔥 तो Local SonarQube का फायदा क्या है?

बहुत फायदा है।

हम पहले local learning करेंगे:

```text
Windows
  ↓
Docker
  ↓
SonarQube
  ↓
Terraform Repository
  ↓
SonarScanner
  ↓
Dashboard
```

इससे तुम्हें समझ आएगा:

```text
Scanner
Project
Token
Analysis
Quality Gate
Issues
Dashboard
```

फिर बाद में:

```text
SonarQube Cloud
```

या:

```text
Self-hosted SonarQube Server
```

को GitHub Actions से integrate करेंगे।

---

# 24. 🏗️ तुम्हारे Current Project का Final Security Architecture

Current:

```text
Feature Branch
      ↓
Terraform CI
      │
      ├── Terraform fmt
      ├── Terraform init
      ├── Terraform validate
      ├── Trivy
      └── Terraform plan
      ↓
Pull Request
      ↓
Review
      ↓
Approval
      ↓
main
      ↓
Terraform CD
      ↓
Terraform Plan
      ↓
Comsolve_production
      ↓
Deployment Approval
      ↓
Terraform Apply
      ↓
Azure
```

अगर SonarQube को **CD में lab purpose के लिए** रखना है:

```text
main
 ↓
Terraform CD
 ↓
SonarQube Analysis
 ↓
SonarQube Quality Gate
 ↓
Terraform Plan
 ↓
Deployment Approval
 ↓
Terraform Apply
```

लेकिन industry-oriented architecture में बेहतर होगा:

```text
Feature Branch
      ↓
CI
 ├── Terraform Validate
 ├── Trivy
 └── SonarQube
      ↓
Quality Gate
      ↓
PR
      ↓
Approval
      ↓
main
      ↓
CD
 ├── Terraform Plan
 ├── Deployment Approval
 └── Terraform Apply
```

**मैं तुम्हारे learning project में पहले तुम्हारी requested CD integration करवा सकता हूँ, लेकिन documentation में साफ लिखेंगे कि production best practice Sonar analysis को pre-merge CI/PR gate में रखना है।**

---

# 25. 🚦 SonarQube का Complete Lifecycle

```text
Developer
    ↓
Code
    ↓
Git
    ↓
GitHub
    ↓
GitHub Actions
    ↓
SonarScanner
    ↓
SonarQube
    ↓
Static Analysis
    ↓
Rules Engine
    ↓
Issues
    ↓
Quality Gate
    ↓
PASS / FAIL
```

---

# 26. 🧠 एक Real-Life Example

मान लो Terraform में कोई खराब configuration है:

```text
Terraform Code
      ↓
SonarQube
      ↓
Analysis
      ↓
Security Issue
      ↓
Quality Gate FAILED
```

तो pipeline:

```text
❌ SonarQube Quality Gate Failed

Deployment STOPPED
```

और अगर:

```text
No critical issue
No new vulnerability
Quality Gate PASSED
```

तो:

```text
✅ SonarQube Passed
       ↓
Continue Pipeline
```

---

# 27. 🔐 Security Model

Never:

```text
Token in Code
Password in YAML
Credentials in Git
```

Always:

```text
GitHub Secrets
      ↓
GitHub Actions
      ↓
SONAR_TOKEN
      ↓
SonarQube
```

---

# 28. 🧪 Local Installation Validation

Installation के बाद:

### Docker

```powershell
docker ps
```

### Container

```powershell
docker logs sonarqube
```

### Browser

```text
http://localhost:9000
```

### Login

```text
admin / admin
```

### Dashboard

```text
Projects
```

Expected:

```text
SonarQube Web UI
        ↓
Operational
```

---

# 29. 🎯 हमारे Project में आगे क्या करेंगे?

हम इसे एकदम step-by-step करेंगे:

```text
Step 01
Docker Verify
       ↓
Step 02
SonarQube Install
       ↓
Step 03
SonarQube Dashboard
       ↓
Step 04
Admin Password
       ↓
Step 05
Create Project
       ↓
Step 06
Generate Token
       ↓
Step 07
Install/Run SonarScanner
       ↓
Step 08
Scan Terraform
       ↓
Step 09
Understand Findings
       ↓
Step 10
Quality Gate
       ↓
Step 11
GitHub Actions Integration
       ↓
Step 12
CD Pipeline Integration
```

---

# 30. 🏆 Final Architecture

हमारा final DevSecOps learning architecture:

```text
                         GitHub
                            │
                            ↓
                     Feature Branch
                            │
                            ↓
                    ┌───────────────┐
                    │      CI       │
                    └───────┬───────┘
                            │
                 ┌──────────┴──────────┐
                 │                     │
               Trivy               SonarQube
                 │                     │
                 ↓                     ↓
             IaC Security       Code Quality
             Misconfiguration   Code Security
                 │                     │
                 └──────────┬──────────┘
                            ↓
                         PR Review
                            ↓
                         Approval
                            ↓
                           main
                            │
                            ↓
                          CD
                            │
                            ↓
                     Terraform Plan
                            │
                            ↓
                 Comsolve_production
                            │
                            ↓
                  Deployment Approval
                            │
                            ↓
                    Terraform Apply
                            │
                            ↓
                          Azure
```

---

# 📌 Important Conclusion

### Trivy

```text
Security Scanner
```

### SonarQube

```text
Code Quality
+
Code Security
+
Quality Gate
```

### Terraform

```text
Infrastructure as Code
```

### GitHub Actions

```text
CI/CD Automation
```

### Azure

```text
Infrastructure Target
```

और पूरा system:

```text
DevSecOps
```

---

# 📋 Evidence

Installation के बाद निम्न evidence capture करेंगे:

* SonarQube Docker container running
* SonarQube dashboard
* SonarQube project
* Project analysis result
* Detected issues
* Quality Gate status
* GitHub Actions SonarQube step
* Successful/failed pipeline result
* Final deployment flow

---

# ✅ Phase Outcome

इस phase के बाद हमें पता होना चाहिए:

* SonarQube क्या है
* Static Code Analysis क्या है
* Scanner क्या करता है
* Quality Gate क्या है
* Bugs और Vulnerabilities में difference
* Security Hotspot क्या है
* Code Smell क्या है
* Trivy और SonarQube में difference
* SonarQube architecture
* Docker installation
* SonarQube project creation
* Token authentication
* Terraform analysis
* GitHub Actions integration
* DevSecOps pipeline में SonarQube की position


---

### 🔍 SonarQube Server vs SonarQube Cloud

| Feature / Aspect | SonarQube Server | SonarQube Cloud |
| :--- | :--- | :--- |
| **Hosting** | 🖥️ Self-hosted | ☁️ SaaS |
| **Server Maintenance** | user (Self-managed) | Sonar (Fully managed) |
| **GitHub Integration** | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) |
| **CI/CD Integration** | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) |
| **Code Quality** | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) |
| **Bugs Detection** | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) |
| **Vulnerabilities** | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) |
| **Code Smells** | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) |
| **Quality Gate** | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) |
| **PR Analysis** | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) | ![Yes](https://img.shields.io/badge/Supported-YES-brightgreen?style=flat-square) |
| **Infrastructure** | Custom VM / Server | Sonar Cloud Managed |
| **Best For** | Enterprise / On-Prem | Cloud-native DevOps |
| **Maintenance Overhead** | High | Very Low |

---

### 📊 Code Quality & Security Scanner Options

| Option | PC Load | Cost | GitHub Actions | Recommendation |
| :--- | :-: | :--- | :-: | :-: |
| **Local SonarQube Server** | 🔴 High | Free | ❌ Direct localhost issue | ❌ |
| **SonarQube Cloud** | 🟢 None | Free tier available* | ✅ | ⭐ **Best** |
| **SonarScanner only** | 🟢 Very low | Free | ⚠️ Server required | ❌ Alone नहीं |
| **Trivy** | 🟢 Very low | Free | ✅ | **Already perfect** |

*\* Cloud plan/features can change, so check current free-plan limits as needed.*


---


### ⚡ CLI-Based Security & Code Analysis Tools Comparison

| Tool | CLI | PC पर / Server Required? | Main Purpose | Project Fit |
| :--- | :-: | :-: | :--- | :-: |
| **Semgrep** | ✅ | ❌ | SAST + Bugs + Security Analysis | ⭐⭐⭐⭐⭐ |
| **CodeQL** | ✅ | ❌ | Deep Semantic Code Security | ⭐⭐⭐⭐ |
| **MegaLinter** | ✅ | ❌ | Multi-language Code Quality & Formatting | ⭐⭐⭐ |
| **Ruff / ESLint** | ✅ | ❌ | Language-specific Quality & Linter | ⭐⭐⭐ |
| **Trivy** | ✅ | ❌ | IaC, Container & Dependency Scanning | ⭐⭐⭐⭐⭐ |


---

Architecture:

```text

GitHub
   │
   ▼
GitHub Actions Runner
   │
   ├── Terraform
   │
   ├── Trivy
   │     └── IaC / Security Misconfiguration
   │
   └── Semgrep
         └── SAST / Code Bugs / Security Patterns


Trivy + Semgrep ka combination mast rahega
                 GitHub Actions
                       │
              ┌────────┴────────┐
              │                 │
           Trivy             Semgrep
              │                 │
       Infrastructure        Source Code
       Security              Security
              │                 │
       Terraform/IaC        SAST / Bugs
```
**Trivy:**

"Infrastructure mein security problem hai kya?"

**Semgrep:**

"Code mein insecure pattern / bug hai kya?"

**Semgrep 30+ languages support karta hai, including Terraform, Dockerfile, Python, JavaScript, Go, Java, YAML**

---

# 🔐 Semgrep — Complete Deep Dive, Installation & CI/CD Integration

<p align="center">

![Semgrep](https://img.shields.io/badge/Semgrep-Community%20Edition-green)
![SAST](https://img.shields.io/badge/Security-SAST-red)
![CLI](https://img.shields.io/badge/Mode-CLI-blue)
![Windows](https://img.shields.io/badge/Windows-Supported-blue)
![GitHub%20Actions](https://img.shields.io/badge/GitHub%20Actions-Supported-black)
![Open%20Source](https://img.shields.io/badge/Open%20Source-Yes-success)

</p>

---

# 📌 1. Semgrep क्या है?

**Semgrep एक Static Application Security Testing (SAST) tool है**, जो source code को execute किए बिना उसके अंदर security vulnerabilities, insecure coding patterns और problematic code patterns identify करता है।

Simple language में:

> **Semgrep = Code को run किए बिना Code के अंदर security problem ढूँढना।**

उदाहरण:

```text
Developer Code
      │
      ▼
   Semgrep
      │
      ├── Security Issues
      ├── Vulnerable Patterns
      ├── Bad Coding Patterns
      ├── Injection Risks
      ├── Hardcoded Secrets Patterns
      └── Insecure Configuration
```

Semgrep Community Edition 30+ languages और 3000+ community rules provide करता है।

---

# 🎯 2. Semgrep की जरूरत क्यों है?

हमारे current project में पहले से:

```text
Trivy
```

use हो रहा है।

लेकिन Trivy और Semgrep का purpose exactly same नहीं है।

## Trivy

Trivy primarily:

```text
Infrastructure Security
        +
IaC Misconfiguration
        +
Container Security
        +
Dependency / Vulnerability Scanning
```

के लिए useful है।

## Semgrep

Semgrep primarily:

```text
Source Code
     ↓
SAST
     ↓
Security Patterns
     ↓
Bugs
     ↓
Insecure Coding
```

के लिए useful है।

इसलिए:

```text
             DevSecOps Pipeline
                    │
          ┌─────────┴─────────┐
          │                   │
        Trivy              Semgrep
          │                   │
      Infrastructure        Source Code
          │                   │
       IaC Security          SAST
```

### Golden Rule

> **Trivy infrastructure को देखता है, Semgrep code को देखता है।**

---

# 🏗️ 3. Semgrep Architecture

Traditional SonarQube architecture:

```text
Developer
    │
    ▼
GitHub
    │
    ▼
SonarScanner
    │
    ▼
SonarQube Server
    │
    ├── Database
    ├── Web UI
    ├── Quality Gate
    └── Dashboard
```

इसमें Server चाहिए।

Semgrep CE का CLI model बहुत lightweight है:

```text
Developer / GitHub Actions
          │
          ▼
       Semgrep CLI
          │
          ▼
     Source Code
          │
          ▼
      Rules Engine
          │
          ▼
      Scan Results
```

इसलिए local testing के लिए अलग SonarQube Server की जरूरत नहीं है।

---

# 🆚 4. Semgrep vs SonarQube vs Trivy

| Feature            | Trivy   | Semgrep CE                 | SonarQube |
| ------------------ | ------- | -------------------------- | --------- |
| CLI                | ✅       | ✅                          | Scanner   |
| Server Required    | ❌       | ❌                          | ✅         |
| Docker Required    | ❌       | ❌                          | ❌         |
| SAST               | Limited | ✅                          | ✅         |
| IaC Security       | ✅       | Limited                    | ✅         |
| Container Security | ✅       | ❌                          | Limited   |
| Dependency Scan    | ✅       | Limited/Platform dependent | Limited   |
| Code Quality       | ❌       | Limited                    | ✅         |
| Code Smells        | ❌       | ❌                          | ✅         |
| Quality Gate       | ❌       | CLI-based rules            | ✅         |
| Local Windows      | ✅       | ✅                          | Heavy     |
| GitHub Actions     | ✅       | ✅                          | ✅         |
| Lightweight        | ✅       | ✅                          | ❌         |

### हमारे project में

```text
Trivy
  ↓
IaC Security

Semgrep
  ↓
SAST / Code Security

Terraform
  ↓
Infrastructure
```

यह combination काफी practical है।

---

# 🆓 5. क्या Semgrep Free है?

हाँ।

**Semgrep Community Edition (CE) free है।**

Semgrep CE को पहले Semgrep OSS कहा जाता था। Semgrep ने इसे Community Edition नाम दिया और CE को free community-focused edition के रूप में maintain किया है।

लेकिन एक important distinction:

```text
Semgrep Community Edition
        │
        ├── Free
        ├── CLI
        ├── Community Rules
        └── Local / CI scanning

Semgrep AppSec Platform
        │
        ├── Cloud features
        ├── Advanced capabilities
        ├── Dashboard
        └── Commercial features
```

इसलिए हमारे current learning project में:

> **Semgrep CE पर्याप्त है।**

---

# 🖥️ 6. Windows पर Installation

Current Semgrep CE releases में native Windows support available है।

इसका मतलब:

```text
Windows
   │
   ├── Docker ❌
   ├── WSL ❌
   └── Python + pip ✅
```

Official Semgrep documentation Windows पर Python/pip installation और `semgrep --config=auto` scan दिखाती है।

---

# 🔎 7. Installation से पहले Python Check

PowerShell खोलो:

```powershell
python --version
```

Expected:

```text
Python 3.x.x
```

अगर यह काम नहीं करता:

```powershell
py --version
```

Expected:

```text
Python 3.x.x
```

---

# 📦 8. Semgrep Installation

### Option 1 — Python command

```powershell
python -m pip install semgrep
```

या:

```powershell
py -m pip install semgrep
```

Installation complete होने के बाद:

```powershell
semgrep --version
```

Expected:

```text
1.x.x
```

Version exact number बदल सकता है।

---

# ✅ 9. Installation Validation

Run:

```powershell
semgrep --version
```

फिर:

```powershell
semgrep --help
```

अगर help दिखाई देती है:

```text
Usage:
  semgrep [OPTIONS] COMMAND [ARGS]...
```

तो installation successful है।

---

# 🧪 10. पहला Semgrep Scan

किसी project directory में जाओ:

```powershell
cd D:\Projects3\comsolve-cyberex-azure-landing-zone
```

अब:

```powershell
semgrep --config=auto
```

यह Semgrep को automatic ruleset selection के साथ scan करने देता है।

Official Community Edition quickstart भी:

```powershell
semgrep --config=auto
```

का उपयोग करता है।

---

# 🔍 11. Semgrep Scan कैसे काम करता है?

जब command चलती है:

```powershell
semgrep --config=auto
```

तो conceptual flow:

```text
Repository
    │
    ▼
Semgrep Scanner
    │
    ▼
Language Detection
    │
    ▼
Rules Selection
    │
    ▼
Pattern Matching
    │
    ▼
Security Findings
```

Semgrep source code को pattern/rule based analysis से inspect करता है।

---

# 🧠 12. Semgrep Rule क्या है?

Semgrep का सबसे important concept:

> **Rule**

Rule basically बताता है:

```text
क्या ढूँढना है?
```

उदाहरण conceptual rule:

```yaml
rules:
  - id: insecure-pattern
    pattern: dangerous_function(...)
    message: "Potentially dangerous function"
    severity: ERROR
```

Semgrep source code में matching pattern मिलने पर finding generate कर सकता है।

---

# 🧩 13. Pattern Matching

मान लो application में:

```python
eval(user_input)
```

है।

एक Semgrep rule इस तरह के insecure pattern को detect कर सकता है।

Flow:

```text
Source Code
     │
     ▼
eval(user_input)
     │
     ▼
Semgrep Rule
     │
     ▼
Pattern Match
     │
     ▼
Security Finding
```

इसका फायदा यह है कि scanner केवल string search नहीं करता; Semgrep syntax-aware pattern analysis का इस्तेमाल कर सकता है।

---

# 🛡️ 14. Semgrep किन Problems को Detect कर सकता है?

Typical categories:

### 1. Injection

```text
SQL Injection
Command Injection
Code Injection
```

### 2. Authentication Issues

```text
Weak authentication patterns
```

### 3. Authorization Issues

```text
Improper access-control patterns
```

### 4. Secrets

```text
Hardcoded credentials
API keys
Tokens
```

### 5. Unsafe Functions

```text
Dangerous API usage
Unsafe function calls
```

### 6. Security Misuse

```text
Insecure cryptography
Unsafe configuration
```

### 7. Code Bugs

```text
Potential runtime bugs
Logic-related patterns
```

---

# 🏠 15. Local Scan

Local repository scan:

```powershell
cd D:\Projects3\comsolve-cyberex-azure-landing-zone

semgrep --config=auto
```

Specific folder:

```powershell
semgrep --config=auto terraform
```

Specific file:

```powershell
semgrep --config=auto terraform/main.tf
```

---

# 📊 16. Output को कैसे समझें?

Semgrep output generally:

```text
Finding
  │
  ├── Rule ID
  ├── File
  ├── Line
  ├── Message
  └── Severity
```

Conceptual example:

```text
terraform/main.tf
Line 25

Rule:
security-rule-example

Severity:
WARNING

Message:
Potential security issue detected
```

---

# 🚦 17. Severity

Findings को broadly इस तरह समझ सकते हैं:

```text
ERROR
  ↓
High concern

WARNING
  ↓
Review required

INFO
  ↓
Informational
```

CI pipeline में हम decide कर सकते हैं कि:

```text
Finding मिले
      │
      ├── Informational → Continue
      │
      ├── Warning → Review
      │
      └── Error/Critical → Fail Pipeline
```

Semgrep को CI में blocking या alerting दोनों तरीके से use किया जा सकता है।

---

# 📄 18. Custom Semgrep Rule

हम अपनी organization-specific rules भी बना सकते हैं।

Example:

```text
.semgrep/
   rules/
      terraform-security.yml
```

Example:

```yaml
rules:

  - id: example-rule

    pattern: dangerous_function(...)

    message: "Do not use this function."

    severity: ERROR
```

Run:

```powershell
semgrep --config .semgrep/rules/terraform-security.yml .
```

इससे organization अपनी custom security policy implement कर सकती है।

---

# 🔐 19. Semgrep + Terraform

हमारे project में Terraform है:

```text
terraform/
├── main.tf
├── providers.tf
├── variables.tf
├── locals.tf
└── modules/
```

Semgrep को Terraform-related code analysis के लिए use किया जा सकता है, लेकिन यहाँ एक important point है:

> **Terraform IaC security के लिए Trivy हमारा primary scanner रहेगा।**

क्योंकि Trivy पहले से IaC misconfiguration scanning कर रहा है।

इसलिए:

```text
Terraform
   │
   ├── Trivy
   │      ↓
   │   IaC Security
   │
   └── Semgrep
          ↓
      Code Pattern /
      SAST Analysis
```

दोनों को एक-दूसरे का duplicate नहीं बनाना है।

---

# ⚙️ 20. GitHub Actions में Semgrep

हमारे existing CI में:

```text
Terraform fmt
     ↓
Terraform init
     ↓
Terraform validate
     ↓
Trivy
     ↓
Terraform plan
```

अब Semgrep add किया जा सकता है:

```text
Terraform fmt
     ↓
Terraform init
     ↓
Terraform validate
     ↓
Trivy
     ↓
Semgrep
     ↓
Terraform plan
```

Semgrep CI/CD platforms including GitHub Actions के साथ integrate किया जा सकता है।

---

# 🧱 21. GitHub Actions — Basic Semgrep CLI

Simple CLI-based approach:

```yaml
# ==============================================================================
# Semgrep Security Scan
# ==============================================================================

- name: Install Semgrep
  run: python -m pip install semgrep

# ==============================================================================
# Run Semgrep
# ==============================================================================

- name: Semgrep SAST Scan
  run: semgrep --config=auto .
```

यह GitHub-hosted runner पर Semgrep install करके scan करेगा।

इसमें:

```text
Your PC
   │
   └── Nothing required

GitHub Runner
   │
   ├── Python
   ├── Semgrep
   └── Scan
```

---

# 🔥 22. Trivy + Semgrep CI Architecture

हमारे project के लिए recommended architecture:

```text
                 GitHub Repository
                        │
                        ▼
                Feature Branch
                        │
                        ▼
                GitHub Actions CI
                        │
        ┌───────────────┼────────────────┐
        │               │                │
        ▼               ▼                ▼
 Terraform           Trivy           Semgrep
 Validation          IaC Scan         SAST
        │               │                │
        └───────────────┼────────────────┘
                        │
                        ▼
                  Terraform Plan
                        │
                        ▼
                       PR
                        │
                        ▼
                     Review
                        │
                        ▼
                     Approval
                        │
                        ▼
                      main
                        │
                        ▼
                      CD
```

---

# 🔐 23. CI और CD में Security Tool कहाँ होना चाहिए?

Industry practice में security scanning generally **CI/PR stage में** रखना बेहतर है।

क्यों?

```text
Developer
   ↓
Code
   ↓
CI
   ↓
Security Scan
   ↓
Problem मिला
   ↓
PR रोक दो
```

बजाय:

```text
Code
 ↓
Merge
 ↓
CD
 ↓
Deploy
 ↓
Security issue
```

इसलिए हमारे project में:

### CI

```text
Trivy
Semgrep
Terraform Validate
Terraform Plan
```

### CD

```text
Terraform Init
Terraform Plan
Deployment Approval
Terraform Apply
```

---

# 🆚 24. Semgrep और Trivy की Responsibility

## Trivy

```text
Infrastructure
      │
      ├── Terraform
      ├── Docker
      ├── Kubernetes
      └── Dependencies
```

Focus:

```text
Configuration / Vulnerability
```

---

## Semgrep

```text
Application / Configuration Code
            │
            ├── Python
            ├── Java
            ├── JavaScript
            ├── Go
            ├── Terraform
            ├── YAML
            └── Other supported languages
```

Focus:

```text
Code Security / SAST
```

---

# 💻 25. Local Development Workflow

Developer machine पर:

```text
Developer
    │
    ▼
Write Code
    │
    ▼
semgrep --config=auto
    │
    ├── Clean
    │     ↓
    │   Commit
    │
    └── Finding
          ↓
       Fix Code
```

फिर:

```text
git add
git commit
git push
```

---

# 🚀 26. CI Workflow

GitHub पर:

```text
Push
  ↓
GitHub Actions
  ↓
Terraform Validation
  ↓
Trivy
  ↓
Semgrep
  ↓
Terraform Plan
  ↓
CI PASS
```

अगर security policy के अनुसार blocking finding मिली:

```text
Semgrep
   ↓
Finding
   ↓
Exit Code ≠ 0
   ↓
GitHub Actions FAILED
   ↓
PR cannot pass required checks
```

---

# 🧪 27. Installation Validation Checklist

### Check 1 — Python

```powershell
python --version
```

Expected:

```text
Python 3.x.x
```

---

### Check 2 — pip

```powershell
python -m pip --version
```

---

### Check 3 — Semgrep

```powershell
semgrep --version
```

---

### Check 4 — Help

```powershell
semgrep --help
```

---

### Check 5 — Project Scan

```powershell
cd D:\Projects3\comsolve-cyberex-azure-landing-zone
semgrep --config=auto
```

---

# 🔍 28. Troubleshooting

## Problem 1 — `python` not recognized

Try:

```powershell
py --version
```

Then:

```powershell
py -m pip install semgrep
```

---

## Problem 2 — `semgrep` not recognized

Check:

```powershell
python -m pip show semgrep
```

अगर installed है लेकिन command PATH में नहीं है, Python Scripts path check करो।

---

## Problem 3 — Permission Error

Try:

```powershell
python -m pip install --user semgrep
```

---

## Problem 4 — Old pip

Update:

```powershell
python -m pip install --upgrade pip
```

फिर:

```powershell
python -m pip install semgrep
```

---

# 📦 29. Semgrep Installation Without Docker

हमारे case में final architecture:

```text
Windows PC
   │
   ├── Python
   │
   └── Semgrep CLI
```

No:

```text
Docker ❌
SonarQube Server ❌
Database ❌
Elasticsearch ❌
WSL ❌
```

Current Semgrep CE native Windows support का मतलब है कि Windows पर सीधे CLI से scan किया जा सकता है।

---

# 🔐 30. Security Best Practice

Semgrep installation के बाद हमेशा:

```text
1. Version verify
2. Local scan
3. Review findings
4. CI integration
5. Define blocking policy
6. PR protection
```

करना चाहिए।

---

# 📋 31. Recommended Project Security Stack

हमारे current Azure Terraform project में:

```text
                 DevSecOps
                    │
                    ▼
             GitHub Repository
                    │
                    ▼
              GitHub Actions
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
      Trivy                  Semgrep
        │                       │
        ▼                       ▼
   IaC Security              SAST
        │                       │
        └───────────┬───────────┘
                    │
                    ▼
             Terraform Plan
                    │
                    ▼
                   PR
                    │
                    ▼
                 Approval
                    │
                    ▼
                  main
                    │
                    ▼
                   CD
                    │
                    ▼
            Deployment Approval
                    │
                    ▼
             Terraform Apply
                    │
                    ▼
                  Azure
```

---

# 🎯 32. Final Recommendation

हमारे project में अभी **SonarQube install करने की जरूरत नहीं है**।

Recommended:

```text
                 Security Layer
                       │
          ┌────────────┴────────────┐
          │                         │
        Trivy                    Semgrep
          │                         │
      IaC Security                  SAST
          │                         │
      Terraform                  Code
```

इससे:

```text
PC Load
   ↓
Low

Docker
   ↓
Not Required

Server
   ↓
Not Required

Cost
   ↓
Community Edition → Free

CI/CD
   ↓
GitHub Actions → Supported
```

---

# 🏁 33. Phase Completion Criteria

Phase complete तब माना जाएगा जब:

* [ ] Python installed
* [ ] Semgrep installed
* [ ] `semgrep --version` successful
* [ ] Local repository scan successful
* [ ] Findings understood
* [ ] Trivy और Semgrep का role अलग defined
* [ ] GitHub Actions integration planned
* [ ] CI security architecture documented

---

# 📎 Official References

* [Semgrep Community Edition](https://semgrep.dev/products/community-edition/)
* [Semgrep Integrations](https://semgrep.dev/products/integrations/)
* [Semgrep Pricing / Editions](https://semgrep.dev/pricing/)

---

# 🏆 Final Takeaway

> **Trivy + Semgrep = हमारे current Terraform DevSecOps project के लिए lightweight security combination.**

```text
Trivy
  ↓
"IaC / Infrastructure में security problem है?"

Semgrep
  ↓
"Code में insecure pattern है?"

Terraform
  ↓
"Infrastructure सही तरीके से deploy होगा?"

GitHub Actions
  ↓
"इन सभी checks को automatically चलाएगा?"
```

इस तरह security को deployment से पहले ही validate किया जा सकता है।

---

# 🔧 Terraform CD — Azure OIDC Authentication Issue & Resolution

<p align="center">

![Azure](https://img.shields.io/badge/Azure-OIDC-0078D4?logo=microsoftazure\&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-2088FF?logo=githubactions\&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-CD-7B42BC?logo=terraform\&logoColor=white)
![Status](https://img.shields.io/badge/Status-Resolved-success)

</p>

---

## 🎯 Objective

Terraform CD pipeline को `main` branch से Azure में deploy करने के दौरान Azure OIDC authentication failure आया।

इस document में बताया गया है:

* Issue क्या आया
* Error से issue कैसे identify किया
* Error में कौन-सी important information मिली
* Feature/PR और Main branch OIDC में क्या difference है
* Azure Portal में Federated Credential कैसे configure किया
* Exact configuration क्या रखी
* Issue कैसे resolve हुआ
* Resolution के बाद pipeline flow क्या होगा

---

# 1. 🚨 Issue Encountered

Terraform CD pipeline को `main` branch पर merge होने के बाद automatically trigger किया गया।

Pipeline का expected flow था:

```text
Pull Request
      ↓
PR Approval
      ↓
Merge to main
      ↓
Terraform CD
      ↓
Azure Login using OIDC
      ↓
Terraform Plan
      ↓
Deployment Approval
      ↓
Terraform Apply
```

लेकिन CD pipeline में **Azure Login step पर failure** आया।

---

# 2. ❌ Actual Error

GitHub Actions में Azure Login step पर following error आया:

```text
Error: AADSTS7002131: No matching federated identity record found
for presented assertion subject
'repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/main'
or no federated identity credential expression matched.
```

Pipeline log में यह भी दिखाई दिया:

```text
issuer - https://token.actions.githubusercontent.com

subject claim -
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/main

audience -
api://AzureADTokenExchange
```

---

# 3. 🔍 Error से Issue कैसे Identify किया?

Error को ध्यान से देखने पर सबसे important line थी:

```text
AADSTS7002131: No matching federated identity record found
```

इसका मतलब:

> GitHub Actions ने Azure को OIDC token successfully दिया, लेकिन Azure App Registration में उस token के `subject` से match करने वाला Federated Identity Credential मौजूद नहीं था।

### Important Point

यह:

```text
Azure Login configuration problem
```

नहीं था।

यह:

```text
GitHub Secret problem
```

भी नहीं था।

यह:

```text
Terraform problem
```

भी नहीं था।

असल problem थी:

```text
GitHub main branch
        ↓
OIDC Token
        ↓
Subject = main branch
        ↓
Azure App Registration
        ↓
Matching FIC नहीं मिला ❌
```

---

# 4. 🧠 Error से हमें क्या समझ आया?

GitHub Actions OIDC authentication में GitHub एक token issue करता है।

इस token में important claims होते हैं:

```text
Issuer
Subject
Audience
```

हमारे error में:

### Issuer

```text
https://token.actions.githubusercontent.com
```

### Subject

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/main
```

### Audience

```text
api://AzureADTokenExchange
```

Azure App Registration में Federated Credential को इन्हीं values के आधार पर GitHub token को trust करना होता है।

---

# 5. ⚠️ पहले से FIC होने के बावजूद Issue क्यों आया?

हमारे Azure App Registration में पहले से Federated Credentials configured थे।

लेकिन existing credentials अलग GitHub contexts के लिए थे।

उदाहरण:

### Pull Request

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:pull_request
```

### Feature Branch

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/*
```

लेकिन अब CD pipeline run हुई:

```text
main
```

इसलिए GitHub ने नया subject भेजा:

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/main
```

Existing PR/Feature credentials इस subject से match नहीं हुए।

इसलिए:

```text
AADSTS7002131
```

आया।

---

# 6. 🔄 PR OIDC और Main OIDC में Difference

यह distinction बहुत important है।

### PR Pipeline

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:pull_request
```

### Feature Branch Pipeline

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/*
```

### Main Branch CD Pipeline

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/main
```

तीनों अलग subjects हैं।

इसलिए:

```text
PR FIC ≠ Feature FIC ≠ Main FIC
```

---

# 7. 🌐 Resolution — Azure Portal Open करना

सबसे पहले Azure Portal open करें:

```text
https://portal.azure.com
```

---

# 8. 🔐 Microsoft Entra ID / App Registration Open करें

Azure Portal में:

```text
Azure Portal
    ↓
Microsoft Entra ID
    ↓
App registrations
```

---

# 9. 📱 App Registration Select करें

हमारे GitHub Actions OIDC authentication के लिए जिस App Registration का उपयोग किया जा रहा है उसे open करें।

App Registration:

```text
GitHub Actions / Terraform OIDC App
```

इस App Registration में हमारा:

```text
Application (client) ID
```

configured है:

```text
666a02fd-9186-4647-bcac-b9fd1943a1e7
```

---

# 10. 🔗 Federated Credentials Open करें

App Registration के अंदर:

```text
App registrations
    ↓
[GitHub OIDC App]
    ↓
Certificates & secrets
    ↓
Federated credentials
```

अब existing Federated Credentials दिखाई देंगे।

---

# 11. ➕ Add Federated Credential

Click करें:

```text
+ Add credential
```

फिर:

```text
Federated credential scenario
```

में GitHub Actions related option select करें।

अगर portal में GitHub-specific option available नहीं है, तो:

```text
Other issuer
```

select करके values manually enter करें।

---

# 12. ⚙️ Main Branch Federated Credential Configuration

हमारे case में exact configuration:

### Issuer

```text
https://token.actions.githubusercontent.com
```

### Subject Identifier Type

```text
Explicit subject identifier
```

### Subject

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/main
```

### Audience

```text
api://AzureADTokenExchange
```

### Name

```text
github-main-terraform-cd
```

### Description

```text
GitHub Actions OIDC authentication for Terraform CD main branch
```

---

# 13. 📋 Final Configuration

| Setting      | Value                                                                                                  |
| ------------ | ------------------------------------------------------------------------------------------------------ |
| Issuer       | `https://token.actions.githubusercontent.com`                                                          |
| Subject Type | Explicit subject identifier                                                                            |
| Subject      | `repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/main` |
| Audience     | `api://AzureADTokenExchange`                                                                           |
| Name         | `github-main-terraform-cd`                                                                             |
| Description  | GitHub Actions OIDC authentication for Terraform CD main branch                                        |

---

# 14. 💾 Create Credential

सभी values verify करने के बाद:

```text
Add
```

या

```text
Save
```

पर click करें।

अब Azure App Registration में नया Federated Credential create हो जाएगा।

---

# 15. 🔎 Credential का Purpose

अब Azure के पास यह trust relationship है:

```text
GitHub Actions
      ↓
ComSolve-Cloud-Lab
      ↓
comsolve-cyberex-azure-landing-zone
      ↓
main branch
      ↓
OIDC Token
      ↓
Azure App Registration
      ↓
github-main-terraform-cd
      ↓
MATCH ✅
```

इसलिए Azure अब main branch से आने वाले GitHub OIDC token को accept कर सकता है।

---

# 16. 🔁 GitHub Actions Pipeline Re-run

Azure में FIC create करने के बाद GitHub repository open करें:

```text
GitHub
   ↓
ComSolve-Cloud-Lab
   ↓
comsolve-cyberex-azure-landing-zone
   ↓
Actions
```

फिर failed:

```text
Terraform CD
```

workflow open करें।

Failed run को open करके:

```text
Re-run failed jobs
```

select करें।

---

# 17. ✅ Expected Result — Azure Login

इस बार:

```text
Run azure/login@v2
```

step successfully complete होना चाहिए।

Expected:

```text
Running Azure CLI Login.
Done setting cloud: "azurecloud"

Attempting Azure CLI login by using OIDC...

Login successful.
```

---

# 18. 🚀 Expected Terraform CD Flow

Azure OIDC login successful होने के बाद pipeline का complete flow:

```text
main
 ↓
Terraform CD
 ↓
Checkout
 ↓
Azure Login using OIDC
 ↓
Verify Azure Login
 ↓
Setup Terraform
 ↓
Terraform Init
 ↓
Terraform Plan
 ↓
Upload tfplan
 ↓
terraform-apply
 ↓
Comsolve_production Environment
 ↓
Deployment Approval
 ↓
Terraform Apply
 ↓
Azure Infrastructure
```

---

# 19. 🔐 Important — Deployment Approval अभी भी अलग है

यह OIDC issue resolve होने के बाद भी:

```text
Comsolve_production
```

environment का approval रहेगा।

मतलब:

### Authentication

```text
GitHub → Azure
```

automatically होगा।

### Deployment

```text
Terraform Apply
```

से पहले human approval required रहेगा।

इसलिए:

```text
Azure Login
    ↓
Automatic
```

लेकिन:

```text
Terraform Apply
    ↓
Comsolve_production
    ↓
Manual Approval
```

होगा।

---

# 20. 🧪 Validation

### 🔍 What to Validate

Check करें:

```text
Azure Login = Success
Terraform Init = Success
Terraform Plan = Success
tfplan Artifact = Uploaded
Comsolve_production = Waiting for Approval
Terraform Apply = Approval के बाद execute
```

---

### ✅ Best Practice

Production CD के लिए:

```text
OIDC Authentication
        +
Saved Terraform Plan
        +
Environment Approval
        +
Exact Plan Apply
```

use करना चाहिए।

हमारे workflow में यही architecture implement किया गया है।

---

### 🧪 Validation Test

GitHub Actions में:

```text
Terraform CD
```

open करें और verify करें:

```text
terraform-plan
    ├── Azure Login ✅
    ├── Terraform Init ✅
    ├── Terraform Plan ✅
    └── Upload tfplan ✅

terraform-apply
    ├── Environment Approval ⏳
    └── Terraform Apply
```

---

### 🎯 Expected Result

Expected final flow:

```text
main
  │
  ▼
Terraform Plan
  │
  ▼
tfplan Artifact
  │
  ▼
Comsolve_production
  │
  ▼
Manual Approval
  │
  ▼
Terraform Apply
  │
  ▼
Azure Resources
```

---

# 21. 🧾 Root Cause

### Root Cause

Terraform CD pipeline `main` branch से execute हो रही थी, लेकिन Azure App Registration में `main` branch के exact GitHub OIDC subject के लिए Federated Identity Credential configured नहीं था।

Existing FICs:

```text
Pull Request
Feature Branch
```

के लिए थे।

लेकिन CD को चाहिए था:

```text
Main Branch
```

इस mismatch के कारण Azure ने GitHub OIDC assertion को reject किया।

---

# 22. 🛠️ Resolution

Resolution के लिए Azure App Registration में नया Federated Credential add किया गया:

```text
Name:
github-main-terraform-cd
```

जिसमें main branch का exact subject configure किया गया:

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/main
```

इसके बाद GitHub Actions CD pipeline को re-run किया गया।

---

# 23. 📚 Key Learning

इस issue से सबसे important learning:

```text
GitHub OIDC Authentication
```

में केवल:

```text
Client ID
Tenant ID
Subscription ID
```

सही होना enough नहीं है।

Azure App Registration में GitHub token के:

```text
Issuer
Subject
Audience
```

का matching Federated Credential भी होना चाहिए।

विशेष रूप से:

```text
PR
Feature Branch
Main Branch
```

के subjects अलग हो सकते हैं।

इसलिए प्रत्येक required GitHub execution context के लिए appropriate Federated Credential configuration maintain करनी चाहिए।

---

# 24. 🎯 Final Architecture

```text
                         GitHub
                            │
                            │ OIDC Token
                            ▼
              ┌──────────────────────────┐
              │     GitHub Actions       │
              │                          │
              │       main branch        │
              └────────────┬─────────────┘
                           │
                           ▼
              ┌──────────────────────────┐
              │ Azure App Registration   │
              │                          │
              │ Federated Credential     │
              │                          │
              │ github-main-terraform-cd │
              └────────────┬─────────────┘
                           │
                           │ Token Match
                           ▼
                    Azure Login ✅
                           │
                           ▼
                  Terraform Plan
                           │
                           ▼
                    tfplan Artifact
                           │
                           ▼
                Comsolve_production
                           │
                           ▼
                  Manual Approval
                           │
                           ▼
                    Terraform Apply
                           │
                           ▼
                    Azure Resources
```

---

# 🏁 Conclusion

Issue का actual कारण **Terraform या GitHub Actions YAML नहीं था**।

Error:

```text
AADSTS7002131
No matching federated identity record found
```

ने clearly बताया कि Azure App Registration में GitHub OIDC token के लिए matching Federated Credential missing था।

हमने error में मिले:

```text
Issuer
Subject
Audience
```

को identify किया और विशेष रूप से `main` branch के exact `subject` को Azure App Registration में Federated Credential के रूप में configure किया।

इसके बाद CD pipeline Azure से OIDC authentication successfully establish कर सकती है और आगे:

```text
Plan → Approval → Apply
```

controlled production deployment flow continue करता है।


---