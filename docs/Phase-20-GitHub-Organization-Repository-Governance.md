# 🏢 Phase 20 — GitHub Organization + Repository Governance

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Repository%20Governance-181717?style=for-the-badge&logo=github&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Security](https://img.shields.io/badge/Security-Governance-success?style=for-the-badge)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Pull Request](https://img.shields.io/badge/Pull%20Request-Review-blue?style=for-the-badge)
![Branch Protection](https://img.shields.io/badge/Branch-Protection-orange?style=for-the-badge)

</p>

> 🎯 **Objective:** GitHub repository को केवल code storage के रूप में नहीं, बल्कि एक **secure, controlled और governed development platform** के रूप में configure करना, ताकि code changes, Pull Requests, branches, secrets, permissions और CI/CD workflow properly controlled रहें।

---

# 📌 Phase Overview

अब तक हमने infrastructure और CI/CD security पर काफी काम कर लिया है।

Phase 20 में focus होगा:

- 🏢 GitHub Organization structure
- 🔐 Repository security
- 🌿 Branch strategy
- 🛡️ Branch protection
- 🔄 Pull Request governance
- 👥 Access control
- 🔑 Secrets और variables management
- ⚙️ GitHub Actions permissions
- 🚫 Unauthorized direct changes को रोकना
- 📋 Code review process
- 🔍 Audit और governance

---

# 🏗️ 20.1 — GitHub Governance Architecture

हमारा desired structure:

```text
GitHub Organization
        │
        ├── Teams
        │
        ├── Repositories
        │      │
        │      └── Cyberex Landing Zone
        │
        ├── Repository Policies
        │
        ├── Branch Protection
        │
        ├── Secrets / Variables
        │
        └── GitHub Actions Policies
```

---

🏢 20.2 — GitHub Organization

Current project:

comsolve-cyberex-azure-landing-zone

एक repository है।

Production environment में इसे Organization के अंदर रखना ज्यादा suitable architecture हो सकता है।

Example:

ComSolve Organization
        │
        ├── Cyberex
        │
        ├── Infrastructure
        │
        ├── Application
        │
        └── Security / DevOps

Organization का फायदा:

Centralized access management
Teams
Repository policies
Security controls
Centralized secrets/variables
Better governance
👥 20.3 — Team-Based Access Control

हर व्यक्ति को repository पर full access देना जरूरी नहीं है।

Example:

Organization
      │
      ├── DevOps Team
      │      └── Maintain
      │
      ├── Developers
      │      └── Write
      │
      ├── Security Team
      │      └── Read / Review
      │
      └── Admin Team
             └── Admin

Principle:

Least Privilege

जिस व्यक्ति को जितनी permission चाहिए, उतनी ही permission दी जाए।

🌿 20.4 — Branch Strategy

हमारे project में feature branch workflow already use किया गया:

main
 │
 ├── feature/nic-infrastructure
 │
 ├── feature/nsg
 │
 └── feature/monitoring

Development flow:

Developer
    │
    ▼
Feature Branch
    │
    ▼
Code Changes
    │
    ▼
Push
    │
    ▼
Pull Request
    │
    ▼
CI Pipeline
    │
    ▼
Review
    │
    ▼
Merge → main
🛡️ 20.5 — Main Branch Protection

सबसे important governance control:

main

branch को direct modification से protect करना।

Desired behavior:

Developer
    │
    ├── ❌ Direct Push → main
    │
    └── ✅ Pull Request → main

इससे हर important change review process से गुजरता है।

🔐 20.6 — Pull Request Security

Pull Request बनते ही CI pipeline run हो सकती है।

Current security flow:

Pull Request
      │
      ▼
GitHub Actions
      │
      ├── Terraform Format
      ├── Terraform Init
      ├── Terraform Validate
      ├── Trivy Scan
      └── Terraform Plan
      │
      ▼
Security Gate

अगर security scan fail होता है:

Trivy
  │
  ▼
HIGH / CRITICAL Finding
  │
  ▼
Pipeline FAIL
  │
  ▼
PR Should Not Merge

इस तरह security को Pull Request workflow का हिस्सा बनाया जाता है।

# 🚦 20.7 — Required Status Checks

Branch protection में CI checks को required बनाया जा सकता है।

Example:

Pull Request
     │
     ▼
Terraform Validation
     │
     ▼
Trivy Security Scan
     │
     ▼
Terraform Plan
     │
     ▼
All Checks PASS
     │
     ▼
Merge Allowed

अगर कोई required check fail:

Check Failed
     │
     ▼
Merge Blocked

यह हमारे Security Gate को governance layer से connect करता है।

# 👀 20.8 — Pull Request Review

Infrastructure code में direct merge avoid करना चाहिए।

Recommended workflow:

Developer
    │
    ▼
Pull Request
    │
    ▼
CI Security Scan
    │
    ▼
Code Review
    │
    ▼
Approval
    │
    ▼
Merge

इससे एक व्यक्ति अकेले production infrastructure change नहीं कर सकता।

# 🔑 20.9 — Secrets & Variables Governance
``` text
Azure authentication के लिए हमने GitHub Actions में variables use किए:

${{ vars.AZURE_CLIENT_ID }}
${{ vars.AZURE_TENANT_ID }}
${{ vars.AZURE_SUBSCRIPTION_ID }}

Important principle:

❌ Azure credentials → Terraform Code
❌ Credentials → Git repository
❌ Credentials → workflow YAML

✅ GitHub Variables / Secrets
✅ OIDC Authentication

इससे sensitive information source code में expose होने से बचती है।
```
---

# 🔐 20.10 — GitHub Actions Permissions

Workflow में हमने:

permissions:
  contents: read
  id-token: write

configure किया।

यह important security principle follow करता है:

Workflow को केवल required permissions देना।

Example:

contents: read
       │
       ▼
Repository Checkout

id-token: write
       │
       ▼
Azure OIDC Authentication

Unnecessary permissions avoid की जानी चाहिए।

# 🔍 20.11 — Repository Security Controls

Repository governance में future controls:

Repository
    │
    ├── Branch Protection
    │
    ├── Pull Request Review
    │
    ├── Required Status Checks
    │
    ├── Secret Management
    │
    ├── Actions Permissions
    │
    ├── Dependabot
    │
    ├── Secret Scanning
    │
    └── Audit / Security Logs

इनका purpose repository को सिर्फ functional नहीं बल्कि secure और maintainable बनाना है।

# 🧩 20.12 — Infrastructure Change Governance

Terraform project में कोई भी infrastructure change अब ideally:

Code Change
     │
     ▼
Feature Branch
     │
     ▼
Pull Request
     │
     ▼
Terraform Validation
     │
     ▼
Trivy Security Scan
     │
     ▼
Terraform Plan
     │
     ▼
Review
     │
     ▼
Approval
     │
     ▼
Merge

के through जाना चाहिए।

इससे infrastructure change का proper trail maintain होता है।

# 📝 20.13 — Commit Governance

Good commit practice:

feat: add network security group
fix: update subnet configuration
security: improve terraform security controls
docs: update monitoring documentation
ci: improve terraform pipeline

Avoid:

test
changes
final
final2
new
working

Meaningful commit messages future troubleshooting और auditing में useful होते हैं।

# 🔄 20.14 — Complete Secure Development Flow

अब हमारे project का complete flow:

Developer
    │
    ▼
Feature Branch
    │
    ▼
Terraform Code
    │
    ▼
Pull Request
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
Controlled Deployment
    │
    ▼
Azure
    │
    ▼
Monitoring / Observability


# 🛡️ 20.15 — Defense in Depth

अब project में security multiple layers में है:

Layer 01
GitHub Access Control
        ↓
Layer 02
Branch Protection
        ↓
Layer 03
Pull Request Review
        ↓
Layer 04
Terraform Validation
        ↓
Layer 05
Trivy IaC Security Scan
        ↓
Layer 06
Terraform Plan
        ↓
Layer 07
Controlled Deployment
        ↓
Layer 08
Azure Monitoring

अगर एक layer में issue रह भी जाए, तो दूसरी layer उसे detect या prevent करने में मदद कर सकती है।
---

### 📊 Step 20.16 — Project Governance Status

| Governance Component | Status |
| :--- | :--- |
| **GitHub Repository** | ![Status](https://img.shields.io/badge/Status-Available-brightgreen?style=flat-square) |
| **Feature Branch Strategy** | ![Status](https://img.shields.io/badge/Status-Implemented-brightgreen?style=flat-square) |
| **Pull Request Workflow** | ![Status](https://img.shields.io/badge/Status-Implemented-brightgreen?style=flat-square) |
| **GitHub Actions CI** | ![Status](https://img.shields.io/badge/Status-Implemented-brightgreen?style=flat-square) |
| **Azure OIDC** | ![Status](https://img.shields.io/badge/Status-Implemented-brightgreen?style=flat-square) |
| **Terraform Validation** | ![Status](https://img.shields.io/badge/Status-Implemented-brightgreen?style=flat-square) |
| **Trivy Security Scan** | ![Status](https://img.shields.io/badge/Status-Implemented-brightgreen?style=flat-square) |
| **Terraform Plan** | ![Status](https://img.shields.io/badge/Status-Implemented-brightgreen?style=flat-square) |
| **Security Gate** | ![Status](https://img.shields.io/badge/Status-Implemented-brightgreen?style=flat-square) |
| **Branch Protection** | ![Status](https://img.shields.io/badge/Status-To_Configure-yellow?style=flat-square) |
| **Required Status Checks** | ![Status](https://img.shields.io/badge/Status-To_Configure-yellow?style=flat-square) |
| **Mandatory PR Approval** | ![Status](https://img.shields.io/badge/Status-To_Configure-yellow?style=flat-square) |
| **GitHub Organization** | ![Status](https://img.shields.io/badge/Status-To_Configure-yellow?style=flat-square) |
| **Team-Based Access** | ![Status](https://img.shields.io/badge/Status-To_Configure-yellow?style=flat-square) |
| **Secret Scanning** | ![Status](https://img.shields.io/badge/Status-To_Configure-yellow?style=flat-square) |
| **Dependabot** | ![Status](https://img.shields.io/badge/Status-To_Configure-yellow?style=flat-square) |
| **Repository Governance Policy** | ![Status](https://img.shields.io/badge/Status-To_Configure-yellow?style=flat-square) |

---

# 🎯 20.17 — Production Governance Target

Final target:

```text

                    GitHub Organization
                            │
                    ┌───────┴───────┐
                    │               │
                  Teams        Repositories
                    │               │
                    │               ▼
                    │          Cyberex LZ
                    │               │
                    │        Branch Protection
                    │               │
                    │               ▼
                    │          Pull Request
                    │               │
                    │               ▼
                    │        GitHub Actions
                    │               │
                    │       ┌───────┴────────┐
                    │       │                │
                    │   Terraform         Trivy
                    │   Validation          Scan
                    │       │                │
                    │       └───────┬────────┘
                    │               │
                    │               ▼
                    │        Security Gate
                    │               │
                    └───────────────┤
                                    ▼
                               Code Review
                                    │
                                    ▼
                                  Merge
                                    │
                                    ▼
                             Azure Deployment
                                    │
                                    ▼
                            Azure Monitoring
```
---

# 🏁 Phase 20 Outcome

Phase 20 का उद्देश्य GitHub repository को secure और governed development environment में convert करना है। इसमें Organization, Teams, Access Control, Branch Protection, Pull Request Review, Required Checks, Secrets Management और GitHub Actions Permissions को properly govern किया जाता है।

हमारे project का security journey अब:

```text

Terraform
    ↓
GitHub
    ↓
CI/CD
    ↓
Trivy
    ↓
Security Gate
    ↓
Pull Request
    ↓
Code Review
    ↓
Controlled Merge
    ↓
Azure
    ↓
Monitoring

तक पहुँच चुका है।
```

---

# 🚀 Final Project Position

```text 

Phase 01–04
Foundation & Planning
        ↓
Phase 05–06
Terraform + Azure Network Foundation
        ↓
Phase 07–15
Infrastructure Development
        ↓
Phase 16
Security Gate + Pull Request Security
        ↓
Phase 17
Security Findings & Remediation
        ↓
Phase 18
Secure CI/CD Pipeline
        ↓
Phase 19
Monitoring / Observability
        ↓
Phase 20
GitHub Organization + Repository Governance
```

---