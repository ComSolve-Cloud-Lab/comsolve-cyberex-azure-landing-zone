# 🛡️ Phase 14 — Terraform Security Automation

<p align="center">

![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Checkov](https://img.shields.io/badge/Checkov-IaC%20Security-success?style=for-the-badge)
![Trivy](https://img.shields.io/badge/Trivy-Security-1904DA?style=for-the-badge)

</p>

> 🎯 **Objective:** Terraform Infrastructure को Azure पर deploy करने से पहले automated security scanning pipeline में integrate करना।

---

# 🧭 Phase 14 Overview

अब तक हमारा Terraform CI pipeline यह काम कर रहा है:

```text
🐙 GitHub
    ↓
⚙️ GitHub Actions
    ↓
📥 Checkout
    ↓
🔐 Azure OIDC Login
    ↓
🏗️ Terraform Setup
    ↓
✨ Terraform Format
    ↓
📦 Terraform Init
    ↓
✅ Terraform Validate
    ↓
📋 Terraform Plan
```
अब इसमें Security Layer add करेंगे:

🐙 GitHub
    ↓
⚙️ GitHub Actions
    ↓
📥 Checkout
    ↓
🔐 Azure OIDC Login
    ↓
🏗️ Terraform Setup
    ↓
✨ Terraform Format
    ↓
📦 Terraform Init
    ↓
✅ Terraform Validate
    ↓
🛡️ Checkov Scan
    ↓
🛡️ Trivy Scan
    ↓
📋 Terraform Plan
    ↓
☁️ Azure


🎯 Phase 14 में क्या सीखेंगे?

इस Phase में हम primarily यह सीखेंगे:

🛡️ Security tools क्या होते हैं
🔍 Terraform/IaC scanning क्या होती है
💻 Security tools local PC पर कैसे test करें
🐙 Security tools GitHub Actions में कैसे integrate करें
🔄 Local scan और CI scan में difference
🚦 Security scan को pipeline gate कैसे बनाएं
❌ Security issue मिलने पर pipeline कैसे रोकें
📋 Scan results को GitHub Actions logs में कैसे देखें

⚠️ Tools की deep security analysis Phase 15 में करेंगे।

🧠 Step 01 — Security Scanning क्यों जरूरी है?

Terraform code syntactically सही हो सकता है:

terraform validate
        ↓
       PASS

लेकिन इसका मतलब यह नहीं है कि configuration secure भी है।

Example:

Terraform Validate
        ↓
Configuration valid

लेकिन Security Scanner कह सकता है:

❌ Subnet does not have NSG
❌ Storage account is publicly accessible
❌ Encryption configuration missing
❌ Weak security configuration

इसलिए:

Terraform Validate
        =
Code technically correct

Security Scan
        =
Code security-wise acceptable

दोनों अलग चीजें हैं।

---

# 🧠— कौन से Security Tools?

इस project में शुरुआत के लिए दो tools use करेंगे:

🔍 Checkov

Checkov Infrastructure-as-Code security scanner है।

Terraform code में यह security misconfigurations और policy violations identify कर सकता है।

यह Terraform configuration को scan करके security best practices के against check करता है।

Example:

Terraform Code
      ↓
Checkov
      ↓
Security Policies
      ↓
PASS / FAIL

Example:

Terraform Subnet
      ↓
Checkov
      ↓
NSG configured?
      ↓
NO
      ↓
❌ FAIL

इसका फायदा यह है कि Azure resource create होने से पहले ही security issue पता चल सकता है।


🛡️ Step 02 — Trivy

Trivy एक broad security scanner है।

यह कई प्रकार के security targets scan कर सकता है और Infrastructure-as-Code scanning भी support करता है।

हमारे project में इसका use Terraform/IaC security scanning के लिए करेंगे।

Terraform
   ↓
Trivy
   ↓
Security Scan
   ↓
Findings

यह अलग-अलग प्रकार के security checks कर सकता है, जैसे:

Vulnerabilities
Misconfigurations
Secrets
Dependencies
Container Images
Infrastructure as Code

हमारे project में इसका use security scanning layer को मजबूत करने के लिए किया जाएगा।


🏆 Step 03 — Best Practice: Local + Pipeline

Security tools को केवल GitHub Actions में blindly add नहीं करेंगे।

Best practice:

Developer Machine
       ↓
Install Tool
       ↓
Local Scan
       ↓
Fix Issues
       ↓
Git Commit
       ↓
GitHub
       ↓
GitHub Actions
       ↓
Automatic Security Scan

इससे developer push करने से पहले ही problem पकड़ सकता है।

💻 Step 04 — Local PC क्यों?

Local scan का फायदा:

❌ Push
   ↓
❌ Pipeline Fail
   ↓
❌ वापस Code Fix

के बजाय:

💻 Local Scan
   ↓
🔍 Finding
   ↓
🔧 Fix
   ↓
🚀 Push

इससे development faster होता है।

🛡️ Step 05 — Checkov Install करें

Windows पर Python/PIP available है तो:

python --version

फिर:

pip install checkov

Installation verify करें:

checkov --version

Expected:

Checkov version

अगर यह version दिखाई देता है तो Checkov successfully installed है।


📂 Step 06 — Terraform Project पर जाएँ

Project root:

cd D:\Projects3\comsolve-cyberex-azure-landing-zone

Terraform directory:

cd terraform

Structure:

terraform/
   │
   ├── main.tf
   ├── variables.tf
   ├── providers.tf
   ├── outputs.tf
   │
   └── modules/
         │
         ├── vnet
         ├── subnet
         ├── nic
         └── resource-group

              ↓

          checkov -d .

              ↓

        Security Analysis


🔍 Step 07 — Checkov Local Scan

Terraform directory के अंदर:

checkov -d .

यह current directory के Terraform/IaC files scan करेगा।

Basic flow:

terraform/
     ↓
checkov -d .
     ↓
Terraform Files
     ↓
Security Checks


📊 Step 08 — Checkov Result समझें

Output में generally:

Passed checks
Failed checks
Skipped checks

जैसी information मिल सकती है।

Example:

Passed checks: 20
Failed checks: 3
Skipped checks: 1



इस stage पर हमारा goal केवल scan चलाना और result देखना है।



Deep explanation Phase 15 में करेंगे।

🐳 Step 09 — Trivy Install

Windows पर recommended simple method:

winget install AquaSecurity.Trivy

Installation के दौरान अगर Microsoft Store agreements पूछे:

[Y] Yes
[N] No

तो package install करने के लिए:

Y

select करें।

Successful installation के बाद message दिखाई देगा:

Successfully installed

Trivy को local machine पर install करके पहले test करना recommended है।

Installation के बाद verify करें:

trivy --version

Expected:

Version: ...


🔍 Step 10 — Trivy Terraform Scan

Terraform directory में:

trivy config .

यह Infrastructure-as-Code configuration scan करेगा।

Flow:

Terraform
    ↓
Trivy Config Scanner
    ↓
Security Checks
    ↓
Findings
🧪 Step 11 — Local Security Validation

अब दोनों tools local में test करें:

checkov -d .

और:

trivy config .

अगर tools successfully execute हो रहे हैं तो local integration complete है।

🚀 Step 12 — अब GitHub Actions में Add करेंगे

Local testing के बाद tools को GitHub Actions में integrate करेंगे।

Important principle:

Local Tool
     +
CI Tool

दोनों चाहिए।

Local:

Developer Testing

CI:

Automated Enforcement


📂 Step 13 — GitHub Workflow Location

Existing workflow:

.github/
└── workflows/
    └── terraform-ci.yml

यही हमारी existing Terraform CI pipeline है।

Security tools के लिए अलग workflow बनाने की जरूरत अभी नहीं है।

पहले existing pipeline में security stages add करेंगे।



🔐 Step 14 — Security Scan Pipeline में कहाँ होगा?

Current:

Checkout
   ↓
Azure Login
   ↓
Setup Terraform
   ↓
Terraform fmt
   ↓
Terraform init
   ↓
Terraform validate
   ↓
Terraform plan

Updated:

Checkout
   ↓
Azure Login
   ↓
Setup Terraform
   ↓
Terraform fmt
   ↓
Terraform init
   ↓
Terraform validate
   ↓
🛡️ Checkov
   ↓
🛡️ Trivy
   ↓
Terraform plan
🧠 Step 15 — Security Scan Plan से पहले क्यों?

Security scan को Terraform Plan से पहले रखना useful है।

Reason:

Terraform Code
      ↓
Format
      ↓
Validate
      ↓
Security Scan
      ↓
PASS?
  ┌───┴───┐
 YES      NO
  ↓        ↓
Plan     STOP

अगर security check fail हो:

❌ Security Issue
       ↓
❌ Pipeline Stop
       ↓
❌ Terraform Plan नहीं

इससे insecure configuration आगे नहीं जाती।

🛡️ Step 16 — Checkov GitHub Actions

Workflow में Checkov step add करेंगे:

# ------------------------------------------------------------------------
# Checkov Security Scan
# ------------------------------------------------------------------------

- name: Checkov Security Scan
  uses: bridgecrewio/checkov-action@master
  with:
    directory: terraform
    framework: terraform

यह GitHub Actions runner पर Checkov execute करेगा।

🛡️ Step 17 — Trivy GitHub Actions

Trivy को भी workflow में add करेंगे:

# ------------------------------------------------------------------------
# Trivy Security Scan
# ------------------------------------------------------------------------

- name: Trivy IaC Security Scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: config
    scan-ref: terraform

यह Terraform/IaC configuration को scan करेगा।

📍 Step 18 — Existing Pipeline में Position

Final structure:

Checkout Repository
        ↓
Azure Login
        ↓
Verify Azure
        ↓
Setup Terraform
        ↓
Terraform Format Check
        ↓
Terraform Init
        ↓
Terraform Validate
        ↓
Checkov Security Scan
        ↓
Trivy Security Scan
        ↓
Terraform Plan
🚦 Step 19 — Security Gate

Security scan को pipeline gate की तरह use करेंगे।

Security Scan
      ↓
   Result
      │
 ┌────┴────┐
 │         │
PASS      FAIL
 │         │
 ▼         ▼
Plan     Pipeline Stop

इसका मतलब:

Security check fail होने पर pipeline automatically आगे नहीं बढ़नी चाहिए।

🧪 Step 20 — GitHub Actions Run

Code save करने के बाद:

git status

Files check करें:

git add .

Commit:

git commit -m "feat: add Terraform security scanning"

Push:

git push


🐙 Step 21 — GitHub Actions देखें

GitHub repository:

Actions
   ↓
Terraform CI
   ↓
Latest Workflow Run

अब logs में:

Checkout Repository
       ↓
Azure Login
       ↓
Setup Terraform
       ↓
Terraform Format Check
       ↓
Terraform Init
       ↓
Terraform Validate
       ↓
Checkov Security Scan
       ↓
Trivy IaC Security Scan
       ↓
Terraform Plan

दिखना चाहिए।

🔍 Step 22 — Checkov Logs

GitHub Actions में:

Checkov Security Scan

step open करें।

यहाँ हमें Checkov का scan output दिखाई देगा।

हम Phase 15 में सीखेंगे:

What is the check?
Why did it fail?
What is the risk?
How to fix it?
Should we suppress it?
🔍 Step 23 — Trivy Logs

इसके बाद:

Trivy IaC Security Scan

open करें।

यहाँ Trivy के findings दिखाई देंगे।

Phase 15 में हम समझेंगे:

Misconfiguration
Severity
Target
Finding
Remediation


🧪 Step 24 — Local vs GitHub Actions

दोनों environments का purpose अलग है।

💻 Local
Developer
   ↓
Security Tool
   ↓
Quick Feedback
   ↓
Fix Code
🐙 GitHub Actions
Developer
   ↓
Git Push
   ↓
GitHub Actions
   ↓
Security Scan
   ↓
Enforced Check
🏆 Step 25 — Recommended Security Workflow

हमारा development model:

                    💻 Developer PC
                           │
                           ▼
                    Terraform Code
                           │
                           ▼
                  🔍 Local Checkov
                           │
                           ▼
                    🔍 Local Trivy
                           │
                           ▼
                       Fix Issues
                           │
                           ▼
                       Git Commit
                           │
                           ▼
                        Git Push
                           │
                           ▼
                    🐙 GitHub Actions
                           │
                           ▼
                     Checkov Scan
                           │
                           ▼
                      Trivy Scan
                           │
                    ┌──────┴──────┐
                    │             │
                   PASS          FAIL
                    │             │
                    ▼             ▼
             Terraform Plan     Stop
🧠 Step 26 — Security Tools Repository में रखें या नहीं?

Security tools की installation files repository में रखने की जरूरत नहीं है।

❌ यह नहीं करना:

tools/
├── checkov.exe
├── trivy.exe
└── security-tool-files/

Instead:

Repository
     ↓
Terraform Code
     +
GitHub Workflow
     ↓
GitHub Runner
     ↓
Tool Automatically Installed/Executed
🔐 Step 27 — Security Credentials के साथ क्या करें?

Security tools के लिए भी credentials hard-code नहीं करने हैं।

❌ Never commit:

Password
API Token
Cloud Credential
Client Secret
Private Key

Repository में:

❌ Secrets
❌ Passwords
❌ Tokens

Workflow में जरूरत हो तो:

GitHub Secrets

use करेंगे।

### 🧩 Step 28 — Enterprise Security Tools

| Tool | Category | Primary Purpose |
| :--- | :--- | :--- |
| **Checkov** | ![IaC](https://img.shields.io/badge/Category-IaC_Security-blue?style=flat-square) | IaC Security |
| **Trivy** | ![Security](https://img.shields.io/badge/Category-Security-red?style=flat-square) | Vulnerability + IaC Security |
| **Prisma Cloud** | ![Cloud Native](https://img.shields.io/badge/Category-CNAPP-orange?style=flat-square) | Cloud Security / CNAPP |
| **Black Duck** | ![SCA](https://img.shields.io/badge/Category-SCA-purple?style=flat-square) | Software Composition / Open Source Security |
| **Aqua Security** | ![Container](https://img.shields.io/badge/Category-Container-brightgreen?style=flat-square) | Container / Cloud Native Security |
| **Prometheus** | ![Monitoring](https://img.shields.io/badge/Category-Monitoring-yellow?style=flat-square) | Monitoring |
| **Grafana** | ![Observability](https://img.shields.io/badge/Category-Observability-informational?style=flat-square) | Visualization / Observability |

> ⚠️ **Note:** सभी tools एक ही काम नहीं करते, हर tool का specific use-case होता है।



### 🧩 Step 28 — Enterprise Security Tools

Industry में अलग-अलग organizations अपनी जरूरतों के हिसाब से अलग-अलग tools use करती हैं।

| Tool | Primary Purpose |
| :--- | :--- |
| **Checkov** | IaC Security |
| **Trivy** | Vulnerability + IaC Security |
| **Prisma Cloud** | Cloud Security / CNAPP |
| **Black Duck** | Software Composition / Open Source Security |
| **Aqua Security** | Container / Cloud Native Security |
| **Prometheus** | Monitoring |
| **Grafana** | Visualization / Observability |

> ⚠️ **Note:** सभी tools एक ही काम नहीं करते, हर tool का specific security use-case होता है।



🎯 Step 29 — इस Phase में क्या नहीं करेंगे?

इस Phase में हम अभी:

❌ Deep vulnerability analysis
❌ Custom security policies
❌ Enterprise Prisma configuration
❌ Black Duck integration
❌ Advanced Trivy configuration
❌ Security dashboards

नहीं करेंगे।

इन topics को आगे के phases में समझेंगे।

📁 Step 30 — Final Repository Structure

Phase 14 के बाद structure roughly:

comsolve-cyberex-azure-landing-zone/
│
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
│
├── docs/
│   ├── phase-13-azure-oidc-troubleshooting.md
│   └── phase-14-terraform-security-automation.md
│
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── locals.tf
│   ├── outputs.tf
│   │
│   └── modules/
│       ├── resource-group/
│       ├── vnet/
│       ├── subnet/
│       └── nic/
│
└── .gitignore

🏆 Phase 14 Final Architecture
                         🐙 GitHub
                              │
                              ▼
                       GitHub Actions
                              │
                              ▼
                       Azure OIDC 🔐
                              │
                              ▼
                     Terraform CI Pipeline
                              │
             ┌────────────────┼────────────────┐
             │                │                │
             ▼                ▼                ▼
        Terraform         Checkov 🔍       Trivy 🔍
         Validation        IaC Scan          IaC Scan
             │                │                │
             └────────────────┼────────────────┘
                              │
                         Security Gate
                              │
                       ┌──────┴──────┐
                       │             │
                      PASS          FAIL
                       │             │
                       ▼             ▼
                 Terraform Plan    STOP ❌
                       │
                       ▼
                     Azure ☁️
🎯 Phase 14 Key Takeaway

Security scanning केवल developer के local machine पर नहीं होना चाहिए।

Best practice:

Local Security Scan
        +
CI/CD Security Scan
        =
Automated Security

Local scan developer को जल्दी feedback देता है।

GitHub Actions scan security policy को enforce करता है।

इससे Terraform infrastructure Azure तक पहुँचने से पहले security validation से गुजरता है।

🔜 Next Phase — Phase 15
🔍 Security Tools Deep Dive

अगले Phase में हम practically समझेंगे:

Checkov
   ↓
What does it scan?
   ↓
What is a failed check?
   ↓
Severity
   ↓
Security Risk
   ↓
Remediation

और:

Trivy
   ↓
What does it scan?
   ↓
Misconfiguration
   ↓
Severity
   ↓
Finding
   ↓
Remediation

इसके बाद हम intentionally एक insecure Terraform configuration बनाएँगे:

Terraform
    ↓
Security Issue
    ↓
Checkov ❌
    ↓
Trivy ❌
    ↓
Pipeline Failed

फिर उसे secure करेंगे:

Fix Terraform
     ↓
Checkov ✅
     ↓
Trivy ✅
     ↓
Terraform Plan ✅

🚀 Goal: Security को Terraform development lifecycle का automatic हिस्सा बनाना।

