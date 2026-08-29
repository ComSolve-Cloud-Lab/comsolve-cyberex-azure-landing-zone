# 🏢 Phase 20.5 — Repository Governance Policy

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Repository%20Governance-181717?style=for-the-badge\&logo=github\&logoColor=white)

![Security](https://img.shields.io/badge/Repository-Security-success?style=for-the-badge)

![Policy](https://img.shields.io/badge/Governance-Policy-blue?style=for-the-badge)

![CI/CD](https://img.shields.io/badge/CI%2FCD-Controlled-orange?style=for-the-badge)

</p>

> 🎯 **Objective:** Repository में एक स्पष्ट Governance Policy establish करना ताकि code changes, Pull Requests, security controls, CI/CD validation और production changes एक controlled और auditable process के through manage हों।

---

# 📌 1. Project Context

**Project:** ComSolve Cyberex Azure Landing Zone

**Repository:** `comsolve-cyberex-azure-landing-zone`

**Infrastructure:** Terraform + Microsoft Azure

**CI/CD:** GitHub Actions

**Security Scanning:** Trivy

---

# 🏗️ 2. Governance Model

Repository में कोई भी महत्वपूर्ण change सीधे `main` branch में नहीं किया जाएगा।

```text
Developer
    ↓
Feature Branch
    ↓
Pull Request
    ↓
CI Validation
    ↓
Security Scan
    ↓
Review / Approval
    ↓
Merge
    ↓
main
```

---

# 🔐 3. Main Branch Protection

`main` branch को protected branch माना जाएगा।

Required controls:

| Control         | Requirement   |
| --------------- | ------------- |
| Direct Push     | ❌ Not Allowed |
| Force Push      | ❌ Not Allowed |
| Branch Deletion | ❌ Protected   |
| Pull Request    | ✅ Required    |
| Review          | ✅ Required    |
| CI Validation   | ✅ Required    |
| Security Scan   | ✅ Required    |

---

# 🔎 4. Pull Request Policy

हर infrastructure change के लिए Pull Request create किया जाएगा।

PR में:

* Change का clear description होना चाहिए
* संबंधित Terraform files identify होनी चाहिए
* Security impact mention होना चाहिए
* CI checks successful होने चाहिए
* Required approval प्राप्त होना चाहिए

---

# 🧪 5. CI/CD Validation Policy

Terraform change merge करने से पहले CI pipeline successful होनी चाहिए।

```text
Pull Request
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
     ↓
PASS
```

अगर security scan या validation fail होता है:

```text
FAIL
 ↓
Merge Blocked
```

---

# 🛡️ 6. Security Policy

Repository में निम्न security principles follow किए जाएंगे:

* Secrets source code में commit नहीं किए जाएंगे
* Azure credentials GitHub Secrets / OIDC के through manage होंगे
* Infrastructure changes Pull Request के through होंगे
* Security scanning CI pipeline का हिस्सा रहेगा
* Vulnerable dependencies को review किया जाएगा
* Security findings को बिना review के suppress नहीं किया जाएगा

---

# 🔑 7. Secret Management

Sensitive information जैसे:

```text
Azure Client ID
Azure Tenant ID
Azure Subscription ID
Client Secret
Passwords
API Keys
Private Keys
Tokens
```

को Terraform code या Git repository में hard-code नहीं किया जाएगा।

Preferred approach:

```text
GitHub Actions
      ↓
OIDC
      ↓
Microsoft Entra ID
      ↓
Azure
```

---

# 🌿 8. Branching Policy

Recommended branch structure:

```text
main
 │
 ├── feature/*
 │
 ├── fix/*
 │
 └── security/*
```

Example:

```text
feature/nic-infrastructure
fix/terraform-network
security/dependency-update
```

---

# 📝 9. Commit Policy

Commit messages meaningful होने चाहिए।

Recommended format:

```text
feat:
fix:
security:
docs:
refactor:
chore:
```

Examples:

```text
feat(network): add subnet NSG association

security: configure dependabot

fix(terraform): correct subnet configuration

docs: update governance policy
```

---

# 🔄 10. Infrastructure Change Policy

Azure infrastructure में कोई भी change करने से पहले:

```text
Terraform Code Change
        ↓
terraform fmt
        ↓
terraform validate
        ↓
Security Scan
        ↓
terraform plan
        ↓
Pull Request
        ↓
Review
        ↓
Merge
```

Production infrastructure पर direct manual modification avoid किया जाएगा।

---

# 🚨 11. Security Finding Policy

अगर Trivy या किसी future security scanner से finding मिलती है:

```text
Security Finding
       ↓
Identify Root Cause
       ↓
Risk Assessment
       ↓
Remediation
       ↓
Rescan
       ↓
PASS
       ↓
Merge
```

Security finding को केवल pipeline पास कराने के लिए blindly suppress नहीं किया जाएगा।

---

# 👥 12. Code Review Policy

Infrastructure changes कम से कम एक authorized reviewer द्वारा review किए जाने चाहिए।

Reviewer को check करना चाहिए:

* Terraform logic
* Azure resource configuration
* Network security
* IAM / identity impact
* Security scanning result
* Terraform plan
* Unexpected resource changes

---

# 📊 13. Auditability

Repository में निम्न चीजें traceable होनी चाहिए:

```text
Who
 ↓
Created the change

What
 ↓
Was changed

Why
 ↓
Was it changed

Review
 ↓
Who approved it

Validation
 ↓
Which CI checks passed

Merge
 ↓
When it entered main
```

---

# 🚫 14. Prohibited Practices

निम्न practices prohibited हैं:

```text
❌ Direct push to main

❌ Force push to main

❌ Hard-coded secrets

❌ Unreviewed infrastructure changes

❌ Bypassing security checks

❌ Blind security-check suppression

❌ Manual production changes without change tracking
```

---

# 📋 15. Governance Checklist

| Governance Control       | Status |
| ------------------------ | ------ |
| Main Branch Protection   | ✅      |
| Pull Request Requirement | ✅      |
| Required Review          | 🟡     |
| Required Status Checks   | 🟡     |
| Security Scanning        | ✅      |
| Secret Management        | ✅      |
| Dependency Security      | 🟡     |
| Commit Convention        | ⏳      |
| Change Management        | ⏳      |
| Auditability             | ⏳      |

---

# 🏁 16. Governance Implementation Target

Final repository governance model:

```text
                    GitHub Repository
                           │
                           ↓
                    Protected main
                           │
                    ┌──────┴──────┐
                    ↓             ↓
              Pull Request    No Direct Push
                    │
                    ↓
              Required Review
                    │
                    ↓
              Required CI Checks
                    │
             ┌──────┴──────┐
             ↓             ↓
          Trivy         Terraform
             │             │
             └──────┬──────┘
                    ↓
                  PASS
                    ↓
                  Merge
                    ↓
                   main
```

---

# 📊 17. Phase 20.5 Status

```text
Phase 20.5
     ↓
Repository Governance Policy
     ↓
Documentation
     ↓
Branch Protection
     ↓
PR Governance
     ↓
Security Governance
     ↓
CI/CD Governance
```

**Status:** 🟡 Implementation in progress

---

# 🚀 Next Phase

```text
Phase 20.5
     ↓
Repository Governance Policy
     ↓
Phase 20.6
     ↓
GitHub Organization
     +
Team-Based Access
```

> 🔐 **Security Principle:** Repository Governance का उद्देश्य केवल GitHub settings configure करना नहीं है; इसका उद्देश्य यह सुनिश्चित करना है कि हर infrastructure change **controlled, reviewed, validated और auditable** हो।
