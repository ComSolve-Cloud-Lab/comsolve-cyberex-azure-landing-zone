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

🏢 STEP 7.1 — GitHub Organization क्या है?

अभी तुम्हारा repository सीधे personal account के अंदर है:

GitHub Personal Account
        ↓
comsolve-cyberex-azure-landing-zone

Organization बनाने के बाद structure ऐसा होगा:

GitHub Organization
        ↓
ComSolve-Cloud
        ↓
Repositories
        ├── comsolve-cyberex-azure-landing-zone
        ├── project-02
        └── project-03

Organization का फायदा है कि Repository, Teams, Permissions, Security Policies और Access Management को company/project level पर manage कर सकते हैं।

🪜 STEP 7.2 — Organization Creation Page खोलें

GitHub में अपने profile picture पर click करो:

GitHub
   ↓
Profile Menu
   ↓
Your organizations
   ↓
New organization

या GitHub में Create an organization option से organization creation page खोल सकते हो।

# 🏷️ STEP 7.3 — Organization Plan चुनें

GitHub organization बनाते समय GitHub तुमसे plan पूछ सकता है।

Learning / Lab / Demo project के लिए पहले Free organization पर्याप्त है।

Concept:

Organization
      ↓
Free Plan
      ↓
Repositories
      ↓
Teams
      ↓
Access Control

बाद में business requirements के अनुसार plan upgrade किया जा सकता है।

🏢 STEP 7.4 — Organization Name तय करें

Organization name बहुत carefully choose करना चाहिए क्योंकि यह GitHub URL का हिस्सा बनेगा।

Example:

ComSolve-Cloud

Result:

github.com/ComSolve-Cloud

लेकिन अगर यह actual company repository है, तो company की official naming policy follow करना बेहतर है।

Naming के लिए मेरा सुझाव

अगर यह तुम्हारा personal learning/lab organization है:

ComSolve-Cloud-Lab

अगर company-level organization है:

ComSolve-Cloud

या company की approved official name use करो।

👤 STEP 7.5 — Organization Owner

Organization बनाने वाला account automatically organization का Owner बन जाता है।

Structure:

Organization
      ↓
Owner
      ↓
Teams
      ↓
Members
      ↓
Repositories

Owner permission बहुत powerful होती है, इसलिए production environment में Owners की संख्या minimum रखना अच्छा security practice है।

# 👥 STEP 7.6 — Members को तुरंत Add करना जरूरी नहीं

Organization create करते समय GitHub members invite करने का option दे सकता है।

अभी learning/initial setup है तो:

Organization Created
        ↓
Owner = आपका account
        ↓
Members = बाद में

पहले organization और repository governance properly configure करना बेहतर है।

# 🔐 STEP 7.7 — Organization Creation के बाद क्या मिलेगा?

Organization बनने के बाद तुम्हारे पास centralized management होगा:

ComSolve-Cloud
      │
      ├── People
      │
      ├── Teams
      │
      ├── Repositories
      │
      ├── Settings
      │
      └── Security

फिर हम Teams बनाएँगे:

ComSolve-Cloud
       ↓
Teams
       ├── DevOps
       ├── Security
       └── Developers

और repositories पर team-based permissions देंगे।

⚠️ अभी एक Important बात

अपने current comsolve-cyberex-azure-landing-zone repository को अभी Organization में transfer मत करना।

पहले:

Organization Create
        ↓
Organization Settings
        ↓
Teams Create
        ↓
Permissions Design
        ↓
Repository Transfer
        ↓
Repository Access
        ↓
Final Testing

इससे existing repository और तुम्हारी current feature/nic-infrastructure workflow unnecessarily disturb नहीं होगी।

# 🧪 STEP 7.8 — Organization Creation के बाद Verification

Organization बनने के बाद यह check करो:

Your Organizations
       ↓
ComSolve-Cloud
       ↓
People
       ↓
Repositories
       ↓
Settings

और verify करो कि तुम्हारा account:

Role: Owner

दिखा रहा है।

🎯 अभी तुम्हारा practical target
Create Organization
        ↓
Organization Name
        ↓
Free Plan
        ↓
Your Account = Owner
        ↓
Organization Successfully Created ✅

बस अभी Organization create करो। Repository transfer और Teams हम उसके बाद अलग step में करेंगे।



हाँ भाई, Organization successfully create हो गया है ✅

तुम अभी:

ComSolve-Cloud-Lab

के Organization Overview में हो।

अब अगला काम Repository transfer करना नहीं है। पहले Organization की basic governance और Teams तैयार करेंगे।

---

🪜 STEP 01 — Member Permissions पहले configure करो

तुम्हारे screen पर यह option दिख रहा है:

Customize members' permissions

उस पर click करो।

Path:

ComSolve-Cloud-Lab
        ↓
Settings
        ↓
Member privileges
        ↓
Base permissions

यहाँ GitHub members के लिए default permission दिखाई जाएगी।

अगर अभी कोई दूसरा member नहीं है, तो भी setting configure कर सकते हो।

हमारा target ideally:

Base permissions
        ↓
Read

मतलब future में organization में कोई member add होने पर उसे automatically repository का unnecessary write/admin access नहीं मिलेगा।

🪜 STEP 02 — अभी Team मत बनाना

पहले यह Base Permission setting देखो।

उस page पर जो options दिख रहे हैं उनका screenshot/text भेज देना। फिर मैं उसी screen से exactly क्या select करना है बताऊँगा।

अभी सिर्फ:

Settings
   ↓
Member privileges
   ↓
Base permissions

तक जाओ।

-----


🔐 STEP 01 — Base permissions

ऊपर Base permissions में:

Read ✅

रखो।

इसका मतलब: organization का normal member repositories को default रूप से Read-only access पाएगा। जरूरत होने पर Team/Repository level पर Write/Triage/Admin दिया जा सकता है।

🔐 STEP 02 — Repository Creation

यहाँ:

Public      ❌
Private     ❌

दोनों disable रखना बेहतर है।

मतलब कोई normal member अपनी तरफ से organization में नया repository नहीं बना पाएगा।

Repository creation केवल controlled/admin process से होगा।

🔐 STEP 03 — Repository Forking
Allow forking of private repositories

इसे:

❌ OFF

रखो।

Private repository का fork बाहर/दूसरे location में जाने का risk कम होगा।

🔐 STEP 04 — App Access Requests

Select:

Members only

इससे organization के members apps request कर सकते हैं, लेकिन outside collaborators नहीं।

🔐 STEP 05 — GitHub Apps

यह option:

Allow repository admins to install GitHub Apps

इसे:

❌ OFF

रखना मैं recommend करूँगा।

पहले organization owner/admin review करे, फिर GitHub App install हो।

🔐 STEP 06 — Admin Repository Permissions

इन तीनों को OFF रखो:

Repository visibility change       ❌ OFF

Repository deletion and transfer   ❌ OFF

Issue deletion                     ❌ OFF

इससे repository admin अकेले:

Repository
   ↓
Visibility change
   ↓
Delete
   ↓
Transfer

नहीं कर पाएगा। ऐसे sensitive actions Owner के control में रहेंगे।

🔐 STEP 07 — Branch Renames
Allow repository administrators
to rename branches protected by organization rules

इसे:

❌ OFF

रखो।

👥 STEP 08 — Team Creation

सबसे नीचे:

Allow members to create teams

इसे भी:

❌ OFF

रखो।

क्योंकि Team creation भी centrally controlled होना चाहिए।

फिर हम खुद controlled Teams बनाएँगे:

ComSolve-Cloud-Lab
        ↓
Teams
   ├── DevOps
   ├── Security
   └── Developers
🎯 तुम्हारी अभी पूरी setting
Base Permission                    → Read
Public Repository Creation         → OFF
Private Repository Creation        → OFF
Private Repository Forking         → OFF
App Access Requests                → Members only
Repository Admin GitHub Apps       → OFF

Visibility Change                  → OFF
Repository Delete/Transfer         → OFF
Issue Deletion                     → OFF
Branch Rename                      → OFF
Member Team Creation               → OFF

अब नीचे जाकर Save/Update changes करो। इसके बाद अगला practical काम Team Creation + Team-based Access होगा।


-------

🛡️ Security Model

हमारा organization governance model:

                    GitHub Organization
                           │
                           ↓
                  ┌──────────────────┐
                  │   Organization   │
                  │      Owner       │
                  └────────┬─────────┘
                           │
              ┌────────────┴────────────┐
              ↓                         ↓
           Teams                  Repositories
              │                         │
              ↓                         ↓
       Controlled Access        Protected Resources
              │                         │
              └────────────┬────────────┘
                           ↓
                    Least Privilege


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


