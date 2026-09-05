# 🚀 Phase 20.4 — Dependabot Dependency Security & Automated Updates

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Repository%20Security-181717?style=for-the-badge\&logo=github\&logoColor=white)
![Dependabot](https://img.shields.io/badge/Dependabot-Dependency%20Security-025E8C?style=for-the-badge\&logo=github\&logoColor=white)
![Security](https://img.shields.io/badge/Dependency-Security-success?style=for-the-badge)
![Automation](https://img.shields.io/badge/Automated-Updates-blue?style=for-the-badge)

</p>

> 🎯 **Objective:** Repository में इस्तेमाल होने वाली dependencies की security vulnerabilities को automatically detect करना और जहाँ possible हो वहाँ सुरक्षित dependency updates के लिए automated Pull Requests generate करना।

---

# 📌 1. Phase Overview

Dependabot GitHub repository की dependencies को continuously monitor करता है।

इस Phase में हम:

* Dependency vulnerability alerts enable करेंगे
* Dependabot configuration बनाएँगे
* Automated dependency update Pull Requests configure करेंगे
* Update frequency define करेंगे
* Terraform ecosystem को configure करेंगे
* Open Pull Requests verify करेंगे
* Security alerts verify करेंगे
* Dependency updates को CI pipeline के साथ validate करेंगे

---

# 🏗️ 2. Current Project Context

**Project:** ComSolve Cyberex Azure Landing Zone

**Repository:** `comsolve-cyberex-azure-landing-zone`

**Infrastructure:** Terraform + Microsoft Azure

**CI/CD:** GitHub Actions

**Security Scanning:** Trivy

**Infrastructure Security:** Terraform IaC Security Scanning

---

# 🔍 3. Dependabot क्या करता है?

Dependabot मुख्य रूप से दो important काम करता है:

```text
Repository Dependencies
        ↓
Dependabot Monitoring
        ↓
New Version / Vulnerability Detection
        ↓
Security Alert
        ↓
Automated Pull Request
        ↓
CI Validation
        ↓
Review
        ↓
Merge
```

---

# 🛡️ 4. Dependabot Security का उद्देश्य

Dependency पुरानी होने पर उसमें known vulnerability हो सकती है।

Example:

```text
Current Version
      ↓
Old Dependency
      ↓
Security Vulnerability
      ↓
New Secure Version Available
      ↓
Dependabot Alert
      ↓
Update PR
```

इससे manually हर dependency की version check करने की आवश्यकता कम होती है।

---

# 📁 5. Dependabot Configuration File

Dependabot की configuration repository में इस location पर रखी जाएगी:

```text
.github/
└── dependabot.yml
```

Final structure:

```text
comsolve-cyberex-azure-landing-zone/
│
├── .github/
│   ├── workflows/
│   │   └── terraform-ci.yml
│   │
│   └── dependabot.yml
│
├── docs/
│   └── security-scanning/
│       └── Phase-20.4-Dependabot-Dependency-Security.md
│
├── terraform/
│
└── README.md
```

---

# 🪜 6. Step 01 — .github Folder Check

Repository root से run करें:

```powershell
Get-ChildItem .\.github
```

अगर `.github` already मौजूद है तो नया folder बनाने की आवश्यकता नहीं है।

अगर नहीं है:

```powershell
New-Item -ItemType Directory -Force .\.github
```

---

# 🪜 7. Step 02 — Dependabot Configuration File Create करें

Command:

```powershell
New-Item -ItemType File -Force .\.github\dependabot.yml
```

Check:

```powershell
Get-ChildItem .\.github
```

Expected:

```text
dependabot.yml
workflows
```

---

# 🪜 8. Step 03 — Dependabot Configuration

`dependabot.yml` में शुरुआत में Terraform ecosystem configure करेंगे।

File खोलें:

```powershell
code .\.github\dependabot.yml
```

Configuration:

```yaml
version: 2

updates:

  - package-ecosystem: "terraform"

    directory: "/terraform"

    schedule:
      interval: "weekly"

    open-pull-requests-limit: 5
```

---

# 🧠 9. Configuration समझें

### `version: 2`

Dependabot configuration का schema version है।

```yaml
version: 2
```

---

### `package-ecosystem`

हम Terraform infrastructure maintain कर रहे हैं।

इसलिए:

```yaml
package-ecosystem: "terraform"
```

---

### `directory`

हमारा Terraform root directory:

```text
/terraform
```

इसलिए:

```yaml
directory: "/terraform"
```

---

### `schedule`

Dependency updates weekly check होंगी:

```yaml
schedule:
  interval: "weekly"
```

---

### `open-pull-requests-limit`

एक समय में maximum 5 Dependabot PRs:

```yaml
open-pull-requests-limit: 5
```

इसका उद्देश्य repository में बहुत सारे automated PRs एक साथ आने से बचाना है।

---

# 🪜 10. Step 04 — File Validate करें

PowerShell:

```powershell
Get-Content .\.github\dependabot.yml
```

Expected:

```yaml
version: 2

updates:

  - package-ecosystem: "terraform"

    directory: "/terraform"

    schedule:
      interval: "weekly"

    open-pull-requests-limit: 5
```

---

# 🪜 11. Step 05 — Terraform Dependency Check

हमारे Terraform project में provider configuration check करें:

```powershell
Get-Content .\terraform\providers.tf
```

हमारे project में Azure provider:

```text
hashicorp/azurerm
```

और currently configured version:

```text
5.1.0
```

इसलिए Dependabot future provider updates monitor करने में उपयोगी होगा।

---

# 🪜 12. Step 06 — Git Status Check

अब:

```powershell
git status
```

Expected new files में:

```text
.github/dependabot.yml

docs/security-scanning/Phase-20.4-Dependabot-Dependency-Security.md
```

---

# 🪜 13. Step 07 — YAML Formatting Check

Dependabot configuration में indentation बहुत important है।

Correct:

```yaml
version: 2

updates:
  - package-ecosystem: "terraform"
    directory: "/terraform"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
```

Incorrect indentation से Dependabot configuration fail हो सकती है।

---

# 🪜 14. Step 08 — Commit से पहले Terraform CI Check

Local Terraform directory में:

```powershell
cd .\terraform
```

Run:

```powershell
terraform fmt -check -recursive
```

फिर:

```powershell
terraform validate
```

फिर वापस repository root:

```powershell
cd ..
```

---

# 🪜 15. Step 09 — GitHub पर Push

पहले status:

```powershell
git status
```

फिर:

```powershell
git add .github/dependabot.yml
git add docs/security-scanning/Phase-20.4-Dependabot-Dependency-Security.md
```

फिर:

```powershell
git status
```

Verify करें कि केवल expected files staged हैं।

---

# 🪜 16. Step 10 — Commit

```powershell
git commit -m "feat(security): configure dependabot dependency updates"
```

---

# 🪜 17. Step 11 — Push

Current branch verify:

```powershell
git branch --show-current
```

फिर:

```powershell
git push origin feature/nic-infrastructure
```

---

# 🌐 18. Step 12 — GitHub Repository में Verify करें

GitHub repository खोलें:

```text
.github
    ↓
dependabot.yml
```

File दिखाई देनी चाहिए।

इसके बाद:

```text
Repository
   ↓
Insights / Security
   ↓
Dependabot
```

GitHub UI में उपलब्ध Dependabot security/update options verify करें।

---

# 🔐 19. Step 13 — Dependency Graph

GitHub repository में:

```text
Settings
   ↓
Security
   ↓
Advanced Security
```

जहाँ उपलब्ध हो वहाँ:

```text
Dependency graph
```

enabled होना चाहिए।

Dependency graph repository की dependencies को identify करने में मदद करता है।

---

# 🚨 20. Step 14 — Dependabot Security Alerts

GitHub repository में:

```text
Security
   ↓
Dependabot
   ↓
Alerts
```

यहाँ known vulnerable dependencies के alerts दिखाई दे सकते हैं।

अगर कोई alert नहीं है:

```text
No vulnerabilities detected
```

तो यह भी valid result है।

इसका मतलब यह नहीं कि Dependabot काम नहीं कर रहा।

---

# 🤖 21. Step 15 — Dependabot Update PR

जब supported dependency का नया version available होगा:

```text
New Dependency Version
        ↓
Dependabot
        ↓
Pull Request
        ↓
Terraform CI
        ↓
Trivy
        ↓
Terraform Plan
        ↓
Review
        ↓
Merge
```

हम manually dependency update नहीं करेंगे जब तक कोई specific reason न हो।

---

# 🔐 22. Security + CI Integration

Dependabot का PR हमारे existing CI pipeline से गुजरना चाहिए।

Current flow:

```text
Dependabot PR
      ↓
GitHub Actions
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
PASS / FAIL
```

इससे automated dependency update सीधे production में नहीं जाता।

पहले CI validation होगी।

---

# 🛑 23. Important Security Rule

Dependabot PR को blindly merge नहीं करना है।

Process:

```text
Dependabot PR
      ↓
Review Changes
      ↓
Check Dependency Version
      ↓
Check Release / Security Notes
      ↓
CI Pass
      ↓
Trivy Pass
      ↓
Terraform Plan Pass
      ↓
PR Approval
      ↓
Merge
```

---

# 📊 24. Phase 20.4 Implementation Status

| Control                         | Status |
| ------------------------------- | ------ |
| Dependabot Configuration        | ⏳      |
| Terraform Dependency Monitoring | ⏳      |
| Dependency Update Schedule      | ⏳      |
| Security Alerts                 | ⏳      |
| Automated Update PR             | ⏳      |
| CI Validation                   | ⏳      |
| Trivy Validation                | ⏳      |
| PR Review                       | ⏳      |
| Final Verification              | ⏳      |

---

# 🏁 25. Phase Completion Criteria

Phase 20.4 को complete तब माना जाएगा जब:

```text
.github/dependabot.yml
        ↓
GitHub recognizes configuration
        ↓
Terraform dependency monitoring
        ↓
Dependabot update/security alerts
        ↓
Automated PR
        ↓
GitHub Actions CI
        ↓
Trivy
        ↓
Terraform Plan
        ↓
PR Review
```

successfully establish हो जाए।

---

# 🚀 Next Phase

Phase 20.4 के बाद:

```text
Phase 20.4
     ↓
Dependabot
     ↓
Dependency Security
     ↓
Automated Updates
     ↓
CI Validation
     ↓
Phase 20.5
     ↓
Repository Governance Policy
```

> 🔐 **Security Principle:** Automated dependency updates useful हैं, लेकिन security तभी मजबूत होती है जब हर update को CI validation, security scanning और controlled Pull Request review के through merge किया जाए।


## ❓ प्रश्न — Dependabot Configuration और Workflow Verification

मैंने अपने GitHub Repository में **Dependabot** की सभी आवश्यक settings enable कर दी हैं और `dependabot.yml` configuration भी बनाई है।

GitHub में:

```text
Dependency graph
       ↓
Automatic dependency submission

Dependabot
       ↓
Dependabot alerts
       ↓
Dependabot rules
       ↓
Dependabot security updates
       ↓
Grouped security updates
       ↓
Dependabot version updates
```

इनमें आवश्यक options enable हैं और **Dependabot Rules में 1 rule भी enabled** दिखाई दे रहा है।

मेरी `dependabot.yml` configuration इस प्रकार है:

```yaml
version: 2

updates:
  - package-ecosystem: "terraform"
    directory: "/terraform"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
```

इसके अलावा GitHub Actions में Terraform CI pipeline भी configured है।

लेकिन समस्या यह है कि:

* कोई **Dependabot Alert** दिखाई नहीं दे रहा है।
* कोई **Dependabot Pull Request** भी दिखाई नहीं दे रहा है।
* GitHub Actions में मेरी Terraform CI pipeline की तरह Dependabot की कोई अलग **workflow run** दिखाई नहीं दे रही है।
* इसलिए मुझे समझ नहीं आ रहा कि `dependabot.yml` वास्तव में execute हो रही है या नहीं।
* क्या `dependabot.yml` GitHub Actions workflow की तरह manually या automatically **run** होती है?
* Dependabot की execution/status को GitHub में कहाँ जाकर verify किया जा सकता है?
* `/terraform` directory और `terraform` package ecosystem की configuration सही है या नहीं, यह कैसे verify करें?
* अगर अभी कोई vulnerability या dependency update available नहीं है, तो Dependabot के working होने को practically कैसे verify/test किया जा सकता है?
* Dependabot द्वारा बनाया गया PR आने पर क्या हमारी existing **Terraform CI → Trivy → Terraform Plan** pipeline automatically trigger होगी?

### 🎯 मेरा उद्देश्य

मैं यह confirm करना चाहता हूँ कि **Dependabot सही तरीके से configured और operational है**, भले ही अभी कोई vulnerability alert या dependency update available न हो।


यहाँ एक important distinction है: dependabot.yml खुद GitHub Actions की तरह "Run" नहीं होती। इसलिए Actions में तुम्हारी Terraform CI जैसी run दिखाई नहीं देगी।

तुम्हारे case में 3 चीजें अलग-अलग हैं:

.github/dependabot.yml
        ↓
GitHub Dependabot Service
        ↓
Weekly dependency check
        ↓
Update / Security PR

और:

.github/workflows/terraform-ci.yml
        ↓
GitHub Actions
        ↓
Workflow Run दिखाई देता है
अभी क्या check करना है

Repository में जाओ:

Settings
   ↓
Security
   ↓
Advanced Security
   ↓
Dependabot

फिर repository का:

Insights
   ↓
Dependency graph

देखो।

और सबसे important:

.github/
├── workflows/
│   └── terraform-ci.yml
│
└── dependabot.yml
तुम्हारे dependabot.yml का मतलब

तुमने लिखा है:

version: 2

updates:
  - package-ecosystem: "terraform"
    directory: "/terraform"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5

इसका मतलब Dependabot हर सप्ताह /terraform में dependency updates check करेगा।

अगर कोई update उपलब्ध नहीं है, तो कोई PR बनना जरूरी नहीं है।
अगर कोई vulnerability नहीं है, तो Dependabot alert भी नहीं आएगा।

इसलिए:

Dependabot Enabled       ✅
dependabot.yml मौजूद     ✅
Terraform ecosystem      ✅
Weekly schedule          ✅
Security alerts          0
Update PRs               0

यह अपने-आप में failure नहीं है।

लेकिन तुम्हारे लिए एक और चीज check करनी है

तुमने कहा:

"pipeline run होते हुए नहीं दिख रही"

Dependabot को Terraform CI से confuse मत करो।

जब Dependabot कोई PR बनाएगा, तब तुम्हारा:

Dependabot PR
     ↓
GitHub Actions
     ↓
Terraform CI
     ↓
Trivy
     ↓
Terraform Plan

चल सकता है, अगर तुम्हारी workflow का trigger उस PR/branch को cover करता है।

अगर तुम चाहो तो अगला step हम यही करेंगे: तुम्हारा dependabot.yml और current terraform-ci.yml साथ में verify करके देखेंगे कि Dependabot PR आने पर Terraform CI वास्तव में trigger होगा या नहीं।