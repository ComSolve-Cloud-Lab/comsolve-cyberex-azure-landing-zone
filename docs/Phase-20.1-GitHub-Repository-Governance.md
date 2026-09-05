````markdown
# 🏢 Phase 20.1 — GitHub Repository Security & Governance Implementation

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Repository%20Governance-181717?style=for-the-badge&logo=github&logoColor=white)

![Branch Protection](https://img.shields.io/badge/Branch-Protection-success?style=for-the-badge)

![Pull Request](https://img.shields.io/badge/Pull%20Request-Review-blue?style=for-the-badge)

![Security](https://img.shields.io/badge/Security-Repository%20Hardening-red?style=for-the-badge)

![Dependabot](https://img.shields.io/badge/Dependabot-Dependency%20Security-0366D6?style=for-the-badge)

![Secret Scanning](https://img.shields.io/badge/Secret%20Scanning-Enabled-orange?style=for-the-badge)

</p>

> 🎯 **Objective:** GitHub repository को secure, controlled और production-ready governance model में configure करना ताकि unauthorized changes, unreviewed infrastructure modifications, exposed secrets और vulnerable dependencies को prevent तथा detect किया जा सके।

---

# 📌 Phase 20.1 Overview

इस phase में हम GitHub repository की security और governance को practically implement करेंगे।

हमारा target:

```text
GitHub Repository
       │
       ├── Branch Protection
       │
       ├── Required Status Checks
       │
       ├── Pull Request Approval
       │
       ├── Secret Scanning
       │
       ├── Dependabot
       │
       ├── Access Control
       │
       └── Repository Governance Policy
````

---

# 🧭 20.1.1 — Current Project Position

हमारे project में अभी तक:

```text
Terraform
    │
    ▼
GitHub Repository
    │
    ▼
GitHub Actions
    │
    ├── Terraform Format
    ├── Terraform Init
    ├── Terraform Validate
    ├── Trivy Security Scan
    └── Terraform Plan
    │
    ▼
Security Gate
```

successfully establish हो चुका है।

अब problem यह है कि कोई developer theoretically:

```text
Developer
    │
    ▼
main branch
    │
    ▼
Direct Push
```

कर सकता है।

इसीलिए GitHub Governance की जरूरत है।

---

# 🛡️ 20.1.2 — Governance क्यों जरूरी है?

मान लो किसी developer ने Terraform में यह change कर दिया:

```text
NSG Rule
        ↓
Internet Access
        ↓
0.0.0.0/0
        ↓
Unwanted Exposure
```

अगर branch protection नहीं है तो change सीधे `main` में जा सकता है।

Governance के बाद:

```text
Developer
    │
    ▼
Feature Branch
    │
    ▼
Pull Request
    │
    ▼
GitHub Actions
    │
    ├── Terraform Validate
    ├── Trivy
    └── Terraform Plan
    │
    ▼
Required Checks
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

इससे infrastructure changes controlled हो जाते हैं।

---

# 🧱 20.1.3 — Governance Implementation Order

हम इसे इस order में implement करेंगे:

```text
Step 01
Repository Baseline
        ↓
Step 02
Branch Protection
        ↓
Step 03
Required Status Checks
        ↓
Step 04
Mandatory Pull Request Approval
        ↓
Step 05
Secret Scanning
        ↓
Step 06
Dependabot
        ↓
Step 07
Access Control / Teams
        ↓
Step 08
GitHub Organization
        ↓
Step 09
Repository Governance Policy
        ↓
Step 10
Final Validation
```

---

# 🔎 Step 01: Repository Baseline

सबसे पहले current repository state verify करेंगे।

Repository:

```text
comsolve-cyberex-azure-landing-zone
```

Current branch:

```text
feature/nic-infrastructure
```

Git status check:

```powershell
git status
```

Current branch check:

```powershell
git branch --show-current
```

Remote repository check:

```powershell
git remote -v
```

Recent commits:

```powershell
git log --oneline -5
```

इन commands का purpose:

```text
git status
    ↓
Working tree clean है?

git branch
    ↓
हम किस branch पर हैं?

git remote
    ↓
किस GitHub repository से connected हैं?

git log
    ↓
Recent changes क्या हैं?
```

---

# 🧹 — Working Tree Clean होना चाहिए

Governance implementation शुरू करने से पहले:

```powershell
git status
```

Expected:

```text
nothing to commit, working tree clean
```

अगर changes दिखाई दें:

```text
modified:
untracked:
deleted:
```

तो पहले उन changes को समझना जरूरी है।

बिना समझे:

```text
git reset
git clean
```

जैसी destructive commands नहीं चलानी हैं।

---

# 🌿 Step 02: Branch Protection

अब सबसे important control:

```text
main branch protection
```

GitHub repository में जाएँ:

```text
Repository
   ↓
Settings
   ↓
Branches
   ↓
Branch protection rules
```

कुछ GitHub interfaces में यह functionality:

```text
Settings
   ↓
Rules
   ↓
Rulesets
```

के अंदर भी दिखाई दे सकती है।

---

# 🔐 20.1.7 — Main Branch को Protect करना

Target branch:

```text
main
```

हमारा desired behavior:

```text
❌ Direct Push → main

✅ Feature Branch
       ↓
   Pull Request
       ↓
     Review
       ↓
      Merge
```

Branch protection का primary purpose है:

> `main` branch में uncontrolled changes को रोकना।

---

# 🚫 20.1.8 — Direct Push Restriction

Protection में यह principle रखना है:

```text
main
 │
 ├── ❌ Direct Push
 │
 └── ✅ Pull Request
```

इसका मतलब developer पहले:

```text
feature/*
```

branch पर काम करेगा।

Example:

```text
feature/nic-infrastructure
feature/nsg
feature/monitoring
```

फिर Pull Request बनाएगा।

---

# 🔄 20.1.9 — Pull Request Requirement

Branch protection में:

```text
Require a pull request before merging
```

enable करना है।

Desired configuration:

```text
Pull Request Required
        ↓
Yes
```

इससे direct merge process बंद होकर review-based process शुरू होता है।

---

# 👀 Step 03: Required Status Checks

हमारी CI pipeline already मौजूद है:

```text
GitHub Actions
      │
      ├── Terraform Format
      ├── Terraform Init
      ├── Terraform Validate
      ├── Trivy
      └── Terraform Plan
```

अब हमें GitHub को बताना है:

> "इन checks के successful होने के बिना `main` में merge नहीं होना चाहिए।"

---

# 🚦 20.1.11 — Required Checks का Concept

Flow:

```text
Pull Request
      │
      ▼
GitHub Actions
      │
      ├── Terraform Format
      │
      ├── Terraform Validate
      │
      ├── Trivy
      │
      └── Terraform Plan
      │
      ▼
All Required Checks PASS
      │
      ▼
Merge Allowed
```

अगर Trivy fail:

```text
Trivy
  ↓
FAIL
  ↓
Required Check Failed
  ↓
Merge Blocked
```

---

# 🔍  Important: Check का Exact Name

Required status check configure करते समय अनुमान से नाम नहीं डालना है।

पहले एक Pull Request खोलकर:

```text
Actions
    ↓
Workflow Run
    ↓
Job
```

में actual check/job name देखना है।

हमारे workflow में job:

```yaml
jobs:

  terraform:

    name: Terraform Validation
```

इसलिए GitHub में status check का displayed name verify करना जरूरी है।

---

# 🧪 Step 04: Mandatory PR Approval

अब दूसरा governance layer:

```text
Code Review
```

Branch protection में:

```text
Require approvals
```

enable करना है।

Recommended starting point:

```text
Required approvals: 1
```

Flow:

```text
Developer
    │
    ▼
Pull Request
    │
    ▼
CI Checks
    │
    ▼
Reviewer
    │
    ▼
1 Approval
    │
    ▼
Merge
```

---

# 🛑 Why One Approval?

Infrastructure repository में:

```text
Terraform
+
Azure Networking
+
Security
```

involved है।

इसलिए एक व्यक्ति द्वारा किया गया change दूसरे व्यक्ति द्वारा review होना बेहतर practice है।

Example:

```text
Developer A
    │
    ▼
Terraform NSG Change
    │
    ▼
Pull Request
    │
    ▼
Developer / Security Reviewer
    │
    ▼
Approve
```

---

# 🔐 Step 05: Secret Scanning

अब repository security का important part:

```text
Secret Scanning
```

Purpose:

> Accidentally committed credentials या sensitive tokens को detect करना।

Potential secrets:

```text
Azure Client Secret
GitHub Token
API Key
Private Key
Cloud Credential
Database Password
```

---

# 🚨 Secret Exposure Example

गलत practice:

```hcl
client_secret = "xxxxxxxxxxxxxxxx"
```

Repository में ऐसा secret commit नहीं होना चाहिए।

हमारा desired architecture:

```text
Terraform Code
      │
      ├── No Secrets
      │
      ▼
GitHub Actions
      │
      ▼
OIDC
      │
      ▼
Azure
```

हम पहले से Azure OIDC use कर रहे हैं, इसलिए static Azure credentials की dependency कम होती है।

---

# 🔍 Secret Scanning Enable करना

Repository में:

```text
Settings
   ↓
Security
   ↓
Code security and analysis
```

जाएँ।

वहाँ available security features verify करें।

अगर उपलब्ध हो:

```text
Secret scanning
```

enable करें।

कुछ advanced features GitHub plan और repository visibility पर depend कर सकते हैं।

इसलिए option available है या नहीं, पहले verify करना है।

---

# 🤖 Step 06: Dependabot

अब dependency security।

हमारे repository में dependencies हैं:

```text
Terraform Provider
GitHub Actions
Azure Actions
Third-party Actions
```

Example:

```yaml
uses: actions/checkout@v4
```

या:

```yaml
uses: azure/login@v2
```

Future में action versions vulnerable हो सकते हैं।

Dependabot outdated या vulnerable dependencies identify/update करने में मदद कर सकता है।

---

# 🔄 Dependabot Flow

```text
Repository
    │
    ▼
Dependency Detection
    │
    ▼
Outdated / Vulnerable Dependency
    │
    ▼
Dependabot Alert / PR
    │
    ▼
Review
    │
    ▼
CI Pipeline
    │
    ▼
Merge
```

यह automated dependency maintenance का हिस्सा है।

---

# 📄 Dependabot Configuration

Repository में future configuration:

```text
.github/
└── dependabot.yml
```

Example structure:

```yaml
version: 2

updates:

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

इसका purpose:

```text
.github/workflows/*
        ↓
GitHub Actions Dependencies
        ↓
Dependabot
        ↓
Update Detection
```

Terraform ecosystem को भी जरूरत के अनुसार configure किया जा सकता है।

---

# 👥 Step 07: Team-Based Access

अब individual permissions के बजाय teams use करने का target है।

Example:

```text
GitHub Organization
        │
        ├── DevOps Team
        │
        ├── Security Team
        │
        ├── Development Team
        │
        └── Admin Team
```

Repository access:

```text
DevOps
   ↓
Maintain / Write

Security
   ↓
Read / Review

Developers
   ↓
Write

Admins
   ↓
Admin
```

Actual permissions project requirements के अनुसार तय होंगी।

---

# 🔐 Least Privilege

Golden rule:

```text
Maximum Permission
        ❌

Required Permission
        ✅
```

Example:

अगर किसी security reviewer को सिर्फ code review करना है:

```text
Admin
   ❌

Write
   ❌

Read / appropriate review permission
   ✅
```

Unnecessary admin access avoid करना है।

---

# 🏢 Step 08: GitHub Organization

Individual repository से organization model:

```text
GitHub
  │
  ▼
Organization
  │
  ├── Teams
  │
  ├── Repositories
  │
  ├── Policies
  │
  └── Security Controls
```

Example:

```text
ComSolve
   │
   ├── comsolve-cyberex-azure-landing-zone
   ├── application-repository
   ├── security-repository
   └── automation-repository
```

यह centralized governance के लिए useful है।

---

# ⚠️ Organization बनाने से पहले

यह step तुरंत नहीं करना है।

पहले verify करना है:

```text
Current Repository Owner
        ↓
Personal Repository?
        ↓
Organization Repository?
```

अगर repository किसी existing company Organization में already है, तो नया Organization बनाने की जरूरत नहीं है।

इसलिए:

```text
पहले verify
     ↓
फिर decide
     ↓
फिर implement
```

---

# 📋 Step 09: Repository Governance Policy

अब documentation layer।

Repository में:

```text
docs/
```

के अंदर governance documentation रख सकते हैं।

Recommended structure:

```text
docs/
│
├── Phase-18-Secure-CICD-Pipeline.md
├── Phase-19-Monitoring-Observability.md
├── Phase-20-GitHub-Organization-Repository-Governance.md
└── Phase-20.1-GitHub-Repository-Security-Governance.md
```

Governance policy में define किया जा सकता है:

```text
Branch Strategy
Pull Request Requirement
Code Review
Security Scan
Terraform Validation
Commit Standards
Secret Management
Access Control
Dependency Management
```

---

# 📜 Recommended Repository Rules

हमारे project के लिए baseline rules:

```text
Rule 01
main branch protected

Rule 02
Direct push to main restricted

Rule 03
Pull Request required

Rule 04
CI checks must pass

Rule 05
Trivy security scan must pass

Rule 06
Terraform validation must pass

Rule 07
At least one approval required

Rule 08
Secrets must not be committed

Rule 09
Dependencies should be monitored

Rule 10
Infrastructure changes must be reviewed
```

---

# 🔄 Complete Governance Flow

अब पूरा process:

```text
Developer
    │
    ▼
Feature Branch
    │
    ▼
Terraform Change
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
GitHub Actions
    │
    ├── Terraform Format
    ├── Terraform Validate
    ├── Trivy Scan
    └── Terraform Plan
    │
    ▼
Required Checks PASS
    │
    ▼
Code Review
    │
    ▼
Approval
    │
    ▼
Merge
    │
    ▼
main
```

---

# 🛡️ Security Layers

अब repository security:

```text
                GitHub Security
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
 Branch Protection   PR Review     Secret Scanning
        │              │              │
        └──────────────┼──────────────┘
                       ▼
                GitHub Actions
                       │
             ┌─────────┼─────────┐
             ▼         ▼         ▼
         Terraform   Trivy     Plan
         Validate     Scan
             │         │         │
             └─────────┼─────────┘
                       ▼
                 Security Gate
                       │
                       ▼
                    Azure
```

---

# 🧪 Final Validation Checklist

Implementation के बाद हमें यह verify करना है:

| Control                  | Expected                    |
| ------------------------ | --------------------------- |
| Main Branch Protection   | ✅ Enabled                   |
| Direct Push Restriction  | ✅ Enabled                   |
| Pull Request Required    | ✅ Enabled                   |
| Required CI Checks       | ✅ Configured                |
| Terraform Validation     | ✅ Required                  |
| Trivy Scan               | ✅ Required                  |
| PR Approval              | ✅ Required                  |
| Secret Scanning          | ✅ Enabled / Available       |
| Dependabot               | ✅ Configured                |
| Team-Based Access        | ⏳ Organization dependent    |
| GitHub Organization      | ⏳ Verify existing structure |
| Governance Documentation | ✅ Documented                |

---

# 🚨 Important Implementation Rule

इस phase में हम security controls को bypass नहीं करेंगे।

इनका use नहीं करना है:

```text
❌ Skip security check
❌ Ignore Trivy failure
❌ Disable required CI check
❌ Commit credentials
❌ Give everyone Admin access
❌ Direct push to main
```

हमारा principle:

```text
Prevent
   ↓
Validate
   ↓
Review
   ↓
Approve
   ↓
Deploy
   ↓
Monitor
```

---

# 🎯 Phase Outcome

Phase 20.1 complete होने के बाद हमारा GitHub repository model:

```text
                    GitHub Repository
                           │
                 ┌─────────┴─────────┐
                 │                   │
          Access Control       Branch Protection
                 │                   │
                 ▼                   ▼
              Teams              main
                                     │
                                     ▼
                               Pull Request
                                     │
                         ┌───────────┴───────────┐
                         ▼                       ▼
                    CI Security             Code Review
                         │                       │
                    ┌────┴────┐                  │
                    ▼         ▼                  ▼
                 Trivy    Terraform          Approval
                           Validate               │
                    │         │                  │
                    └────┬────┘                  │
                         ▼                       │
                    Security Gate ◄──────────────┘
                         │
                         ▼
                       Merge
                         │
                         ▼
                        main
```

---

# 🏁 Final Status

```text
Repository Security
        │
        ├── Branch Protection      ⏳ Implement
        ├── Required Checks        ⏳ Implement
        ├── PR Approval            ⏳ Implement
        ├── Secret Scanning        ⏳ Verify / Enable
        ├── Dependabot             ⏳ Configure
        ├── Team Access            ⏳ Verify
        ├── Organization           ⏳ Verify
        └── Governance Policy      ⏳ Document
```

> 🔐 **Phase 20.1 का मुख्य उद्देश्य:** GitHub repository में ऐसे controls establish करना जिनसे Terraform infrastructure में होने वाला हर महत्वपूर्ण change **controlled, reviewed, security-scanned और auditable** हो।

---

# 🚀 Next Practical Step

Implementation अब इस क्रम में करेंगे:

```text
20.1.1
Repository Baseline
        ↓
20.1.2
Main Branch Protection
        ↓
20.1.3
Required Status Checks
        ↓
20.1.4
Mandatory PR Approval
        ↓
20.1.5
Secret Scanning
        ↓
20.1.6
Dependabot
        ↓
20.1.7
Teams / Access Control
        ↓
20.1.8
Organization Governance
        ↓
20.1.9
Governance Policy
        ↓
20.1.10
Final Security Validation
```

> 🏆 **Target:** `main` branch को ऐसा बनाना कि कोई भी Terraform infrastructure change बिना **PR + CI Security Checks + Review + Approval** के merge न हो सके।

```
```
