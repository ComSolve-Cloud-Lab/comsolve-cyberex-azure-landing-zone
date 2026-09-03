# 👥 Phase 20.8 — Team Creation, Team-Based Repository Access & RBAC Testing

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Organization-181717?style=for-the-badge\&logo=github\&logoColor=white)
![Teams](https://img.shields.io/badge/GitHub-Teams-blue?style=for-the-badge)
![RBAC](https://img.shields.io/badge/RBAC-Role%20Based%20Access%20Control-success?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-Least%20Privilege-red?style=for-the-badge)
![Repository Governance](https://img.shields.io/badge/Repository-Governance-orange?style=for-the-badge)

</p>

> 🎯 **Objective:** GitHub Organization `ComSolve-Cloud-Lab` में centralized **Teams, Repository Access और RBAC (Role-Based Access Control)** implement करना ताकि developers, DevOps engineers और administrators को केवल required repositories और required permissions ही मिलें।

---

# 🏢 Organization

**Organization Name:**

```text
ComSolve-Cloud-Lab
```

Organization में repository permissions को individual users के बजाय **Teams** के माध्यम से manage किया जाएगा।

Recommended architecture:

```text
Organization
      ↓
Teams
      ↓
Team Members
      ↓
Repository Access
      ↓
Role / Permission
```

---

# 🔐 RBAC Model

हमारा access-control model:

```text
User
  ↓
Team
  ↓
Repository
  ↓
Permission Level
```

उदाहरण:

```text
Developer
    ↓
DevOps-Developers Team
    ↓
comsolve-cyberex-azure-landing-zone
    ↓
Write
```

इससे future में user add/remove करना आसान रहेगा।

---

# 👥 STEP 01 — Team Structure Design

Organization के लिए initial team structure:

| Team               | Purpose                                 | Recommended Access |
| ------------------ | --------------------------------------- | ------------------ |
| `DevOps-Admins`    | Senior DevOps / Admin users             | Admin              |
| `DevOps-Engineers` | DevOps implementation                   | Maintain           |
| `Developers`       | Application / Infrastructure developers | Write              |
| `Security`         | Security / Audit users                  | Read               |
| `Read-Only`        | Management / Review users               | Read               |

### Recommended hierarchy

```text
ComSolve-Cloud-Lab
│
├── DevOps-Admins
│
├── DevOps-Engineers
│
├── Developers
│
├── Security
│
└── Read-Only
```

> 🔐 **Principle:** Team को business responsibility के अनुसार बनाया जाए, individual user के नाम पर नहीं।

---

# 👥 STEP 02 — Create DevOps-Admins Team

GitHub में जाएँ:

```text
ComSolve-Cloud-Lab
        ↓
Teams
        ↓
New team
```

Team Name:

```text
DevOps-Admins
```

### Description

```text
Organization administrators responsible for DevOps platform governance, repository administration and CI/CD security.
```

### Visibility

Recommended:

```text
Visible
```

Team creation के बाद:

```text
DevOps-Admins
        ↓
Add Members
```

Required administrative users को add करें।

---

# 👥 STEP 03 — Create DevOps-Engineers Team

Create another team:

```text
Team Name:

DevOps-Engineers
```

Description:

```text
DevOps engineers responsible for infrastructure, Terraform, CI/CD pipelines and cloud automation.
```

Recommended visibility:

```text
Visible
```

---

# 👥 STEP 04 — Create Developers Team

Create:

```text
Developers
```

Description:

```text
Application and infrastructure developers requiring controlled repository write access.
```

Recommended visibility:

```text
Visible
```

---

# 👥 STEP 05 — Create Security Team

Create:

```text
Security
```

Description:

```text
Security and compliance team responsible for security review, audit and repository monitoring.
```

Recommended visibility:

```text
Visible
```

---

# 👥 STEP 06 — Create Read-Only Team

Create:

```text
Read-Only
```

Description:

```text
Users requiring read-only access for management, audit and review activities.
```

Recommended visibility:

```text
Visible
```

---

# 🔑 STEP 07 — Repository Access Matrix

Target repository:

```text
comsolve-cyberex-azure-landing-zone
```

Recommended access:

| Team               | Permission |
| ------------------ | ---------- |
| `DevOps-Admins`    | Admin      |
| `DevOps-Engineers` | Maintain   |
| `Developers`       | Write      |
| `Security`         | Read       |
| `Read-Only`        | Read       |

### Access model

```text
                         Repository
                              │
             ┌────────────────┼────────────────┐
             │                │                │
             ↓                ↓                ↓
      DevOps-Admins    DevOps-Engineers    Developers
          Admin             Maintain           Write
             │                │                │
             └────────────────┼────────────────┘
                              │
                     comsolve-cyberex
                              │
                    ┌─────────┴─────────┐
                    ↓                   ↓
                Security            Read-Only
                  Read                  Read
```

---

# 🏗️ Final Architecture

हमारा final structure:

```text
                    ComSolve-Cloud-Lab
                           │
            ┌──────────────┴──────────────┐
            │                             │
          Teams                      Repositories
            │                             │
   ┌────────┼────────┐                    │
   │        │        │                    │
   ↓        ↓        ↓                    ↓
Admins   DevOps   Developers      Cyberex Landing Zone
   │        │        │                    │
 Admin   Maintain   Write                 │
   │        │        │                    │
   └────────┴────────┘                    │
            │                             │
            ↓                             ↓
         Members                    Branch Protection
                                          │
                                          ↓
                                     Pull Request
                                          │
                                          ↓
                                     CI/CD Checks
```

---



# 📊 STEP 17 — Final RBAC Matrix

| Team               | Repository Permission | Purpose                   |
| ------------------ | --------------------- | ------------------------- |
| `DevOps-Admins`    | Admin                 | Repository Administration |
| `DevOps-Engineers` | Maintain              | DevOps / Infrastructure   |
| `Developers`       | Write                 | Development               |
| `Security`         | Read                  | Security / Audit          |
| `Read-Only`        | Read                  | Review / Management       |

Final model:

```text
                    Repository
                         │
       ┌─────────────────┼─────────────────┐
       │                 │                 │
       ↓                 ↓                 ↓
 DevOps-Admins    DevOps-Engineers    Developers
     Admin             Maintain          Write
       │                 │                 │
       └─────────────────┼─────────────────┘
                         │
                  Cyberex Landing Zone
                         │
                  ┌──────┴──────┐
                  ↓             ↓
              Security      Read-Only
                 Read           Read
```

---

# 🚀 Organization Repository Setup
<p align="center">

</p>

🎯 Objective: ComSolve-Cloud-Lab Organization में existing comsolve-cyberex-azure-landing-zone repository को लाना और उसके बाद Teams के माध्यम से controlled RBAC (Role-Based Access Control) implement करना।

# 🧠 पहले समझो — अभी Problem क्या है?

हमारा Organization:

ComSolve-Cloud-Lab

अभी बनाया गया है।

लेकिन Organization में:

```text
Repositories
    ↓
0 repositories
```
हैं।

इसलिए जब Team में जाकर:

```text
Team
   ↓
Repositories
```
देखते हैं तो:

This team doesn’t have any repositories.

आ रहा है।

इसका मतलब

Team में कोई problem नहीं है।

Problem सिर्फ यह है:

```text
Organization
      ↓
No Repository
      ↓
Team को क्या assign करें?
```
इसलिए पहले:

```text
Repository
      ↓
Organization
```
करना है।

फिर:

```text

Organization Repository
      ↓
Team
      ↓
Permission

करेंगे।
```
---

# 🏗️ हमारा Existing Repository

हमारा existing project repository है:

comsolve-cyberex-azure-landing-zone

इसमें हमारा:

Terraform
Azure
GitHub Actions
CI/CD
Security Scanning
Landing Zone
Documentation

का पूरा project है।

इसलिए नया blank repository बनाने की जरूरत नहीं है।

हम existing repository को Organization में transfer करेंगे।

---

# 🔄 STEP 01 — Existing Repository को Organization में Transfer करना

अपने existing GitHub repository पर जाएँ:

comsolve-cyberex-azure-landing-zone

फिर:

```text
Repository
    ↓
Settings
    ↓
General
```
नीचे scroll करें।

आपको section मिलेगा:

*** Danger Zone ***

इसके अंदर:

*** Transfer ownership ***

option होगा।

---

### ⚠️ STEP 02 — Transfer Ownership ###

Transfer ownership पर click करें।

GitHub आपसे destination पूछेगा।

Destination में:

ComSolve-Cloud-Lab

select करें।

Repository name confirm करने के लिए GitHub कुछ इस प्रकार पूछ सकता है:

comsolve-cyberex-azure-landing-zone

इसे exactly enter करें।

फिर:

Transfer

confirm करें।

---

# 🧠 Transfer करने से क्या होगा?

पहले:

```text

Personal GitHub Account
        │
        └── comsolve-cyberex-azure-landing-zone
```
Transfer के बाद:
```text
ComSolve-Cloud-Lab
        │
        └── comsolve-cyberex-azure-landing-zone
```
यानी repository अब Organization-owned होगी।

---

# 🔐 STEP 03 — Transfer के बाद Verify करो

Organization में जाएँ:
```text
ComSolve-Cloud-Lab
    ↓
Repositories
```
अब expected:

1 repository

और दिखाई देना चाहिए:

*** comsolve-cyberex-azure-landing-zone ***

अब हमारा architecture बन गया:
```text
ComSolve-Cloud-Lab
        │
        └── comsolve-cyberex-azure-landing-zone
```
---

# ⚠️ STEP 04 — Transfer के बाद Important Checks

Repository transfer के बाद तुरंत ये चीजें verify करनी हैं:

- ☐ Repository visible
- ☐ Branches available
- ☐ main branch available
- ☐ docs folder available
- ☐ terraform folder available
- ☐ .github/workflows available
- ☐ GitHub Actions workflows available
- ☐ Secrets available / correctly configured
- ☐ Environments available
- ☐ Branch protection/rules available

विशेष रूप से हमारे project में:

*** .github/ ***
*** terraform/ ***
*** docs/ ***
*** README.md ***

* verify करना है। *
---

# 🔐 STEP 05 — GitHub Actions Check

क्योंकि हमारा project GitHub Actions use करता है:
```text
GitHub
   ↓
GitHub Actions
   ↓
Terraform
   ↓
Azure
```

इसलिए transfer के बाद:
```text
Repository
    ↓
Actions
```
में जाकर workflows check करें।

Expected:

Terraform CI

या हमारे configured workflow का नाम दिखाई देगा।

---

# 🔑 STEP 06 — Azure OIDC Check

हमारे project में Azure authentication के लिए:

```text
GitHub Actions
       ↓
OIDC
       ↓
Microsoft Entra ID
       ↓
Azure
```
use हो रहा है।

`Repository transfer के बाद Azure OIDC configuration को verify करना जरूरी है क्योंकि GitHub repository identity में organization/repository context आता है।`

Check:

```text

Azure
   ↓
Microsoft Entra ID
   ↓
App Registration
   ↓
Federated Credentials
```
और GitHub repository reference verify करें।

Expected repository:

**ComSolve-Cloud-Lab/comsolve-cyberex-azure-landing-zone**

`⚠️ अगर existing federated credential पुराने personal repository path पर बना है, तो उसे update करना पड़ेगा।`

---
# अभी सिर्फ यह करो:

Personal GitHub
      ↓
comsolve-cyberex-azure-landing-zone
      ↓
Settings
      ↓
General
      ↓
Danger Zone
      ↓
Transfer ownership
      ↓
ComSolve-Cloud-Lab

Transfer के बाद Organization में Repositories = 1 दिखना चाहिए।

फिर हम Team में जाकर repository assign करेंगे।

🔐 Security Principle: पहले resource (Repository) को Organization में centralized control में लाओ, फिर Team-based RBAC से access दो। Empty Team में repository assign नहीं हो सकती क्योंकि Organization में अभी कोई repository मौजूद ही नहीं है।


---

# 🔐👥 STEP 08 — Assign Team Repository Access

अब Team में Repository Assign करो

अब पहले वाली problem solve हो जाएगी।

GitHub में जाएँ:

```text
Organization
    ↓
Teams
    ↓
Select Team
    ↓
Repositories
    ↓
Add Repository
```

Repository:

```text
comsolve-cyberex-azure-landing-zone
```

फिर required permission select करें।

---

# 👥 same process for — DevOps-Engineers Team

अब:

```text

Teams
    ↓
DevOps-Engineers
    ↓
Repositories
    ↓
Add repository
```

Select:

`comsolve-cyberex-azure-landing-zone`

`Permission:`
`Admin`

---

## DevOps-Admins

```text
Repository:
comsolve-cyberex-azure-landing-zone

Permission:
Admin
```

---

## DevOps-Engineers

```text
Repository:
comsolve-cyberex-azure-landing-zone

Permission:
Maintain
```

---

## Developers

```text
Repository:
comsolve-cyberex-azure-landing-zone

Permission:
Write
```

---

## 🛡️ Security

```text
Repository:
comsolve-cyberex-azure-landing-zone

Permission:
Read
```

---

## 👀 Read-Only

```text
Repository:
comsolve-cyberex-azure-landing-zone

Permission:
Read
```

---

# 🔐 Final RBAC Architecture

अब हमारा actual setup ऐसा होगा:
```text
                 ComSolve-Cloud-Lab
                         │
                         ↓
          comsolve-cyberex-azure-landing-zone
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ↓                ↓                ↓
 DevOps-Admins     DevOps-Engineers   Developers
     Admin              Maintain          Write
        │                │                │
        └────────────────┼────────────────┘
                         │
                 ┌───────┴───────┐
                 ↓               ↓
              Security       Read-Only
                Read             Read
```

---
# 🧠 STEP 09 — Understand Permission Levels

GitHub repository roles को इस तरह समझें:

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

### Read

User:

```text
View Code
View Issues
View Repository
```

कर सकता है।

---

### Write

User additional development activities कर सकता है:

```text
Push Code
Create Branch
Create PR
```

लेकिन repository administration नहीं।

---

### Maintain

Repository को manage करने के लिए broader permissions मिलती हैं, लेकिन full administrative control नहीं।

Suitable:

```text
DevOps Engineers
Repository Maintainers
```

---

### Admin

Full repository administration.

Suitable:

```text
Organization Admins
Senior DevOps
Repository Owners
```

> ⚠️ **Admin permission केवल trusted users को दें।**

---

# 🔐 STEP 10 — Avoid Direct User Permissions

Preferred model:

```text
❌ User
      ↓
Repository

✅ User
      ↓
Team
      ↓
Repository
```

### गलत approach

```text
Shrikant → Write
Amit → Maintain
Rahul → Read
```

### सही approach

```text
DevOps-Engineers
        ↓
Maintain
        ↓
Repository

Members:
Shrikant
Amit
Rahul
```

इससे access management centralized रहता है।

---

# 🔄 STEP 11 — User Lifecycle Management

जब नया employee join करे:

```text
New User
    ↓
Add to Organization
    ↓
Add to Required Team
    ↓
Team automatically provides Repository Access
```

जब employee project से remove हो:

```text
Remove User from Team
        ↓
Repository Access Removed
```

इससे प्रत्येक repository में manually permissions बदलने की जरूरत कम होती है।

---

# 🔐 STEP 12 — Nested Team Consideration

Future में team hierarchy बनाई जा सकती है:

```text
Engineering
     │
     ├── DevOps-Engineers
     │
     └── Developers
```

लेकिन initial implementation में unnecessary nested teams avoid करें।

पहले simple structure रखें:

```text
DevOps-Admins
DevOps-Engineers
Developers
Security
Read-Only
```

---

# 🧪 STEP 13 — RBAC Testing

Team permissions configure करने के बाद access test करें।

Testing matrix:

| Test                                     | Expected Result |
| ---------------------------------------- | --------------- |
| Admin can manage repository              | ✅               |
| DevOps Engineer can maintain repository  | ✅               |
| Developer can push code                  | ✅               |
| Security can view repository             | ✅               |
| Read-Only can view repository            | ✅               |
| Read-Only can push code                  | ❌               |
| Security can push code                   | ❌               |
| Developer can change repository settings | ❌               |
| Developer can delete repository          | ❌               |

---

# 🧪 STEP 14 — Read-Only Test

`Read-Only` team के test user से repository open करें:

```text
comsolve-cyberex-azure-landing-zone
```

Verify:

```text
Repository visible
        ↓
Code readable
        ↓
Files accessible
        ↓
Push permission unavailable
```

Expected:

```text
✅ Read
❌ Write
❌ Maintain
❌ Admin
```

---

# 🧪 STEP 15 — Security Team Test

Security team member से verify करें:

```text
Repository
    ↓
Read Access
```

Expected:

```text
View Repository
View Code
View PRs
View Issues
```

लेकिन:

```text
❌ Push
❌ Repository Administration
```

---

# 🧪 STEP 16 — Developer Test

Developer account से test करें:

```text
Create Branch
      ↓
Modify Code
      ↓
Push Branch
      ↓
Create Pull Request
```

Expected:

```text
✅ Write operations
✅ Pull Request creation
❌ Repository Administration
❌ Repository deletion
```

---

# 🧪 STEP 17 — DevOps Engineer Test

DevOps Engineer team member से verify करें:

```text
Repository
      ↓
Maintain
```

Expected:

```text
✅ Repository maintenance
✅ CI/CD related management where permitted
✅ Branch / PR management according to repository rules
❌ Organization ownership
❌ Organization-wide administration
```

---

# 🔐 STEP 18 — Branch Protection + Team RBAC

Previous phase में configured branch protection को Team RBAC के साथ combine करें।

Security model:

```text
Developer
    ↓
Write
    ↓
Feature Branch
    ↓
Pull Request
    ↓
Required Checks
    ↓
Code Review
    ↓
Protected main
```

Developer को directly:

```text
Developer
    ↓
main
    ↓
Direct Push
```

नहीं करना चाहिए।

---

# 🛡️ STEP 19 — Complete Access Control Architecture

Final architecture:

```text
                    ComSolve-Cloud-Lab
                            │
                            ↓
                    Organization Governance
                            │
              ┌─────────────┴─────────────┐
              │                           │
            Teams                    Repositories
              │                           │
      ┌───────┼────────┐                  │
      │       │        │                  │
      ↓       ↓        ↓                  ↓
   Admins   DevOps   Developers     Cyberex Landing Zone
      │       │        │                  │
      │       │        │                  │
     Admin  Maintain  Write               │
      │       │        │                  │
      └───────┼────────┘                  │
              │                           │
          Security ───────────────→ Read  │
              │                           │
        Read-Only ───────────────→ Read   │
                                          │
                                          ↓
                                  Branch Protection
                                          ↓
                                   Required Checks
                                          ↓
                                        PR Review
```

---

# 🔐 STEP 20 — Least Privilege Validation

हर team के लिए पूछें:

```text
क्या इस team को यह permission वास्तव में चाहिए?
```

अगर answer:

```text
NO
```

तो permission remove करें।

Recommended principle:

```text
Minimum Required Access
          ↓
Business Requirement
          ↓
Team Assignment
          ↓
Repository Permission
```

---

# 📊 RBAC Access Matrix

| Control                |           Admins |  DevOps | Developers | Security | Read-Only |
| ---------------------- | ---------------: | ------: | ---------: | -------: | --------: |
| View Code              |                ✅ |       ✅ |          ✅ |        ✅ |         ✅ |
| Push Code              |                ✅ |       ✅ |          ✅ |        ❌ |         ❌ |
| Create PR              |                ✅ |       ✅ |          ✅ |        ❌ |         ❌ |
| Repository Maintenance |                ✅ |       ✅ |          ❌ |        ❌ |         ❌ |
| Repository Settings    |                ✅ | Limited |          ❌ |        ❌ |         ❌ |
| Repository Admin       |                ✅ |       ❌ |          ❌ |        ❌ |         ❌ |
| Delete Repository      |       Controlled |       ❌ |          ❌ |        ❌ |         ❌ |
| Organization Admin     | Owner-controlled |       ❌ |          ❌ |        ❌ |         ❌ |

---

# 🧾 STEP 21 — Documentation / Evidence

RBAC implementation के evidence के लिए screenshots/documentation maintain करें:

```text
01-Organization-Teams.png
02-DevOps-Admins.png
03-DevOps-Engineers.png
04-Developers.png
05-Security-Team.png
06-Read-Only-Team.png
07-Repository-Team-Access.png
08-RBAC-Testing.png
```

Evidence का उद्देश्य:

```text
Configuration
     ↓
Access Assignment
     ↓
Validation
     ↓
Audit Evidence
```

---

# 📋 Implementation Status

| Control                 | Status      |
| ----------------------- | ----------- |
| Organization Created    | ✅ Completed |
| Base Permissions        | ✅ Completed |
| Repository Governance   | ✅ Completed |
| Team Structure Designed | ✅ Completed |
| DevOps-Admins Team      | ⬜ Pending   |
| DevOps-Engineers Team   | ⬜ Pending   |
| Developers Team         | ⬜ Pending   |
| Security Team           | ⬜ Pending   |
| Read-Only Team          | ⬜ Pending   |
| Repository Team Access  | ⬜ Pending   |
| RBAC Testing            | ⬜ Pending   |
| Evidence Collection     | ⬜ Pending   |

---

# 🚀 Phase Completion Criteria

Phase तब complete माना जाएगा जब:

```text
☐ Required Teams Created
☐ Members Added to Correct Teams
☐ Repository Assigned to Teams
☐ Correct Permission Level Assigned
☐ Direct User Permissions Avoided
☐ Read-Only Access Tested
☐ Developer Write Access Tested
☐ DevOps Maintain Access Tested
☐ Admin Access Validated
☐ Unauthorized Actions Tested
☐ Evidence Screenshots Captured
```

---

# 🚀 Next Phase

```text
Phase 20.6.2
      ↓
Team Creation
      ↓
Team-Based Repository Access
      ↓
RBAC Testing
      ↓
✅ Complete
      ↓
Phase 20.6.3
      ↓
Organization Security Validation
      ↓
Audit & Governance Verification
```

> 🔐 **Security Principle:** Organization में default access हमेशा minimum रखें और additional permissions केवल documented business requirement के आधार पर assign करें।

> 🏢 **Governance Principle:** Repository access को individual users के बजाय Teams के माध्यम से manage करना centralized RBAC, easier onboarding/offboarding और बेहतर auditability प्रदान करता है।
