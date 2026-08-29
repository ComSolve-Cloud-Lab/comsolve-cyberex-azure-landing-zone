# 🏢 Phase 20.6 — GitHub Organization & Team-Based Access

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Organization-181717?style=for-the-badge\&logo=github\&logoColor=white)

![Teams](https://img.shields.io/badge/Teams-Based-Access-blue?style=for-the-badge)

![RBAC](https://img.shields.io/badge/RBAC-Access%20Control-success?style=for-the-badge)

![Security](https://img.shields.io/badge/Access-Security-orange?style=for-the-badge)

</p>

> 🎯 **Objective:** GitHub repositories को centralized Organization के under manage करना और users को individual repository access देने के बजाय **Team-Based Role-Based Access Control (RBAC)** के through नियंत्रित करना।

---

# 📌 1. Phase Overview

Organization-based model में repositories को एक centralized GitHub Organization के under रखा जाएगा।

```text
GitHub
   ↓
Organization
   ↓
Teams
   ↓
Repositories
   ↓
Role-Based Access
```

इससे repository access centrally manage किया जा सकता है।

---

# 🏗️ 2. Target Architecture

```text
GitHub Organization
        │
        ├── Platform Team
        │       ↓
        │   Infrastructure Repositories
        │
        ├── Security Team
        │       ↓
        │   Security / Compliance
        │
        ├── DevOps Team
        │       ↓
        │   CI/CD + Infrastructure
        │
        └── Developers
                ↓
            Application Repositories
```

---

# 🔐 3. Why Organization?

Individual repository-based access के बजाय Organization model में:

* Centralized repository management
* Team-based permissions
* Standard security policies
* Centralized GitHub Actions governance
* Easier onboarding/offboarding
* Better auditability
* Consistent repository security controls

establish किए जा सकते हैं।

---

# 👥 4. Team-Based Access Model

Users को directly repository में permissions देने के बजाय Teams के through access दिया जाएगा।

```text
User
 ↓
Team
 ↓
Repository
 ↓
Permission
```

Example:

```text
DevOps Engineer
       ↓
DevOps Team
       ↓
Cyberex Repository
       ↓
Write Access
```

---

# 🔑 5. Recommended Teams

Initial organization के लिए:

| Team       | Purpose                     | Access           |
| ---------- | --------------------------- | ---------------- |
| Platform   | Infrastructure Management   | Maintain         |
| DevOps     | CI/CD + Terraform           | Write / Maintain |
| Security   | Security Review             | Read / Write     |
| Developers | Application Development     | Write            |
| Admins     | Organization Administration | Admin            |

> ⚠️ Actual permissions project requirements और least-privilege principle के अनुसार assign किए जाएंगे।

---

# 🛡️ 6. Least Privilege Principle

हर user को केवल उतना access दिया जाएगा जितना उसके काम के लिए आवश्यक है।

```text
Required Access
      ↓
Minimum Permission
      ↓
No Unnecessary Privilege
```

Example:

```text
Developer
   ↓
Write

Security Reviewer
   ↓
Read / Triage

Platform Engineer
   ↓
Maintain

Organization Administrator
   ↓
Admin
```

---

# 🪜 7. Organization Creation

GitHub पर:

```text
GitHub
   ↓
Profile Menu
   ↓
Your organizations
   ↓
New organization
```

Organization create करते समय project/company naming policy follow करें।

Example:

```text
ComSolve-Cloud
```

या organization की official naming convention के अनुसार appropriate name रखें।

---

# 🪜 8. Repository Migration

Existing repository:

```text
comsolve-cyberex-azure-landing-zone
```

Organization के under move किया जा सकता है।

Target:

```text
Organization
      ↓
comsolve-cyberex-azure-landing-zone
```

Migration से पहले:

* Branch protection review करें
* Secrets review करें
* Actions permissions review करें
* Repository collaborators review करें
* CI pipeline verify करें

---

# 👥 9. Team Creation

Organization में:

```text
Organization
    ↓
Teams
    ↓
New Team
```

Teams create करें:

```text
platform
devops
security
developers
```

---

# 🔗 10. Repository Team Access

Team को repository के साथ associate करें:

```text
Organization
     ↓
Teams
     ↓
Team
     ↓
Repositories
     ↓
Add Repository
```

फिर required role assign करें।

---

# 🔐 11. Repository Permission Levels

GitHub repository roles environment के अनुसार use किए जाएंगे।

```text
Read
 ↓
Triage
 ↓
Write
 ↓
Maintain
 ↓
Admin
```

General principle:

```text
Developer
   ↓
Write

Platform
   ↓
Maintain

Security
   ↓
Read / Triage

Repository Administrator
   ↓
Admin
```

---

# 🚫 12. Direct Individual Access

जहाँ possible हो:

```text
User
 ↓
❌ Direct Repository Access
```

के बजाय:

```text
User
 ↓
Team
 ↓
Repository
```

model prefer किया जाएगा।

इससे employee/team changes के समय access management आसान होता है।

---

# 🔄 13. Onboarding Process

New member:

```text
New User
   ↓
Add to Organization
   ↓
Add to Required Team
   ↓
Team Repository Permission
   ↓
Access Granted
```

---

# 🚪 14. Offboarding Process

User organization छोड़ता है:

```text
User
 ↓
Remove from Team
 ↓
Remove Organization Access
 ↓
Review Tokens / SSH Keys
 ↓
Review Repository Access
```

इससे stale access का risk कम होता है।

---

# 🔍 15. Access Review

Periodic access review किया जाएगा।

Check:

```text
Organization Members
        ↓
Teams
        ↓
Repositories
        ↓
Permissions
        ↓
Inactive Users
        ↓
Excessive Privileges
```

---

# 🔐 16. Security Controls

Organization level पर जहाँ available हों:

* Two-factor authentication
* SAML SSO
* IP allow lists
* Member privilege restrictions
* Actions policy
* Repository creation policy
* Secret scanning
* Dependency security
* Branch protection

जैसे controls लागू किए जा सकते हैं।

---

# 🧪 17. Validation

Implementation के बाद verify करें:

```text
Organization
     ↓
Team Exists
     ↓
User Added
     ↓
Repository Connected
     ↓
Correct Permission
     ↓
Access Test
```

Test करें:

```text
Developer → Can create PR
Developer → Cannot bypass protection

Security → Can review security findings

Platform → Can maintain infrastructure

Admin → Organization administration
```

---

# 📊 18. Governance Integration

Phase 20.1–20.6 का final model:

```text
Organization
      ↓
Teams
      ↓
Repository
      ↓
Protected main
      ↓
Pull Request
      ↓
Required Review
      ↓
Required CI
      ↓
Trivy Security Scan
      ↓
Terraform Validation
      ↓
Terraform Plan
      ↓
Merge
```

---

# 📋 19. Phase 20 Final Governance Model

| Control                  | Status |
| ------------------------ | ------ |
| Branch Protection        | ✅      |
| Pull Request Requirement | ✅      |
| Required Status Checks   | 🟡     |
| Secret Scanning          | 🟡     |
| Dependabot               | 🟡     |
| Governance Policy        | 🟡     |
| GitHub Organization      | ⏳      |
| Team-Based Access        | ⏳      |
| Least Privilege          | ⏳      |
| Access Review            | ⏳      |

---

# 🏁 20. Phase Completion Criteria

Phase 20.6 complete तब माना जाएगा जब:

```text
GitHub Organization
        ↓
Teams Created
        ↓
Repository Added
        ↓
Team Permissions Configured
        ↓
Individual Access Reviewed
        ↓
Least Privilege Applied
        ↓
Access Tested
```

successfully complete हो जाए।

---

# 🎯 Final Security Architecture

```text
                 GitHub Organization
                         │
              ┌──────────┼──────────┐
              ↓          ↓          ↓
           DevOps     Security   Developers
              │          │          │
              └──────────┼──────────┘
                         ↓
                  Cyberex Repository
                         ↓
                  Protected main
                         ↓
                    Pull Request
                         ↓
                  Required Review
                         ↓
                   Required CI
                         ↓
                     Trivy
                         ↓
                 Terraform Plan
                         ↓
                       Merge
```

> 🔐 **Security Principle:** Access हमेशा **Need-to-Know + Least Privilege + Team-Based RBAC** के आधार पर दिया जाना चाहिए। Organization का उद्देश्य केवल repositories को एक जगह रखना नहीं, बल्कि access, security और governance को centrally control करना है।
