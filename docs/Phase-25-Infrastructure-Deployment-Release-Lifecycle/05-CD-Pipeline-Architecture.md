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