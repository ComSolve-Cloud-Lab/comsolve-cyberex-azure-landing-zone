# 🚀 Phase 20.3 — GitHub Required Status Checks & CI Security Gate

<p align="center">

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-623CE4?style=for-the-badge&logo=terraform&logoColor=white)

![Trivy](https://img.shields.io/badge/Trivy-Security%20Scan-1904DA?style=for-the-badge)

![Branch Protection](https://img.shields.io/badge/Branch%20Protection-Required-success?style=for-the-badge)

![Security Gate](https://img.shields.io/badge/Security%20Gate-Enforced-red?style=for-the-badge)

</p>

> 🎯 **Objective:** GitHub Repository की `main` branch पर GitHub Actions CI checks को **Required Status Checks** बनाना, ताकि Terraform validation या Trivy security scan fail होने पर Pull Request को `main` में merge न किया जा सके।

---

# 📌 1. Current Position

Phase 20.1 में हमने Repository Governance और Branch Protection की foundation तैयार की।

अब हमारा focus है:

```text
Pull Request
      ↓
GitHub Actions
      ↓
Terraform CI
      ↓
Trivy Security Scan
      ↓
Terraform Plan
      ↓
PASS / FAIL
      ↓
Merge Decision
```


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


📂 3. Existing CI Pipeline

हमारे Repository में existing workflow:

.github/
└── workflows/
    └── terraform-ci.yml

Pipeline का current flow:

Checkout
   ↓
Azure Login
   ↓
Azure Subscription Verify
   ↓
Terraform Setup
   ↓
Terraform Format
   ↓
Terraform Init
   ↓
Terraform Validate
   ↓
Trivy IaC Scan
   ↓
Terraform Plan
🟢 STEP 01 — Repository में Workflow Verify करें

PowerShell में Repository root से run करें:

Get-Content .\.github\workflows\terraform-ci.yml

Check करें कि workflow में:

name: Terraform CI

मौजूद है।

और:

jobs:
  terraform:

मौजूद है।

🟢 STEP 02 — Workflow Name समझें

हमारे workflow में:

name: Terraform CI

है।

लेकिन Required Status Check configure करते समय GitHub में अक्सर पूरा job/check name दिखाई देता है।

इसलिए हमें अनुमान नहीं लगाना है।

पहले एक वास्तविक Pull Request create करके GitHub Actions का exact check name देखेंगे।

🟢 STEP 03 — Test Branch Create करें

PowerShell:

git checkout main

Latest code लें:

git pull origin main

अब testing branch बनाएँ:

git checkout -b feature/required-status-check

Verify करें:

git branch

Expected:

* feature/required-status-check
  main


तुम्हारे case में main से नई branch बनाकर test करना सही नहीं रहेगा, क्योंकि Azure/GitHub Actions की authentication/permission setup अभी feature/nic-infrastructure के साथ जुड़ी हुई है।

इसलिए Phase 20.2 की testing भी feature/nic-infrastructure से branch बनाकर करेंगे।

तुम्हारा current flow:

main
  ↓
❌ नई branch
  ↓
GitHub Actions
  ↓
Azure authentication / permissions issue
  ↓
Pipeline FAIL

हमारा practical flow:

feature/nic-infrastructure
          ↓
          ↓
feature/required-status-check
          ↓
GitHub Actions
          ↓
Azure Authentication
          ↓
Terraform CI
          ↓
Trivy
          ↓
Terraform Plan
          ↓
✅ PASS
इसलिए Step 03 को ऐसे बदलो
git checkout feature/nic-infrastructure

Latest code:

git pull origin feature/nic-infrastructure

Testing branch:

git checkout -b feature/required-status-check

Verify:

git branch

Expected:

  feature/nic-infrastructure
* feature/required-status-check
  main
⚠️ एक important बात

तुमने जो Azure Agent/Secrets को feature/nic-infrastructure तक restrict किया है, उसकी वजह से feature/* pattern automatically permission नहीं दे रहा — यह branch/ref restriction का behavior है।

इसलिए अभी हम existing working branch से ही testing branch बनाएँगे, ताकि पहले से working Azure authentication और CI setup को disturb न करें।

बाद में Phase 20.6 में हम इस permission model को properly organization/repository governance + environments + branch rules के हिसाब से clean करेंगे।

----


# 🟢 STEP 04 — Safe Test Change करें

किसी Terraform resource को modify नहीं करना है।

सिर्फ documentation में एक छोटी line add करें।

Example:

README.md

या:

docs/Phase-20.2-GitHub-Repository-Governance.md

में change करें।

# 🟢 STEP 05 — Commit करें
git status

फिर:

git add .

Commit:

git commit -m "docs: add required status checks governance"


### 🟢 STEP 06 — Branch Push करें
git push -u origin feature/required-status-check

अब GitHub पर branch दिखाई देगी।

🟢 STEP 07 — Pull Request Create करें

GitHub Repository खोलें।

Path:

Pull requests
     ↓
New pull request

Select करें:

base:
main

compare:
feature/required-status-check

फिर:

Create pull request
🟢 STEP 08 — GitHub Actions Run होने दें

PR open करने के बाद GitHub Actions automatically run होगी।

Expected:

Terraform CI
     ↓
Terraform Format
     ↓
Terraform Init
     ↓
Terraform Validate
     ↓
Trivy
     ↓
Terraform Plan

सभी checks complete होने दें।

🟢 STEP 09 — Exact Status Check Name Identify करें

Pull Request में:

Checks

tab खोलें।

यहाँ हमें GitHub द्वारा generated exact check/job name देखना है।

Example:

Terraform Validation

या:

Terraform CI / Terraform Validation

या GitHub UI में जो exact name दिखाई दे।

⚠️ यहाँ manually name नहीं लिखना है। GitHub में जो exact check name दिखाई दे वही use करना है।

🔐 STEP 10 — Repository Settings Open करें

GitHub Repository:

Settings
   ↓
Branches

अब main branch की protection configuration खोलें।

अगर नया GitHub Rulesets interface दिखाई देता है तो:

Settings
   ↓
Rules
   ↓
Rulesets

का उपयोग किया जा सकता है।

🟢 STEP 11 — Main Branch Rule Select करें

Target branch:

main

है।

Rule का उद्देश्य:

main
 ↓
Protected
 ↓
PR Required
 ↓
Status Checks Required
🔒 STEP 12 — Required Status Checks Enable करें

Option:

Require status checks to pass before merging

को enable करें।

इसके बाद GitHub check search करने का option देगा।

🟢 STEP 13 — Terraform CI Check Add करें

अब Step 09 में जो exact check name मिला था उसे search करें।

Example:

Terraform Validation

उस check को select करें।

Expected:

Required Status Checks

☑ Terraform Validation
🔐 STEP 14 — Branch Protection Strict रखें

अगर option मिले:

Require branches to be up to date before merging

तो इसे enable करने से पहले team workflow consider करें।

Strict mode में PR branch को latest main के साथ updated रखना पड़ सकता है।

इस project के लिए शुरुआती implementation में:

Required CI Check
        +
PR Approval
        +
Protected main

मुख्य security controls हैं।

🧪 STEP 15 — Save Protection Rule

Configuration verify करें:

Target:
main

Pull Request:
Required

Approval:
Required

Status Check:
Required

Force Push:
Disabled

Deletion:
Disabled

फिर:

Save changes

करें।

🔥 STEP 16 — पहला Practical Test

अब वही Pull Request खुला रहने दें।

PR में:

Checks

section देखें।

Expected:

Terraform CI
   ✅ Passed

अब merge button available होना चाहिए, provided बाकी branch protection requirements भी satisfied हों।

🚨 STEP 17 — Failure Test

अब हमें security gate को practically test करना है।

Test branch में ऐसा temporary Terraform change करें जिससे validation fail हो।

उदाहरण के लिए intentionally invalid Terraform syntax डाल सकते हैं।

⚠️ यह change केवल test branch में करें। main में कभी नहीं।

फिर:

git add .
git commit -m "test: validate failed CI merge protection"
git push

GitHub Actions फिर से run होगी।

Expected:

Terraform Validate
        ↓
❌ FAILED

या कोई दूसरा required CI check fail होगा।

🚫 STEP 18 — Merge Blocking Verify करें

अब Pull Request में देखें।

Expected behavior:

Required check
      ↓
❌ Failed
      ↓
Merge blocked

GitHub को PR merge नहीं करने देना चाहिए।

यही हमारी CI Security Gate है।

🟢 STEP 19 — Test Fix करें

अब intentionally broken code को वापस सही करें।

git status

फिर:

git add .

Commit:

git commit -m "fix: restore valid terraform configuration"

Push:

git push
🟢 STEP 20 — Successful CI Verify करें

GitHub Actions फिर run होगी।

Expected:

Terraform Format
        ✅

Terraform Init
        ✅

Terraform Validate
        ✅

Trivy
        ✅

Terraform Plan
        ✅

अब:

Required Checks
       ↓
ALL PASS
       ↓
Merge Allowed
🔐 STEP 21 — Final Security Flow

हमारे Repository का final PR flow अब:

Developer
    ↓
Feature Branch
    ↓
Pull Request
    ↓
GitHub Actions
    ↓
Terraform Validation
    ↓
Trivy Security Scan
    ↓
Terraform Plan
    ↓
Required Status Checks
    ↓
Code Review
    ↓
Approval
    ↓
Merge to main
🚫 STEP 22 — Failure Scenario

अगर Trivy fail करता है:

Pull Request
     ↓
Trivy
     ↓
❌ FAILED
     ↓
Required Check Failed
     ↓
🚫 Merge Blocked

अगर Terraform Validate fail करता है:

Pull Request
     ↓
Terraform Validate
     ↓
❌ FAILED
     ↓
🚫 Merge Blocked
🟢 STEP 23 — Success Scenario
Pull Request
     ↓
Terraform Format
     ↓
Terraform Init
     ↓
Terraform Validate
     ↓
Trivy
     ↓
Terraform Plan
     ↓
✅ ALL REQUIRED CHECKS PASSED
     ↓
Reviewer Approval
     ↓
Merge
🧪 STEP 24 — Final Validation Checklist
Validation	Expected
Feature branch created	✅
Pull Request created	✅
GitHub Actions executed	✅
Exact CI check identified	✅
Required Status Check configured	⏳
CI failure blocks merge	⏳
CI success allows merge	⏳
Main branch protected	⏳
PR approval required	⏳
Force push disabled	⏳
📊 STEP 25 — Phase 20.2 Final State

Implementation complete होने के बाद:

                    GitHub Repository
                           │
                           ▼
                    Protected main
                           │
                    ┌──────┴──────┐
                    │             │
                    ▼             ▼
              Pull Request    No Direct Push
                    │
                    ▼
              Required CI
                    │
          ┌─────────┼─────────┐
          ▼         ▼         ▼
      Terraform    Trivy    Plan
      Validate     Scan
          │         │         │
          └─────────┼─────────┘
                    ▼
               All Passed
                    │
                    ▼
              Code Approval
                    │
                    ▼
                Merge main
📝 Phase 20.2 Status
Governance Control	Status
Main Branch Protection	✅ Phase 20.1
Pull Request Requirement	✅ Phase 20.1
Required Status Checks	⏳ Phase 20.2
Terraform CI Gate	⏳
Trivy Security Gate	⏳
Failed CI Merge Blocking	⏳
Successful CI Merge	⏳
Force Push Protection	⏳
Branch Deletion Protection	⏳
🧠 What We Implemented

इस Phase में हमारा मुख्य practical achievement होगा:

CI सिर्फ report नहीं करेगा
        ↓
CI अब Merge Gate बनेगा

मतलब:

Security/Infrastructure Check Failed
             ↓
       Merge नहीं होगा

और:

All Required Checks Passed
             ↓
       Review + Approval
             ↓
          Merge
🚀 Next Phase

Phase 20.2 के बाद:

Phase 20.3
     ↓
Secret Scanning
     ↓
Repository में accidentally committed
secrets / credentials को detect और protect करना

इसके बाद:

Phase 20.4
     ↓
Dependabot
Phase 20.5
     ↓
Repository Governance Policy
Phase 20.6
     ↓
GitHub Organization
+
Team-Based Access

🔐 Security Principle: कोई भी Pull Request तब तक main में merge नहीं होना चाहिए जब तक सभी mandatory CI और security checks सफलतापूर्वक pass न हो जाएँ।


**इस Phase में खास बात:** हम सिर्फ setting नहीं लगाएंगे—**एक बार intentionally CI fail करके merge-blocking behavior


Bilkul bhai 👍 manual approval लगा है, इसलिए CI PASS → Merge Allowed का मतलब automatic merge नहीं है। वहाँ wording थोड़ी confusing है।

हमारा actual flow यह है:

Developer
    ↓
feature branch पर code change
    ↓
Pull Request → main
    ↓
┌─────────────────────────┐
│ GitHub Actions          │
│ Terraform CI            │
│ Trivy Scan              │
│ Terraform Plan          │
└─────────────────────────┘
    ↓
   PASS
    ↓
Reviewer Approval
    ↓
   APPROVED
    ↓
GitHub Governance Rules
    ↓
✅ Merge Allowed
    ↓
Human / Maintainer
    ↓
Merge PR
    ↓
main

अगर CI fail:

Pull Request
    ↓
CI / Trivy / Terraform
    ↓
❌ FAIL
    ↓
Merge ❌ BLOCKED

और अगर CI PASS लेकिन reviewer approval नहीं है:

CI ✅
   ↓
Approval ❌
   ↓
Merge ❌ BLOCKED
इसलिए हमारे project में सही principle

CI PASS अकेले merge नहीं करता।
CI PASS + Required Reviewer Approval + सभी Repository Rules PASS होने के बाद ही human reviewer/maintainer merge करता है।

तो तुम्हारे document में:

CI PASS
   ↓
Merge Allowed

की जगह बेहतर होगा:

CI PASS
   ↓
Required Reviewer Approval
   ↓
Repository Rules PASS
   ↓
Human Reviewer / Maintainer
   ↓
Merge

यही हमारा Secure PR Flow है। 🔐
