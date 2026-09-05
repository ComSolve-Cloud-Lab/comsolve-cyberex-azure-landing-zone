# 🚀 Phase 25.02 — Pull Request Creation

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Pull_Request-black?logo=github)
![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-blue?logo=githubactions)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?logo=terraform)
![Azure](https://img.shields.io/badge/Azure-Cloud-blue?logo=microsoftazure)
![Security](https://img.shields.io/badge/Security-PR_Governance-red?logo=security)
![DevOps](https://img.shields.io/badge/DevOps-CI%2FCD-orange?logo=azuredevops)

</p>

---

## 🎯 Objective

इस phase का objective यह समझना और practically implement करना है कि एक **Feature Branch से Pull Request (PR)** कैसे create होती है और production infrastructure में merge होने से पहले कौन-कौन से validation और review controls लागू होते हैं।

हम अपने current project:

```text
comsolve-cyberex-azure-landing-zone
```

में following industrial flow implement करेंगे:

```text
Developer
   ↓
Feature Branch
   ↓
Code Changes
   ↓
Git Commit
   ↓
Git Push
   ↓
Pull Request
   ↓
GitHub Actions CI
   ├── Terraform fmt
   ├── Terraform init
   ├── Terraform validate
   ├── Trivy Security Scan
   └── Terraform Plan
   ↓
AI Code Review
   ↓
Human Code Review
   ↓
Approval
   ↓
Merge → main
   ↓
Phase 25.03
PR Approval
```

---

# 🔹 1. Pull Request क्या होता है?

Pull Request यानी **PR** GitHub का mechanism है जिसके द्वारा developer अपने changes को एक branch से दूसरी branch में merge करने का request करता है।

Example:

```text
feature/network-change
        │
        │ Pull Request
        ↓
      main
```

इसका मतलब:

> "मेरे feature branch में जो changes हैं, उन्हें main branch में merge करने से पहले review और validation कर लो।"

---

# 🔹 2. हमारे Project में PR क्यों जरूरी है?

हमारा project normal application code नहीं है।

यह:

```text
Terraform
   ↓
Azure Infrastructure
   ↓
Networking
   ↓
Security
   ↓
Cloud Resources
```

manage करता है।

इसलिए एक छोटी Terraform mistake भी production infrastructure को प्रभावित कर सकती है।

Example:

```text
Developer accidentally changes:

10.10.0.0/16
        ↓
10.0.0.0/8
```

या:

```text
private subnet
      ↓
public subnet
```

या:

```text
NSG rule
      ↓
0.0.0.0/0
```

ऐसी changes को direct `main` में जाने देना dangerous है।

इसलिए:

```text
Feature Branch
      ↓
Pull Request
      ↓
Validation
      ↓
Review
      ↓
Approval
      ↓
Merge
```

---

# 🔹 3. Industrial Pull Request Architecture

हमारा complete architecture:

```text
                    Developer
                       │
                       ▼
              Feature Branch
                       │
                       ▼
                  Git Commit
                       │
                       ▼
                   Git Push
                       │
                       ▼
              ┌─────────────────┐
              │  Pull Request   │
              └────────┬────────┘
                       │
             ┌─────────┼─────────┐
             │         │         │
             ▼         ▼         ▼
            CI       Trivy      AI Review
             │         │         │
             └─────────┼─────────┘
                       │
                       ▼
                Human Review
                       │
                       ▼
                    Approval
                       │
                       ▼
                 Merge → main
                       │
                       ▼
                Phase 25.03
```

---

# 🔹 4. Feature Branch से PR तक Complete Flow

हमारे project में example लेते हैं:

```text
feature/network-foundation-update
```

Developer:

```text
Feature Branch
      ↓
Terraform Code Change
      ↓
Local Validation
      ↓
Commit
      ↓
Push
      ↓
Create PR
      ↓
CI Validation
      ↓
AI Review
      ↓
Human Review
      ↓
Approval
```

---

# 🔹 5. Step 1 — Current Branch Check

सबसे पहले check करें:

```powershell
git branch
```

Expected:

```text
* feature/network-foundation-update
  main
```

यह confirm करता है कि हम `main` पर directly काम नहीं कर रहे हैं।

---

# 🔹 6. Step 2 — Git Status

```powershell
git status
```

Example:

```text
On branch feature/network-foundation-update

Changes not staged for commit:
  modified:
    terraform/modules/vnet/main.tf
```

इससे पता चलता है कि कौन-कौन से files modify हुए हैं।

---

# 🔹 7. Step 3 — Changes Review

पहले complete diff देखना चाहिए:

```powershell
git diff
```

या summary:

```powershell
git diff --stat
```

Example:

```text
terraform/modules/vnet/main.tf | 8 +++++---
1 file changed
```

---

# 🔹 8. Step 4 — Local Terraform Validation

PR बनाने से पहले developer को local validation करना चाहिए।

```powershell
cd terraform
```

### Terraform Format

```powershell
terraform fmt -check -recursive
```

### Terraform Validate

```powershell
terraform validate
```

### Terraform Plan

```powershell
terraform plan
```

### Trivy

```powershell
trivy config . --severity HIGH,CRITICAL
```

फिर:

```powershell
cd ..
```

---

# 🔹 9. Step 5 — Git Add

Specific file:

```powershell
git add terraform/modules/vnet/main.tf
```

या complete changes:

```powershell
git add .
```

फिर verify:

```powershell
git status
```

---

# 🔹 10. Step 6 — Git Commit

Example:

```powershell
git commit -m "feat: update Azure VNet configuration"
```

Good commit message:

```text
feat: update Azure VNet configuration
```

Bad:

```text
changes
```

या:

```text
test
```

Industrial environment में commit message meaningful होना चाहिए।

---

# 🔹 11. Step 7 — Push Feature Branch

```powershell
git push origin feature/network-foundation-update
```

अब GitHub पर branch दिखाई देगी:

```text
main
feature/network-foundation-update
```

---

# 🔹 12. Step 8 — Pull Request Create करना

GitHub repository open करें:

```text
ComSolve-Cloud-Lab
        ↓
comsolve-cyberex-azure-landing-zone
```

फिर:

```text
Pull requests
      ↓
New pull request
```

Select:

```text
base:
main

compare:
feature/network-foundation-update
```

फिर:

```text
Create pull request
```

---

# 🔹 13. PR का मतलब अब क्या है?

अब GitHub कह रहा है:

```text
feature/network-foundation-update
              │
              │
              ▼
            main
```

लेकिन अभी merge नहीं हुआ है।

यह सबसे important point है।

```text
PR Created
     ≠
Code Merged
```

PR सिर्फ merge request है।

---

# 🔹 14. PR में क्या-क्या दिखेगा?

GitHub PR में normally:

```text
Conversation
Commits
Checks
Files changed
Reviewers
```

देखने को मिलते हैं।

सबसे important:

```text
Files changed
```

यहीं reviewer देखता है कि actual code में क्या बदला।

---

# 🔹 15. Real Terraform PR Example

मान लो developer ने VNet बदल दिया:

Before:

```hcl
address_space = ["10.10.0.0/16"]
```

After:

```hcl
address_space = ["10.20.0.0/16"]
```

PR में reviewer देखेगा:

```diff
- address_space = ["10.10.0.0/16"]
+ address_space = ["10.20.0.0/16"]
```

अब reviewer पूछ सकता है:

```text
Why is the VNet CIDR changing?

Will this impact existing subnets?

Does Terraform plan show resource replacement?
```

---

# 🔹 16. PR Create होते ही CI शुरू

हमारे existing:

```text
.github/workflows/terraform-ci.yml
```

में trigger है:

```yaml
on:

  push:
    branches:
      - "feature/**"

  pull_request:
    branches:
      - main
```

इसलिए PR create/update होने पर CI run होगा।

Flow:

```text
PR
 ↓
GitHub Actions
 ↓
Terraform CI
```

---

# 🔹 17. Current CI Pipeline

हमारे current pipeline में:

```text
Checkout
   ↓
Azure Login
   ↓
Terraform Setup
   ↓
terraform fmt
   ↓
terraform init
   ↓
terraform validate
   ↓
Trivy
   ↓
terraform plan
```

Architecture:

```text
Pull Request
     │
     ▼
┌─────────────────────┐
│ GitHub Actions CI   │
├─────────────────────┤
│ Terraform fmt       │
│ Terraform init      │
│ Terraform validate  │
│ Trivy               │
│ Terraform plan      │
└──────────┬──────────┘
           │
           ▼
      Checks Passed
```

---

# 🔹 18. CI Pass होने के बाद क्या?

Example:

```text
Terraform fmt       ✅
Terraform init      ✅
Terraform validate  ✅
Trivy               ✅
Terraform plan      ✅
```

अब PR में:

```text
All checks have passed
```

दिख सकता है।

लेकिन:

> CI Pass ≠ Approval

CI सिर्फ automated validation है।

---

# 🔹 19. CI और Code Review में Difference

| CI                 | Code Review        |
| ------------------ | ------------------ |
| Automated          | Human/AI           |
| Syntax check       | Architecture check |
| Terraform validate | Design validation  |
| Trivy              | Security reasoning |
| Plan               | Business impact    |
| Machine-based      | Context-based      |

Example:

Terraform:

```hcl
location = "centralindia"
```

CI कहेगा:

```text
Syntax valid
```

लेकिन reviewer पूछ सकता है:

```text
क्या production workload Central India में होना चाहिए?
```

यह contextual decision है।

---

# 🔹 20. AI Code Review कहाँ आएगा?

Industrial flow में:

```text
PR
 │
 ├── CI
 │
 ├── Security Scan
 │
 └── AI Code Review
          │
          ▼
     Human Review
          │
          ▼
       Approval
```

AI reviewer Terraform changes को देखकर issues identify कर सकता है।

उदाहरण:

```text
⚠️ Public IP detected

⚠️ CIDR range changed

⚠️ Security rule allows 0.0.0.0/0

⚠️ Resource naming inconsistent

⚠️ Missing tags

⚠️ Potential production impact
```

---

# 🔹 21. AI Review को Final Authority क्यों नहीं बनाना चाहिए?

AI useful है लेकिन:

```text
AI
 ↓
Recommendation
```

ना कि:

```text
AI
 ↓
Automatic Production Approval
```

Best practice:

```text
Automated CI
      +
Security Scan
      +
AI Review
      +
Human Approval
      ↓
Production
```

GitHub भी Copilot review output को human review से supplement करने की सलाह देता है।

---

# 🔹 22. GitHub Copilot Code Review

Current GitHub Copilot Code Review में PR के अंदर Copilot को reviewer के रूप में request किया जा सकता है।

Flow:

```text
Pull Request
      ↓
Reviewers
      ↓
Copilot
      ↓
Request
      ↓
AI Review
```

Copilot comments में severity जैसे:

```text
High
Medium
Low
```

आ सकती है और suggested changes भी मिल सकते हैं।

---

# 🔹 23. Automatic AI Review

अगर organization/repository में configure किया जाए तो Copilot PRs को automatically review कर सकता है।

Possible model:

```text
PR Created
    ↓
CI Started
    ↓
Copilot Review
    ↓
Human Review
```

Automatic review को new pushes पर भी trigger करने के लिए configuration उपलब्ध है।

---

# 🔹 24. AI को Terraform Project समझाना

AI review को generic नहीं रखना चाहिए।

Repository में instructions रख सकते हैं:

```text
.github/copilot-instructions.md
```

इसमें project-specific rules define किए जा सकते हैं।

Example:

```text
Review Terraform changes with focus on:

1. Azure security
2. Network architecture
3. CIDR overlap
4. Public exposure
5. NSG rules
6. Naming conventions
7. Resource tagging
8. Terraform best practices
9. Least privilege
10. Production impact
```

GitHub Copilot repository custom instructions को code review के दौरान use कर सकता है।

---

# 🔹 25. हमारे Project के लिए AI Review Checklist

AI reviewer को mainly इन areas पर focus करवाना चाहिए:

```text
Terraform
 ├── Syntax
 ├── Variables
 ├── Modules
 ├── Dependencies
 └── State impact

Azure
 ├── VNet
 ├── Subnet
 ├── NSG
 ├── Public IP
 ├── Key Vault
 └── RBAC

Security
 ├── Public exposure
 ├── 0.0.0.0/0
 ├── Secrets
 ├── Least privilege
 └── Encryption

Operations
 ├── Naming
 ├── Tags
 ├── Cost
 └── Maintainability
```

---

# 🔹 26. AI + Terraform Plan

AI review को सिर्फ `.tf` files तक सीमित रखना जरूरी नहीं है।

बेहतर architecture:

```text
Terraform Code
      ↓
Terraform Plan
      ↓
Plan Output
      ↓
AI Review
      ↓
Risk Analysis
```

Example:

Terraform plan:

```text
16 to add
0 to change
0 to destroy
```

AI को समझाया जा सकता है:

```text
Review this Terraform plan.

Focus on:
- destructive changes
- public resources
- networking changes
- security exposure
- unexpected resource creation
```

इससे AI actual infrastructure impact समझने में ज्यादा useful हो सकता है।

---

# 🔹 27. PR Description कैसे लिखें?

PR description में minimum यह होना चाहिए:

```text
## Summary

Updated Azure VNet configuration.

## Changes

- Updated VNet configuration
- Updated subnet configuration
- Updated Terraform module

## Validation

- terraform fmt
- terraform validate
- terraform plan
- Trivy

## Security Impact

No HIGH/CRITICAL findings.

## Deployment Impact

No destructive changes expected.

## Rollback

Revert the PR commit.
```

---

# 🔹 28. Industrial PR Flow

अब complete lifecycle:

```text
Developer
   │
   ▼
Feature Branch
   │
   ▼
Terraform Changes
   │
   ▼
Local Validation
   │
   ├── fmt
   ├── validate
   ├── plan
   └── Trivy
   │
   ▼
Git Commit
   │
   ▼
Git Push
   │
   ▼
Pull Request
   │
   ├───────────────┐
   │               │
   ▼               ▼
GitHub CI       AI Review
   │               │
   └───────┬───────┘
           ▼
      Human Review
           │
           ▼
        Approval
           │
           ▼
      Merge → main
```

---

# 🔹 29. Real Industrial Example

मान लो developer को नया subnet add करना है:

```text
VNet
10.10.0.0/16
```

New subnet:

```text
app-subnet
10.10.10.0/24
```

Developer:

```text
feature/add-app-subnet
```

पर change करता है।

Flow:

```text
Developer
    ↓
Add subnet
    ↓
terraform fmt
    ↓
terraform validate
    ↓
terraform plan
    ↓
Trivy
    ↓
Commit
    ↓
Push
    ↓
PR
```

अब:

```text
CI → PASS
AI → PASS
Human → APPROVE
```

फिर:

```text
Merge → main
```

और अगला phase:

```text
CD Pipeline
```

start करेगा।

---

# 🔹 30. PR Governance

Production repository में direct push रोकना चाहिए:

```text
Developer
    X
    │
    └──────→ main
```

Allowed:

```text
Developer
    ↓
Feature Branch
    ↓
PR
    ↓
Checks
    ↓
Approval
    ↓
main
```

इसका मतलब:

```text
main = Protected Production Branch
```

---

# 🔹 31. PR में Required Controls

हमारे project के लिए recommended controls:

```text
☑ Pull Request required
☑ CI checks required
☑ Terraform validation
☑ Trivy security scan
☑ Terraform plan
☑ Code review
☑ Human approval
☑ Main branch protection
☑ No direct push
```

---

# 🔹 32. PR Failure Scenario

मान लो Trivy कहता है:

```text
HIGH severity finding
```

Flow:

```text
PR
 ↓
CI
 ↓
Trivy
 ↓
❌ FAILED
```

अब:

```text
Merge
  X
```

Developer को fix करना होगा।

```text
Fix
 ↓
Commit
 ↓
Push
 ↓
PR automatically updates
 ↓
CI runs again
```

---

# 🔹 33. PR Update होने पर क्या होता है?

Suppose:

```text
PR #25
```

पहले CI failed।

Developer fix करता है:

```powershell
git add .
git commit -m "fix: remediate security finding"
git push
```

अब same PR update होगा।

Flow:

```text
Existing PR
     ↓
New Commit
     ↓
CI Re-run
     ↓
AI Re-review*
     ↓
Human Review
```

AI automatic re-review configured होने पर new pushes को भी review किया जा सकता है।

---

# 🔹 34. PowerShell Automation कहाँ Use करें?

अब तुम्हारे सवाल का important हिस्सा।

PowerShell को हम developer-side helper automation के लिए use कर सकते हैं।

Example:

```text
Developer
   ↓
PowerShell Script
   ├── Git Status
   ├── Terraform fmt
   ├── Terraform validate
   ├── Terraform plan
   └── Trivy
   ↓
If PASS
   ↓
Git Commit
   ↓
Git Push
```

---

# 🔹 35. Example PowerShell Pre-PR Script

File:

```text
scripts/pre-pr-check.ps1
```

Example:

```powershell
Write-Host "====================================="
Write-Host " Terraform Pre-PR Validation"
Write-Host "====================================="

Write-Host "`n[1] Git Status"
git status

Write-Host "`n[2] Terraform Format"
terraform fmt -check -recursive

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform format failed"
    exit 1
}

Write-Host "`n[3] Terraform Validate"
terraform validate

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform validation failed"
    exit 1
}

Write-Host "`n[4] Terraform Plan"
terraform plan -input=false

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform plan failed"
    exit 1
}

Write-Host "`n[5] Trivy"
trivy config . --severity HIGH,CRITICAL

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Trivy security scan failed"
    exit 1
}

Write-Host "`n====================================="
Write-Host "✅ PRE-PR VALIDATION PASSED"
Write-Host "====================================="
```

इसका purpose:

```text
Developer
   ↓
.\scripts\pre-pr-check.ps1
   ↓
All validation
   ↓
PR Creation
```

---

# 🔹 36. Bash Version

Linux/macOS developers के लिए:

```bash
#!/bin/bash

set -e

echo "====================================="
echo " Terraform Pre-PR Validation"
echo "====================================="

echo "[1] Terraform Format"
terraform fmt -check -recursive

echo "[2] Terraform Validate"
terraform validate

echo "[3] Terraform Plan"
terraform plan -input=false

echo "[4] Trivy Security Scan"
trivy config . --severity HIGH,CRITICAL

echo "====================================="
echo "✅ PRE-PR VALIDATION PASSED"
echo "====================================="
```

---

# 🔹 37. लेकिन Important — Script और CI में Difference

यह समझना बहुत जरूरी है:

```text
PowerShell/Bash
      ↓
Developer Machine
```

जबकि:

```text
GitHub Actions
      ↓
Centralized CI
```

इसलिए सिर्फ local script पर भरोसा नहीं करना चाहिए।

Best architecture:

```text
Local Script
      ↓
Fast Feedback
      ↓
Git Push
      ↓
GitHub Actions
      ↓
Authoritative CI
```

---

# 🔹 38. Recommended Industrial Architecture

हमारे project के लिए:

```text
Developer Laptop
       │
       ▼
pre-pr-check.ps1
       │
       ├── fmt
       ├── validate
       ├── plan
       └── Trivy
       │
       ▼
Git Push
       │
       ▼
Pull Request
       │
       ├── GitHub Actions
       ├── Trivy
       ├── Terraform Plan
       └── AI Review
       │
       ▼
Human Approval
       │
       ▼
main
       │
       ▼
CD Pipeline
```

यह ज्यादा mature setup है।

---

# 🔹 39. AI Tool Selection — हमारे Project के लिए

### Option 1 — GitHub Copilot Code Review ⭐ Recommended

अगर organization के पास GitHub Copilot availability है तो यह सबसे natural option है क्योंकि हमारा source code already GitHub पर है।

Architecture:

```text
GitHub PR
    ↓
Copilot Code Review
    ↓
Comments
    ↓
Developer Fix
    ↓
Human Approval
```

Copilot को PR से directly reviewer के रूप में request किया जा सकता है और automatic review भी configure किया जा सकता है।

---

### Option 2 — Custom AI Review

अगर future में हमें organization-specific AI review चाहिए:

```text
GitHub PR
    ↓
GitHub Actions
    ↓
Terraform Diff
    ↓
AI API
    ↓
Security/Architecture Analysis
    ↓
PR Comment
```

इसमें custom rules बनाए जा सकते हैं।

लेकिन:

```text
AI API key
```

को repository code में hard-code नहीं करना चाहिए।

GitHub Secrets/organization-level secret management use करना चाहिए।

---

# 🔹 40. AI Review का Recommended Role

AI को यह काम दें:

```text
✅ Detect potential issues
✅ Explain Terraform changes
✅ Review security
✅ Review naming
✅ Review architecture
✅ Review Terraform best practices
✅ Identify risky changes
✅ Suggest fixes
```

AI को यह authority **नहीं** देनी चाहिए:

```text
❌ Direct production deployment
❌ Automatic Terraform Apply
❌ Final security acceptance
❌ Final production approval
```

Final control:

```text
Human Approval
```

रहेगा।

---

# 🔹 41. हमारे Project के लिए Final PR Architecture

```text
                     GitHub
                       │
                Pull Request
                       │
          ┌────────────┼────────────┐
          │            │            │
          ▼            ▼            ▼
       GitHub CI     Trivy       AI Review
          │            │            │
          └────────────┼────────────┘
                       │
                       ▼
                 Human Review
                       │
                       ▼
                    Approval
                       │
                       ▼
                  Merge → main
                       │
                       ▼
              Terraform CD
                       │
                       ▼
                 Deployment
```

---

# 🔹 42. Complete Practical Command Flow

Developer machine:

```powershell
git checkout -b feature/add-app-subnet
```

Change Terraform.

Then:

```powershell
cd terraform
```

Run:

```powershell
terraform fmt -check -recursive
terraform validate
terraform plan
trivy config . --severity HIGH,CRITICAL
```

Then:

```powershell
cd ..
git status
git diff
git add .
git commit -m "feat: add application subnet"
git push origin feature/add-app-subnet
```

Then GitHub:

```text
Compare & pull request
        ↓
Create Pull Request
```

Then:

```text
CI
 ↓
Trivy
 ↓
Terraform Plan
 ↓
AI Review
 ↓
Human Review
 ↓
Approval
```

Then:

```text
Merge → main
```

---

# 🔹 43. PR Success Criteria

PR को merge करने से पहले:

```text
☑ Correct source branch
☑ Correct target branch
☑ Meaningful PR title
☑ Clear PR description
☑ Terraform fmt passed
☑ Terraform validate passed
☑ Terraform plan reviewed
☑ Trivy passed
☑ AI review checked
☑ Human review completed
☑ Required approval received
☑ No unresolved critical issue
```

---

# 🔹 44. 🔍 What to Validate

Pull Request creation और governance properly configured है या नहीं, यह verify करना है।

विशेष रूप से validate करें:

* Feature branch से PR create हो रही है।
* PR का target branch `main` है।
* Existing CI workflow PR पर execute हो रही है।
* Terraform validation और Trivy checks PR में दिखाई दे रहे हैं।
* Terraform plan review के लिए available है।
* AI review mechanism available/configured है।
* Human reviewer assignment possible है।
* Direct `main` merge bypass नहीं किया जा सकता।

---

# 🔹 45. ✅ Best Practice

Industrial Terraform repository में:

```text
Developer
   ↓
Feature Branch
   ↓
Local Validation
   ↓
PR
   ↓
Automated CI
   ↓
Security Scan
   ↓
AI Review
   ↓
Human Review
   ↓
Approval
   ↓
Merge
```

Follow करें।

AI को **review assistant** रखें, जबकि final production decision human-controlled रहे।

Local PowerShell/Bash scripts को **fast developer feedback** के लिए रखें और GitHub Actions को authoritative validation layer रखें।

---

# 🔹 46. 🧪 Validation Test

### Test 1 — Feature Branch

```powershell
git branch
```

Expected:

```text
* feature/...
  main
```

### Test 2 — PR

GitHub में:

```text
feature/... → main
```

PR create करें।

### Test 3 — CI

PR में verify करें:

```text
Terraform Format       ✅
Terraform Init         ✅
Terraform Validate     ✅
Trivy                  ✅
Terraform Plan         ✅
```

### Test 4 — Code Review

Verify:

```text
AI Review
Human Review
```

### Test 5 — Approval

Required reviewer से approval लें।

### Test 6 — Merge

Only after all controls pass:

```text
Merge → main
```

---

# 🔹 47. 🎯 Expected Result

Expected final state:

```text
Feature Branch
      ↓
Local Validation
      ↓
Pull Request
      ↓
GitHub Actions CI
      ↓
Terraform Validation
      ↓
Trivy Security Scan
      ↓
Terraform Plan
      ↓
AI Review
      ↓
Human Review
      ↓
Approval
      ↓
Merge → main
```

`main` branch में कोई infrastructure change बिना defined review/validation controls के merge नहीं होना चाहिए।

---

# 🔹 48. 📋 Evidence

इस phase के लिए following evidence capture करें:

* Feature branch screenshot
* Git branch output
* Git status output
* PR screenshot
* PR title and description
* Files changed screenshot
* GitHub Actions CI result
* Terraform plan result
* Trivy result
* AI review comments
* Human review comments
* Approval evidence
* Successful merge to `main`
* Git commit ID
* PR number

---

# 🏁 Phase 25.02 Outcome

इस phase के बाद हमें यह complete flow clear होना चाहिए:

```text
Developer
    ↓
Feature Branch
    ↓
Terraform Change
    ↓
Local Validation
    ↓
Git Commit
    ↓
Git Push
    ↓
Pull Request
    ↓
CI
    ↓
Security Scan
    ↓
Terraform Plan
    ↓
AI Review
    ↓
Human Review
    ↓
Approval
    ↓
Merge → main
```

और उसके बाद:

```text
main
 ↓
Phase 25.03
 ↓
PR Approval
 ↓
Phase 25.04
 ↓
Feature → Main Merge
 ↓
Phase 25.05
 ↓
CD Pipeline Architecture
```

---

# 🚀 Final Industrial Model

हमारे **Cyberex Azure Landing Zone** project के लिए recommended release governance:

```text
┌───────────────────────────────┐
│        Developer              │
└───────────────┬───────────────┘
                │
                ▼
       Feature Branch
                │
                ▼
       Local Pre-PR Script
       ├── fmt
       ├── validate
       ├── plan
       └── Trivy
                │
                ▼
          Pull Request
                │
       ┌────────┼────────┐
       ▼        ▼        ▼
      CI      Trivy      AI
       │        │        │
       └────────┼────────┘
                ▼
         Human Review
                │
                ▼
            Approval
                │
                ▼
          Merge → main
                │
                ▼
          CD Pipeline
                │
                ▼
       Deployment Approval
                │
                ▼
        Terraform Apply
                │
                ▼
        Azure Resources
```

**यही हमारा actual industrial Infrastructure-as-Code release lifecycle बनेगा।**

---

# 🔐 15. GitHub Feature Branch OIDC Authentication — Flexible FIC Implementation

इस section में हमारे current GitHub Actions + Azure OIDC setup में आने वाली **Feature Branch Authentication Problem** को permanently scalable तरीके से resolve किया जाएगा।

---

# 🔴 15.1 Current Issue

हमारे Terraform CI workflow में Feature Branches के लिए:

```yaml
on:

  push:
    branches:
      - "feature/**"

  pull_request:
    branches:
      - main
```

configured है।

इसका मतलब:

```text
feature/nic
feature/vnet
feature/subnet
feature/test
feature/anything
        │
        ▼
Terraform CI
```

और CI में:

```text
Terraform
   ├── fmt
   ├── init
   ├── validate
   ├── Trivy
   └── plan
```

चलना जरूरी है।

विशेष रूप से:

> **Terraform Plan Feature Branch पर ही चलेगा।**

इसलिए Feature Branch CI से Azure authentication हटाना हमारा solution नहीं है।

---

# 🔴 15.2 Existing FIC Problem

Current Azure setup में Feature Branch के लिए exact branch-based FIC configured है।

Example:

```text
feature/nic
```

इसलिए:

```text
feature/nic
     ↓
Azure OIDC
     ↓
FIC = feature/nic
     ↓
✅ Match
```

लेकिन:

```text
feature/vnet
     ↓
Azure OIDC
     ↓
FIC = feature/nic
     ↓
❌ No Match
```

इसी कारण नई Feature Branch पर:

```text
Azure Login
     ↓
Authentication Failed
```

होता है।

---

# ❌ 15.3 Traditional FIC में `feature/**` क्यों नहीं?

GitHub Actions में:

```yaml
branches:
  - "feature/**"
```

valid है।

लेकिन traditional Azure Branch FIC में:

```text
feature/**
```

को wildcard Branch trust की तरह use नहीं किया जा सकता।

Traditional Branch FIC exact subject matching करता है।

इसलिए:

```text
feature/nic
feature/vnet
feature/subnet
```

के लिए अलग-अलग traditional credentials बनाने पड़ सकते हैं।

Microsoft documentation traditional branch/tag trust में pattern matching limitation को document करती है।

---

# 🟢 15.4 Final Solution — Flexible FIC

हम अब एक **Flexible Federated Identity Credential** बनाएँगे।

Architecture:

```text
                    GitHub
                       │
                       ▼
                Feature Branch
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   feature/nic    feature/vnet   feature/subnet
        │              │              │
        └──────────────┼──────────────┘
                       │
                       ▼
                GitHub OIDC Token
                       │
                       ▼
              Flexible FIC
                       │
             ┌─────────┴─────────┐
             │                   │
        Branch Pattern       Repository ID
             │                   │
             └─────────┬─────────┘
                       │
                       ▼
                 Azure Login
                       │
                       ▼
               Terraform Plan
```

अब:

```text
1 FIC
  ↓
feature/nic
feature/vnet
feature/subnet
feature/test
feature/anything
```

सभी matching branches को handle कर सकता है।

Microsoft की current Flexible FIC documentation specifically GitHub के multiple branches/workflows वाले scenario को single flexible credential से handle करने का use case बताती है।

---

# 🧠 15.5 हमारे Repository के लिए Exact Matching Logic

हमारे repository की values:

```text
Organization:
ComSolve-Cloud-Lab

Organization ID:
322537409

Repository:
comsolve-cyberex-azure-landing-zone

Repository ID:
1338145312
```

Current immutable GitHub subject structure:

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/BRANCH
```

इसलिए:

### `feature/nic`

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/nic
```

### `feature/vnet`

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/vnet
```

### `feature/subnet`

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/subnet
```

इन तीनों को एक pattern से match करने के लिए:

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/*
```

use करेंगे।

---

# 🔐 15.6 Final Flexible FIC Expression

हमारा exact expression:

```text
claims['sub'] matches 'repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/*' and claims['repository_id'] eq '1338145312' and claims['repository_owner_id'] eq '322537409'
```

### इसे समझो:

```text
claims['sub']
        │
        ▼
Repository + Feature Branch
        │
        ▼
matches
        │
        ▼
feature/*
```

और साथ में:

```text
repository_id
      =
1338145312
```

और:

```text
repository_owner_id
      =
322537409
```

इससे trust सिर्फ हमारे intended repository और owner से bind रहेगा।

Microsoft के current Flexible FIC rules में GitHub के लिए `sub` match करना और `repository_id` तथा/or `repository_owner_id` में से कम-से-कम एक immutable claim match करना required है। यहाँ security को और मजबूत करने के लिए दोनों match किए जा रहे हैं।

---

# 🏗️ 15.7 Azure Portal — Step-by-Step Implementation

## Step 1 — Azure Portal Open करें

Azure Portal खोलें।

फिर:

```text
Microsoft Entra ID
        ↓
App registrations
        ↓
Your GitHub Actions App Registration
```

---

# Step 2 — App Registration Open करें

अपना वही App Registration खोलें जिसे:

```text
GitHub Actions
      ↓
Azure Login
```

के लिए अभी use कर रहे हैं।

---

# Step 3 — Certificates & Secrets

Left side:

```text
Certificates & secrets
```

पर click करें।

फिर:

```text
Federated credentials
```

tab खोलें।

---

# Step 4 — Existing FIC को अभी Touch मत करना

यह बहुत important है।

अगर existing FIC दिख रहे हैं:

```text
GitHub-feature-nic
GitHub-PullRequest
```

तो:

```text
❌ Delete मत करो
❌ Modify मत करो
```

पहले नया Flexible FIC add करेंगे।

---

# Step 5 — Add Federated Credential

Click:

```text
+ Add credential
```

अब नया page/dialog खुलेगा।

---

# Step 6 — Federated Credential Scenario

यहाँ ध्यान देना है।

Traditional GitHub option select नहीं करना है।

Select:

```text
Other issuer
```

Microsoft की current Flexible FIC portal procedure में GitHub के लिए **Other issuer** select करने को कहा गया है।

---

# Step 7 — Issuer URL

Issuer field में exactly:

```text
https://token.actions.githubusercontent.com
```

डालना है।

यह GitHub Actions का OIDC issuer है।

**Type: Claims matching expression (Preview)**

इसका use इसलिए करना है क्योंकि हमें एक ही Flexible Federated Credential से `feature/*` की सभी branches को allow करना है। Traditional **Explicit subject identifier** में हर branch (`feature/nic`, `feature/vnet`, `feature/subnet`) के लिए अलग FIC चाहिए। **Claims matching expression** में `*` wildcard के through सभी `feature/*` branches एक ही FIC से match हो जाती हैं।

---

# Step 8 — Value Field

अब सबसे important field:

```text
Value
```

यहाँ पूरा expression paste करो:

```text
claims['sub'] matches 'repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/*' and claims['repository_id'] eq '1338145312' and claims['repository_owner_id'] eq '322537409'
```

### ध्यान:

पूरी line एक ही expression है।

```text
claims['sub']
        ↓
matches
        ↓
feature/*
```

और:

```text
repository_id
        ↓
1338145312
```

और:

```text
repository_owner_id
        ↓
322537409
```

Microsoft के documented GitHub Flexible FIC examples इसी `claims['sub'] matches ...` + immutable repository claim model का उपयोग करते हैं।

---

# Step 9 — Credential Name

**Name में:**


`GitHub-Feature-Branches-Flexible`


रख सकते हैं।

Final configuration:


**Name:**

`GitHub-Feature-Branches-Flexible`

**Description:** This Flexible Federated Credential allows GitHub Actions workflows from all feature branches of the ComSolve-Cloud-Lab/comsolve-cyberex-azure-landing-zone repository to authenticate to Microsoft Entra ID using GitHub OIDC. The trust is restricted using immutable repository and repository-owner identifiers for secure branch-level authentication.


**Issuer:**

`https://token.actions.githubusercontent.com`

```text
Value:

claims['sub'] matches 'repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/*' and claims['repository_id'] eq '1338145312' and claims['repository_owner_id'] eq '322537409'
```

---

**`claims['sub']` क्या है?**  
`sub` यानी **Subject (identity)** — यह बताता है कि GitHub से आने वाला OIDC token किस exact repository और branch से आया है।

इस case में:

`repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/*`

इसका मतलब है:

- `ComSolve-Cloud-Lab` → GitHub Organization
- `322537409` → **Repository Owner ID / Organization ID**
- `comsolve-cyberex-azure-landing-zone` → GitHub Repository
- `1338145312` → **Repository ID**
- `ref:refs/heads/feature/*` → सभी `feature/*` branches

इसलिए `sub` का main काम है **यह verify करना कि OIDC token हमारे allowed repository की `feature/*` branch से ही आया है।**


**`claims['repository_id']` क्या है?**  
यह GitHub repository का **immutable numeric ID** है।

`claims['repository_id'] eq '1338145312'`

इसका मतलब है कि केवल इसी exact repository:

`comsolve-cyberex-azure-landing-zone`

से आने वाले token को allow किया जाएगा।

Repository का नाम बदलने या repository transfer होने जैसी स्थिति में भी numeric Repository ID स्थिर रहता है, इसलिए यह security के लिए ज्यादा reliable है।


**`claims['repository_owner_id']` क्या है?**  
यह GitHub Organization/Owner का **immutable numeric ID** है।

`claims['repository_owner_id'] eq '322537409'`

इसका मतलब है कि repository केवल हमारे allowed GitHub Organization/Owner:

`ComSolve-Cloud-Lab`

के under होनी चाहिए।

यह organization/owner की identity को securely verify करता है।


**तीनों को साथ में क्यों use किया गया है?**

```text
GitHub OIDC Token
       │
       ▼
┌─────────────────────────────┐
│ claims['sub']               │
│ Repository + feature/*      │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ repository_id               │
│ 1338145312                  │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ repository_owner_id         │
│ 322537409                   │
└──────────────┬──────────────┘
               │
               ▼
        All conditions match
               │
               ▼
       Azure OIDC Authentication
               │
               ▼
          Terraform Plan
```
---

### 🔐 GitHub OIDC Claims — `sub`, `repository_id` & `repository_owner_id`

Flexible Federated Credential में GitHub OIDC token के अंदर आने वाले कुछ claims को Azure Microsoft Entra ID trust validation के लिए use किया जाता है।

**1. `claims['sub']` — Subject Identifier**

`sub` यानी **Subject** बताता है कि GitHub से आने वाला OIDC token किस specific workload/context से संबंधित है।

हमारे repository के लिए immutable `sub` format इस प्रकार है:

```text
repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/*
```

यहाँ `feature/*` का मतलब है कि `feature/nic`, `feature/vnet`, `feature/subnet`, `feature/test` जैसी सभी feature branches एक ही Flexible FIC से match हो सकती हैं।

---

**2. `claims['repository_id']` — Repository की Unique ID**

`repository_id` GitHub repository की **immutable numeric ID** है।

हमारे repository की ID:

```text
1338145312
```

इसका काम Azure को यह सुनिश्चित करना है कि OIDC token **इसी exact GitHub repository** से आया है।

इसलिए:

```text
claims['repository_id'] eq '1338145312'
```

का मतलब है:

> केवल repository ID `1338145312` वाले repository का token इस Flexible FIC से authenticate हो सकता है।

यह repository name से ज्यादा reliable binding है क्योंकि repository का name बदल सकता है, लेकिन repository ID stable रहती है।

---

**3. `claims['repository_owner_id']` — GitHub Organization की Unique ID**

`repository_owner_id` उस GitHub organization/owner की **immutable numeric ID** है जिसके अंदर repository मौजूद है।

हमारी GitHub Organization:

```text
ComSolve-Cloud-Lab
```

की owner ID:

```text
322537409
```

इसलिए:

```text
claims['repository_owner_id'] eq '322537409'
```

का मतलब है:

> केवल `ComSolve-Cloud-Lab` organization से संबंधित repository token इस trust relationship में allowed होगा।

यह additional security boundary है।

---

### 🧩 पूरा Expression कैसे काम करता है

हमारा Flexible FIC expression:

```text
claims['sub'] matches 'repo:ComSolve-Cloud-Lab@322537409/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/*' and claims['repository_id'] eq '1338145312' and claims['repository_owner_id'] eq '322537409'
```

इसे तीन security checks की तरह समझें:

```text
GitHub OIDC Token
       │
       ├── sub
       │     └── क्या यह feature/* branch है?
       │
       ├── repository_id
       │     └── क्या यह हमारा exact repository है?
       │
       └── repository_owner_id
             └── क्या यह हमारी exact GitHub Organization है?
       │
       ▼
    All conditions match
       │
       ▼
 Azure OIDC Authentication
       │
       ▼
 Terraform CI → Plan
```

इसका फायदा यह है कि हमें प्रत्येक feature branch के लिए अलग-अलग traditional FIC बनाने की जरूरत नहीं पड़ती।

> **Important:** `repository_id` और `repository_owner_id` GitHub repository के OIDC token से आने वाले immutable claims हैं। इन्हें manually बनाया या बदला नहीं जाता; इनके actual numeric values GitHub OIDC identity से आती हैं।


---

# Step 10 — Add

अब:

```text
Add
```

पर click करें।

अगर credential successfully create हो जाता है:

```text
GitHub-Feature-Branches-Flexible
```

Federated credentials list में दिखाई देगा।

---

# 🟢 15.8 अभी Existing FIC Delete क्यों नहीं करना?

Current setup:

```text
Existing FIC
     +
New Flexible FIC
```

दोनों temporarily रहेंगे।

यह हमारा **safe migration approach** है।

Flow:

```text
Existing FIC
     │
     ├── feature/nic
     │
     ▼
Still working

New Flexible FIC
     │
     ├── feature/nic
     ├── feature/vnet
     ├── feature/subnet
     └── future feature/*
```

पहले नया FIC test होगा।

फिर old branch-specific FIC cleanup करेंगे।

---

# 🧪 15.9 Feature Branch Test — `feature/nic`

पहले existing branch test करें:

```powershell
git checkout feature/nic
```

फिर:

```powershell
git push origin feature/nic
```

GitHub में:

```text
Actions
   ↓
Terraform CI
```

open करें।

Check:

```text
Azure Login
```

Expected:

```text
✅ Azure Login successful
```

फिर:

```text
Terraform Init
      ↓
Terraform Validate
      ↓
Trivy
      ↓
Terraform Plan
```

Expected:

```text
✅ Terraform Plan successful
```

---

# 🧪 15.10 New Branch Test — `feature/vnet`

अब actual problem test करेंगे:

```powershell
git checkout -b feature/vnet
```

फिर कोई छोटा valid change करें और:

```powershell
git add .
git commit -m "test: validate flexible oidc authentication"
```

फिर:

```powershell
git push -u origin feature/vnet
```

GitHub Actions:

```text
feature/vnet
      ↓
Terraform CI
      ↓
Azure Login
      ↓
Flexible FIC
      ↓
Match
      ↓
✅ Success
```

और:

```text
Terraform Plan
      ↓
✅ Success
```

---

# 🧪 15.11 Third Test — `feature/subnet`

अब:

```powershell
git checkout -b feature/subnet
```

फिर:

```powershell
git push -u origin feature/subnet
```

Expected:

```text
feature/subnet
      ↓
Flexible FIC
      ↓
repository_id = 1338145312
      ↓
repository_owner_id = 322537409
      ↓
feature/*
      ↓
Match
      ↓
✅ Azure Login
      ↓
✅ Terraform Plan
```

---

# 🧪 15.12 Future Branch Test

अब theoretically:

```text
feature/storage
feature/keyvault
feature/bastion
feature/appgateway
feature/security
feature/testing
feature/anything
```

सभी:

```text
feature/*
```

pattern के अंदर आएँगे।

इसलिए:

```text
1 Flexible FIC
       ↓
Unlimited Git Branches
```

GitHub branch count की कोई FIC-per-branch dependency नहीं रहेगी।

---

# 🔵 15.13 Pull Request FIC को क्या करना है?

तेरे पास already:

```text
Pull Request FIC
```

configured है।

इसे **अभी delete नहीं करना है।**

क्यों?

क्योंकि:

```text
Feature Push
     ↓
Flexible Feature FIC
```

जबकि:

```text
Pull Request
     ↓
Pull Request FIC
```

दो अलग OIDC contexts हैं।

Architecture:

```text
feature/vnet PUSH
       │
       ▼
Feature Flexible FIC
       │
       ▼
Terraform CI
```

लेकिन:

```text
feature/vnet
       │
       ▼
Pull Request → main
       │
       ▼
Pull Request FIC
       │
       ▼
Terraform CI
```

इसलिए दोनों FIC रखना सही है।

---

# 🔥 15.14 Final Authentication Architecture

अब हमारा पूरा setup:

```text
                         GitHub
                           │
             ┌─────────────┴─────────────┐
             │                           │
       Feature Push                  Pull Request
             │                           │
             ▼                           ▼
     Feature Flexible FIC           PR FIC
             │                           │
             └─────────────┬─────────────┘
                           │
                           ▼
                      Azure Login
                           │
                           ▼
                    Terraform CI
                           │
             ┌─────────────┼─────────────┐
             │             │             │
            fmt          validate       Trivy
             │             │             │
             └─────────────┼─────────────┘
                           │
                           ▼
                    Terraform Plan
                           │
                           ▼
                       PR Review
                           │
                           ▼
                      PR Approval
                           │
                           ▼
                      Merge → main
                           │
                           ▼
                       Terraform CD
                           │
                           ▼
                    Production Identity
                           │
                           ▼
                    Terraform Apply
```

---

# 🛡️ 15.15 Security Boundary

Flexible FIC को broad नहीं रखना है:

### ❌ ऐसा नहीं:

```text
claims['sub'] matches '*'
```

यह बहुत broad trust होगा।

### ❌ ऐसा भी नहीं:

```text
repository_owner_id only
```

क्योंकि organization के दूसरे repositories भी trust boundary में आ सकते हैं।

### ✅ हमारा model:

```text
Repository
      +
Repository Owner
      +
Feature Branch Pattern
```

यानी:

```text
ComSolve-Cloud-Lab
       +
comsolve-cyberex-azure-landing-zone
       +
feature/*
```

यह ज्यादा controlled है।

---

# 🔐 15.16 Exact Trust Boundary

हमारा Flexible FIC केवल इस प्रकार के token को accept करने के लिए बनाया गया है:

```text
Repository:
comsolve-cyberex-azure-landing-zone

Owner:
ComSolve-Cloud-Lab

Branch:
feature/*
```

इसलिए:

```text
feature/nic       ✅
feature/vnet      ✅
feature/subnet    ✅
feature/test      ✅
feature/security  ✅
```

लेकिन:

```text
main              ❌
random-repo       ❌
other-org         ❌
```

यह Flexible FIC feature-branch CI के लिए है।

---

# ⚠️ 15.17 Main Branch के लिए यही FIC Use नहीं करना

हम feature FIC में:

```text
feature/*
```

रख रहे हैं।

इसका मतलब:

```text
main
```

इस credential का intended match नहीं है।

Main deployment के लिए अलग:

```text
CD Identity
     +
Main/Environment FIC
```

रहेगा।

यह हमारी CI/CD security boundary है।

---

# 🧹 15.18 Testing Successful होने के बाद Cleanup

जब ये तीनों tests successful हो जाएँ:

```text
feature/nic       ✅
feature/vnet      ✅
feature/subnet    ✅
```

तब existing branch-specific FIC:

```text
GitHub-feature-nic
```

को remove करने पर विचार कर सकते हैं।

लेकिन:

```text
Pull Request FIC
```

को नहीं हटाना है।

Final:

```text
Federated Credentials
│
├── GitHub-Feature-Branches-Flexible
│
└── GitHub-PullRequest
```

और future में:

```text
feature/nic
feature/vnet
feature/subnet
feature/storage
feature/keyvault
feature/test
...
```

के लिए अलग FIC बनाने की आवश्यकता नहीं होगी।

---

# 🧪 15.19 Final Test Matrix

| Test                          | Expected                |
| ----------------------------- | ----------------------- |
| `feature/nic` push            | ✅ Azure Login           |
| `feature/vnet` push           | ✅ Azure Login           |
| `feature/subnet` push         | ✅ Azure Login           |
| `feature/test` push           | ✅ Azure Login           |
| Feature branch Terraform Plan | ✅ Success               |
| PR → main                     | ✅ Existing PR FIC       |
| Merge → main                  | ✅ CD                    |
| Feature → Terraform Apply     | ❌ Not permitted         |
| main → Terraform Apply        | ✅ Controlled deployment |

---

# 🚨 15.20 अगर Flexible FIC Add करते समय Error आए

Flexible FIC अभी **Preview** capability है। Microsoft के current documentation के अनुसार इसे Azure Portal या Microsoft Graph से manage किया जा सकता है। Azure CLI/Azure PowerShell/Terraform में direct explicit Flexible FIC support अभी available नहीं है; जरूरत पड़ने पर `az rest` के जरिए Microsoft Graph API इस्तेमाल किया जा सकता है।

इसलिए:

```text
Azure Portal
     ↓
Other issuer
     ↓
Expression
```

पहला और easiest तरीका है।

अगर Portal validation error देता है:

```text
❌ Do not modify existing FIC
❌ Do not delete existing FIC
```

पहले error capture करें और उसी error के आधार पर Graph/`az rest` route use करेंगे।

---

# 🧠 15.21 इस Fix से Actual Problem कैसे Solve होगी?

### पहले:

```text
feature/nic
     ↓
FIC = feature/nic
     ↓
✅

feature/vnet
     ↓
FIC = feature/nic
     ↓
❌

feature/subnet
     ↓
FIC = feature/nic
     ↓
❌
```

### Fix के बाद:

```text
feature/nic
     │
     ├──────────────┐
feature/vnet       │
     │             │
feature/subnet     │
     │             │
feature/test       │
     │             │
     └──────┬──────┘
            ▼
       Flexible FIC
            │
       feature/*
            │
            ▼
      Azure OIDC Login
            │
            ▼
      Terraform Plan
            │
            ▼
          SUCCESS
```

---

# 🏆 15.22 Final Result

हमारा desired result:

```text
                    FEATURE BRANCHES
                           │
          ┌────────────────┼────────────────┐
          │                │                │
     feature/nic      feature/vnet     feature/subnet
          │                │                │
          └────────────────┼────────────────┘
                           │
                           ▼
                    GitHub OIDC
                           │
                           ▼
                Flexible Federated FIC
                           │
                 ┌─────────┴─────────┐
                 │                   │
             feature/*          Repository ID
                 │                   │
                 └─────────┬─────────┘
                           │
                           ▼
                     Azure Login
                           │
                           ▼
                  Terraform CI / PLAN
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
                       main
                           │
                           ▼
                    Terraform CD
                           │
                           ▼
                       APPLY
```

---

# 🔍 What to Validate

* Existing Feature Branch FIC और Pull Request FIC को preserve करना।
* Flexible FIC successfully create हुआ है या नहीं।
* Issuer exactly `https://token.actions.githubusercontent.com` है या नहीं।
* Flexible FIC में exact repository ID `1338145312` configured है या नहीं।
* Repository owner ID `322537409` configured है या नहीं।
* Feature branch pattern `feature/*` correctly configured है या नहीं।
* `feature/nic` से Azure Login successful है या नहीं।
* `feature/vnet` से Azure Login successful है या नहीं।
* `feature/subnet` से Azure Login successful है या नहीं।
* Feature branches पर Terraform `plan` successfully execute हो रहा है या नहीं।
* Pull Request authentication existing PR FIC से successful है या नहीं।

---

# ✅ Best Practice

* Feature branches के लिए scalable Flexible FIC use करें।
* Repository और owner को immutable IDs से bind करें।
* Existing working FIC को test से पहले delete न करें।
* Feature CI identity को production deployment permissions न दें।
* Pull Request FIC को Feature Branch FIC से अलग रखें।
* Main branch deployment के लिए controlled CD identity रखें।
* `feature/*` trust को production `main` trust के साथ combine न करें।
* Flexible FIC Preview होने के कारण production adoption से पहले organizational approval/security review करें।

---

# 🧪 Validation Test

### Test 1

```powershell
git checkout feature/nic
git push origin feature/nic
```

Expected:

```text
Azure Login       → ✅
Terraform Init    → ✅
Terraform Validate → ✅
Trivy             → ✅
Terraform Plan    → ✅
```

### Test 2

```powershell
git checkout -b feature/vnet
git push -u origin feature/vnet
```

Expected:

```text
Azure Login       → ✅
Terraform Plan    → ✅
```

### Test 3

```powershell
git checkout -b feature/subnet
git push -u origin feature/subnet
```

Expected:

```text
Azure Login       → ✅
Terraform Plan    → ✅
```

### Test 4

```text
feature/vnet
      ↓
Pull Request
      ↓
main
```

Expected:

```text
Pull Request FIC
      ↓
Azure Login
      ↓
✅ Success
```

---

# 🎯 Expected Result

एक successful Flexible FIC implementation के बाद:

```text
feature/nic
feature/vnet
feature/subnet
feature/test
feature/anything
        │
        ▼
  ONE Flexible FIC
        │
        ▼
   Azure OIDC Login
        │
        ▼
 Terraform Plan
        │
        ▼
      SUCCESS
```

अब:

```text
1 Branch = 1 FIC
```

वाला model खत्म हो जाएगा।

हमारा model होगा:

```text
1 Flexible FIC
      ↓
feature/*
```

---

# 📋 Evidence

Implementation के बाद capture करें:

* Azure Flexible FIC screenshot.
* FIC Name.
* Issuer URL.
* Claims Matching Expression.
* Repository ID.
* Repository Owner ID.
* `feature/nic` successful CI run.
* `feature/vnet` successful CI run.
* `feature/subnet` successful CI run.
* Azure Login successful log.
* Terraform Plan successful log.
* Pull Request CI successful run.
* Existing PR FIC validation.
* Final FIC inventory after cleanup.

---

# 🏁 Final Decision

इस project के लिए final decision:

```text
❌ हर feature branch के लिए अलग FIC नहीं

❌ feature/** को traditional Branch FIC में नहीं डालना

❌ Feature CI से Terraform Plan हटाना नहीं

❌ Existing PR FIC delete नहीं करना

                    ↓

✅ Flexible FIC create करना

                    ↓

✅ feature/* branches trust करना

                    ↓

✅ repository_id = 1338145312

                    ↓

✅ repository_owner_id = 322537409

                    ↓

✅ Terraform Plan Feature Branch पर continue रखना

                    ↓

✅ PR FIC अलग रखना

                    ↓

✅ Main/CD identity अलग रखना
```

## 🎯 Final Target

```text
Developer
   │
   ▼
feature/*
   │
   ▼
GitHub Actions
   │
   ▼
Flexible FIC
   │
   ▼
Azure OIDC
   │
   ▼
Terraform Plan
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
main
   │
   ▼
CD
   │
   ▼
Terraform Apply
```

यही हमारा **final scalable + secure + industrial CI/CD OIDC architecture** रहेगा।


---

