# 🔐 Phase 16 — Security Gate & Pull Request Security

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Pull%20Request-2088FF?style=for-the-badge&logo=github&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Checkov](https://img.shields.io/badge/Checkov-Security%20Gate-success?style=for-the-badge)
![Trivy](https://img.shields.io/badge/Trivy-Security%20Gate-1904DA?style=for-the-badge&logo=trivy&logoColor=white)
![DevSecOps](https://img.shields.io/badge/DevSecOps-PR%20Security-orange?style=for-the-badge)

</p>

---

# 🎯 Phase Objective

इस Phase का मुख्य उद्देश्य Terraform Infrastructure में **Pull Request आधारित Security Validation** implement करना है।

अब तक हमने:

```text
Terraform
   ↓
GitHub Actions
   ↓
Azure OIDC
   ↓
Terraform Plan
   ↓
Checkov
   ↓
Trivy
```
सीखा है।

अब हम इसे एक proper Security Gate में बदलेंगे।

Final objective:

```text
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
Checkov
    ↓
Trivy
    ↓
Security Gate
    ↓
Terraform Plan
    ↓
Review
    ↓
Merge to main
```

⚠️ इस Phase में अभी terraform apply नहीं किया जाएगा।

Actual Azure deployment को बाद के Deployment Phase में रखा जाएगा।

🧠 Step 01 — Security Gate क्या है?

Security Gate एक ऐसा automated checkpoint है जो यह decide करता है कि code आगे जा सकता है या नहीं।

Example:

Terraform Code
      ↓
Security Scan
      ↓
       ┌───────────────┐
       │ Security Gate │
       └───────────────┘
          ↓         ↓
       PASS        FAIL
          ↓         ↓
       Continue    STOP

अगर defined security requirement fail होती है:

❌ Pull Request Check Failed

तो code को आगे merge करने से पहले issue resolve करना होगा।

🔀 Step 02 — Feature Branch से Pull Request तक Flow

हमारा development flow:

feature/nic-infrastructure
            │
            │ git push
            ▼
      GitHub Repository
            │
            ▼
      Pull Request → main
            │
            ▼
      GitHub Actions

Feature branch पर development होगा।

main branch को controlled branch रखा जाएगा।

⚙️ Step 03 — Pull Request Trigger

GitHub Actions workflow में PR trigger होना चाहिए।

Example:

on:

  push:
    branches:
      - "feature/**"

  pull_request:
    branches:
      - main

इसका मतलब:

Feature Branch Push
feature/**
     ↓
GitHub Actions
Pull Request to Main
Pull Request
     ↓
main
     ↓
GitHub Actions

इससे Pull Request के दौरान security checks automatically run होंगे।

🔍 Step 04 — Security Checks का Order

Pipeline में security checks को Terraform validation के बाद रखना useful है।

Recommended flow:

Checkout
   ↓
Azure OIDC Login
   ↓
Terraform Setup
   ↓
Terraform Format
   ↓
Terraform Init
   ↓
Terraform Validate
   ↓
Checkov
   ↓
Trivy
   ↓
Terraform Plan

Security checks का purpose:

Terraform Validate
        ↓
Configuration valid?

फिर:

Checkov
        ↓
Security policies satisfied?

फिर:

Trivy
        ↓
Known IaC misconfigurations detected?

और अंत में:

Terraform Plan
        ↓
What will Terraform change?
🛡️ Step 05 — Checkov को Security Gate बनाना

Checkov को केवल report generator की तरह use करने के बजाय pipeline gate बनाया जा सकता है।

Example:

- name: Checkov Security Scan
  run: checkov -d terraform

अगर Checkov configured checks के अनुसार failure देता है, तो GitHub Actions step fail हो सकता है।

Flow:

Checkov
   ↓
Finding
   ↓
Non-zero exit code
   ↓
GitHub Actions
   ↓
❌ Step Failed
🐳 Step 06 — Trivy को Security Gate में Add करना

Trivy Terraform configuration scan कर सकता है।

Example:

- name: Trivy IaC Security Scan
  run: trivy config terraform

Flow:

Terraform
    ↓
Trivy Config Scanner
    ↓
Misconfiguration Detection
    ↓
PASS / FAIL


5. तुम्हारे existing YAML में placement

तुम्हारे existing flow में बस यह हिस्सा add होगा:

Checkov को Security Gate बनाया
Trivy को HIGH/CRITICAL Security Gate बनाया

      # ------------------------------------------------------------------------
      # Step 09 — Checkov Security Gate
      # ------------------------------------------------------------------------

      - name: Checkov Security Scan
        uses: bridgecrewio/checkov-action@master
        with:
          directory: terraform
          framework: terraform


      # ------------------------------------------------------------------------
      # Step 10 — Trivy IaC Security Gate
      # ------------------------------------------------------------------------

      - name: Trivy IaC Security Scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: config
          scan-ref: terraform
          severity: HIGH,CRITICAL
          exit-code: 1


      # ------------------------------------------------------------------------
      # Step 11 — Terraform Plan
      # ------------------------------------------------------------------------


🚦 Step 07 — Security Gate का Practical Meaning

हमारा Security Gate केवल यह नहीं देखता:

"Pipeline चली या नहीं?"

बल्कि:

"Security requirements पूरी हुईं या नहीं?"

Example:

Checkov
   ↓
5 FAILED
   ↓
❌ Security Gate
   ↓
Pipeline STOP

और:

Checkov
   ↓
PASS
   ↓
Trivy
   ↓
PASS
   ↓
Security Gate
   ↓
✅ Continue
🔎 Step 08 — Security Finding आने पर क्या करना है?

Security finding आने पर तुरंत scanner को disable नहीं करना है।

हमारा troubleshooting process:

Security Finding
       ↓
Read Finding
       ↓
Identify Resource
       ↓
Identify File
       ↓
Identify Line
       ↓
Understand Risk
       ↓
Find Root Cause
       ↓
Fix Terraform
       ↓
Run Scanner Again
       ↓
Verify
🧠 Step 09 — Finding और Root Cause में Difference

Example:

CKV2_AZURE_31

Finding:

Ensure VNET subnet is configured
with a Network Security Group

अगर हमारे पास 5 subnets हैं:

web
application
data
management
security

तो Checkov 5 failures दिखा सकता है।

लेकिन root cause:

Common subnet module
       ↓
NSG association missing

हो सकता है।

इसलिए:

Multiple findings हमेशा multiple root causes नहीं होतीं।

❌ Step 10 — Security Failure को Ignore क्यों नहीं करना?

गलत approach:

Checkov FAIL
      ↓
Ignore
      ↓
Continue

Better approach:

Checkov FAIL
      ↓
Understand
      ↓
Risk Assessment
      ↓
Fix
      ↓
Re-scan

अगर finding intentionally accepted है, तो उसका documented reason और approval होना चाहिए।

🧪 Step 11 — Security Gate PASS होने पर

Expected flow:

Terraform Validate
       ↓
      PASS
       ↓
Checkov
       ↓
      PASS
       ↓
Trivy
       ↓
      PASS
       ↓
Terraform Plan
       ↓
      PASS

GitHub Pull Request में checks दिखाई देंगे।

Example:

✅ Terraform Validation
✅ Checkov Security Scan
✅ Trivy IaC Scan
✅ Terraform Plan
🚨 Step 12 — Security Gate FAIL होने पर

Example:

Terraform Validate
       ↓
      PASS
       ↓
Checkov
       ↓
      FAIL
       ↓
❌ GitHub Actions Failed

अब developer को:

1. Failed check खोलना
2. Logs पढ़ना
3. Finding identify करना
4. Terraform code fix करना
5. Commit करना
6. Push करना

होगा।

Push के बाद GitHub Actions फिर से run होगा।

🔄 Step 13 — Failed Pipeline को Re-run करना

अगर failure transient हो या code change की आवश्यकता न हो तो GitHub Actions में:

Actions
   ↓
Workflow Run
   ↓
Re-run jobs

के options मिल सकते हैं।

Typical options:

Re-run all jobs
Re-run failed jobs
Re-run failed jobs

अगर केवल एक job fail हुई और बाकी jobs successfully complete हुई थीं:

Re-run failed jobs

use करना efficient हो सकता है।

लेकिन:

अगर Terraform code या security configuration change किया है, तो नया commit/push करना बेहतर है, ताकि नया workflow run उस exact code state पर execute हो।

🔐 Step 14 — Pull Request Security का Benefit

अब developer directly main में code push करने के बजाय:

Feature Branch
      ↓
Pull Request
      ↓
Automated Security Checks
      ↓
Review
      ↓
Merge

follow करता है।

इसका benefit:

🔐 Security validation
👨‍💻 Code review
🔎 Automated testing
📋 Terraform plan review
🚦 Security gate
🛡️ Controlled main branch
🛡️ Step 15 — Main Branch Protection

GitHub repository में:

Settings
   ↓
Branches
   ↓
Branch protection rules

या GitHub के available Rulesets section में branch rules configure किए जा सकते हैं।

Target:

main

Recommended controls:

Require Pull Request
Require status checks
Require review
Restrict direct changes

इसका उद्देश्य:

Developer
   │
   ├── ❌ Direct main push
   │
   └── ✅ Feature Branch
            ↓
       Pull Request
            ↓
       Security Checks
            ↓
          Review
            ↓
           main
🚧 Step 16 — अभी क्या Block करना है?

इस Phase में हम blindly हर warning को block नहीं करेंगे।

Security Gate design करते समय severity समझना जरूरी है।

Example:

Critical
   ↓
Block

High
   ↓
Normally Block

Medium
   ↓
Review / Policy based

Low
   ↓
Track / Review

Actual blocking policy organization की security requirements पर depend करेगी।


### 📊 Step 17 — Security Results को समझना

Security scan में हमें मुख्य रूप से इन points पर ध्यान देना होता है:

| Item | Question | Description / Purpose |
| :--- | :--- | :--- |
| **Tool** | कौन सा scanner finding दे रहा है? | Scan perform करने वाले tool की पहचान (e.g., Checkov, Trivy) |
| **Check ID** | कौन सी policy fail हुई? | Failed security policy का unique identifier (e.g., CKV_AZURE_9) |
| **Resource** | कौन सा Azure/Terraform resource प्रभावित है? | Affected infrastructure block (e.g., `azurerm_subnet.internal`) |
| **File** | कौन सी `.tf` file में issue है? | Target configuration file का नाम |
| **Line** | कौन सी line responsible है? | Specific code line number जहाँ remediation की जरूरत है |
| **Severity** | Risk कितना है? | Risk level assessment (LOW, MEDIUM, HIGH, CRITICAL) |
| **Root Cause** | असली कारण क्या है? | Vulnerability या misconfiguration की मूल वजह |
| **Remediation** | Fix क्या होगा? | Security issue को resolve करने के लिए आवश्यक code change |
| **Verification** | Fix के बाद scan PASS हुआ? | Code change के बाद re-scan करके confirmation करना |


🧩 Step 18 — Local Security Scan vs CI Security Gate

हमारे project में दोनों का अलग purpose है।

Local
Developer
   ↓
Checkov
   ↓
Trivy
   ↓
Fix before Push

Purpose:

Developer को जल्दी feedback देना।

GitHub Actions
Pull Request
      ↓
GitHub Actions
      ↓
Checkov
      ↓
Trivy
      ↓
Security Gate

Purpose:

Repository में आने वाले code को automatically validate करना।

🏗️ Step 19 — Complete Phase 16 Architecture
                 👨‍💻 Developer
                      │
                      ▼
             🌿 Feature Branch
                      │
                  git push
                      │
                      ▼
               🐙 GitHub
                      │
                      ▼
               🔀 Pull Request
                      │
                      ▼
             ⚙️ GitHub Actions
                      │
                      ▼
              Terraform Format
                      │
                      ▼
             Terraform Validate
                      │
                      ▼
                 🔍 Checkov
                      │
                      ▼
                  🐳 Trivy
                      │
                      ▼
              🚦 Security Gate
                 │          │
              FAIL         PASS
                 │          │
                 ▼          ▼
               STOP    Terraform Plan
                            │
                            ▼
                       👨‍💻 Review
                            │
                            ▼
                       🔀 Merge
                            │
                            ▼
                          main
🚫 Step 20 — Important: Terraform Apply अभी नहीं

इस Phase में:

❌ terraform apply
❌ Production deployment
❌ Actual Azure resource creation

नहीं करेंगे।

अभी हमारा objective है:

Feature Branch
      ↓
Pull Request
      ↓
Security Validation
      ↓
Terraform Plan
      ↓
Review
      ↓
Merge

Actual deployment के लिए अलग deployment workflow बाद में बनाया जाएगा।


🎯 Phase 16 Final Outcome

Phase 16 के बाद हमारा repository केवल Terraform code repository नहीं रहेगा।

अब development model होगा:

🌿 Feature Branch
       ↓
🔀 Pull Request
       ↓
⚙️ GitHub Actions
       ↓
🔍 Terraform Validation
       ↓
🛡️ Checkov
       ↓
🐳 Trivy
       ↓
🚦 Security Gate
       ↓
📋 Terraform Plan
       ↓
👨‍💻 Review
       ↓
✅ Merge to main

इसका मतलब:

Security को infrastructure deployment के बाद check करने के बजाय development और Pull Request stage पर ही validate किया जा रहा है।

🚀 Next Phase
📊 Phase 17 — Security Findings Analysis & Remediation

अगले Phase में हम सीखेंगे:

Security Finding
      ↓
Severity
      ↓
Risk
      ↓
Root Cause
      ↓
Remediation
      ↓
Terraform Code Change
      ↓
Checkov Re-scan
      ↓
Trivy Re-scan
      ↓
Finding Resolved

अर्थात Phase 16 में हमने Security Gate बनाया और Phase 17 में हम Security findings को properly analyze और fix करेंगे।


### इसके बाद commit

```powershell
git add docs/phase-16-security-gate-pull-request-security.md
git commit -m "Add Phase 16 security gate and pull request security"
git push

एक बात ध्यान रखना: Phase 16 में अभी main पर actual deployment नहीं होगा। हम PR + security checks + plan तक ही रहेंगे; terraform apply को तुम्हारे तय किए हुए बाद वाले deployment phase तक अलग रखेंगे।