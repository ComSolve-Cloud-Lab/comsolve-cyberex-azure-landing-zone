# 🛡️ Phase 15 — Security Tool Troubleshooting & Findings

<p align="center">

![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Checkov](https://img.shields.io/badge/Checkov-Security%20Findings-success?style=for-the-badge)
![Trivy](https://img.shields.io/badge/Trivy-Misconfiguration%20Scan-1904DA?style=for-the-badge&logo=trivy&logoColor=white)
![Security](https://img.shields.io/badge/Security-Troubleshooting-red?style=for-the-badge)
![DevSecOps](https://img.shields.io/badge/DevSecOps-Security%20Analysis-orange?style=for-the-badge)

</p>

> इस Phase का focus **Checkov और Trivy को install करना नहीं**, बल्कि security scanning के दौरान आए errors को पढ़ना, समझना, root cause identify करना और सही तरीके से troubleshoot करना है।

---

# 🎯 Phase Objective

Phase 14 में हमने security tools को project में introduce किया था।

Phase 15 में हमारा focus रहेगा:

```text
Security Tool
      ↓
Scan
      ↓
Error / Warning / Finding
      ↓
Log पढ़ना
      ↓
Root Cause समझना
      ↓
Fix / Workaround
      ↓
Re-Scan
      ↓
PASS
```

इस Phase में हमने दो important real-world situations देखीं:

🔎 Checkov ने Terraform में security findings detect कीं
🐳 Trivy installation के दौरान Windows PATH issue आया


# 🧭 Phase 15 — Troubleshooting Mindset

Security tool का output देखकर तुरंत code बदलना सही approach नहीं है।

पहले हमेशा यह समझें:

WHAT?
↓
क्या error/finding आया?

WHERE?
↓
किस file/resource पर आया?

WHY?
↓
यह क्यों आया?

RISK?
↓
इससे security risk क्या है?

FIX?
↓
इसे कैसे resolve करना है?

VERIFY?
↓
Fix के बाद scan क्या कहता है?

यही approach real DevSecOps troubleshooting में सबसे ज्यादा useful है।

🔎 Issue 01 — Checkov Scan Failed
🧪 Command Used

हमने Terraform directory के अंदर यह command run की:

checkov -d .

Output:

terraform scan results:

Passed checks: 5
Failed checks: 5
Skipped checks: 0

इसका मतलब:

Total security checks = 10

PASS   = 5
FAIL   = 5
SKIP   = 0

⚠️ इसका मतलब Terraform syntax गलत है ऐसा जरूरी नहीं है।


यह security policy failure है।

🔍 Step 01 — सबसे पहले Failed Check पढ़ें

Output में सबसे important information:

CKV2_AZURE_31:
"Ensure VNET subnet is configured with a Network Security Group (NSG)"

यह हमारा actual security finding था।

Checkov हमें बता रहा है:

VNET subnet के साथ Network Security Group (NSG) configured होना चाहिए।

📍 Step 02 — Resource Identify करें

Output:

FAILED for resource:
module.subnets.azurerm_subnet.Subnets["web"]

यह बहुत important finding है क्योंकि यह हमारे actual Terraform code से निकली है।

Checkov ने यह resource identify किया:

इसका मतलब Checkov ने:

Module
   ↓
subnets
   ↓
azurerm_subnet
   ↓
web subnet

को check किया और security requirement missing पाई।

📂 Step 03 — Exact File Identify करें

Checkov ने हमें यह भी बताया:

File:
\modules\subnet\main.tf:5-15

यानी problem इस file में है:

terraform/
│
├── main.tf
│
└── modules/
    └── subnet/
        └── main.tf   ← Finding

यह troubleshooting में बहुत important है।

❌ पूरा project randomly check करने की जरूरत नहीं।

✅ Tool ने जिस file और line range को बताया है, पहले वहीं देखो।

🔬 Step 04 — Actual Terraform Code समझें

हमारे subnet module में code था:

resource "azurerm_subnet" "Subnets" {

  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes = each.value.address_prefixes

}

अब Checkov की finding से इसे compare करें।

Checkov कह रहा है:

Subnet
   ↓
NSG association missing

और हमारे code में:

azurerm_subnet
   ↓
Name
   ↓
Resource Group
   ↓
VNET
   ↓
Address Prefix

लेकिन:

NSG Association
      ❌

नहीं है।

इसलिए Checkov ने finding generate की।

🧠 Step 05 — Root Cause कैसे निकाला?

हमने output को तीन हिस्सों में पढ़ा:

1️⃣ WHAT?
CKV2_AZURE_31

Security policy failure।

2️⃣ WHERE?
modules/subnet/main.tf

Subnet module।

3️⃣ WHY?
NSG association configured नहीं है।

इसलिए:

Root Cause:
VNET subnets के लिए Network Security Group association
Terraform configuration में मौजूद नहीं थी।


⚠️ Important — Checkov Error और Terraform Error अलग हैं

यह distinction हमेशा याद रखें।

Terraform Error

Example:

Error: Unsupported attribute

यह बताता है कि Terraform configuration में technical/configuration problem है।

Checkov Finding

Example:

CKV2_AZURE_31
Ensure VNET subnet is configured with a Network Security Group

यह बताता है:

Terraform code syntactically valid हो सकता है
लेकिन security best practice satisfy नहीं कर रहा।

इसलिए:

terraform validate
        ↓
PASS

और:

checkov
        ↓
FAIL

दोनों एक साथ possible हैं।

🔁 Step 06 — एक Finding कई Resources पर क्यों आई?

हमारे output में:

web
application
data
management
security

सभी subnets पर वही finding आई।

Reason:

हमारा module:

for_each = var.subnets

use करता है।

इसका मतलब एक ही resource definition से multiple subnets create होते हैं।

इसलिए:

One module definition
        ↓
Multiple subnet instances
        ↓
Same security gap
        ↓
Multiple Checkov findings

यह देखकर घबराने की जरूरत नहीं है।

यह जरूरी नहीं कि पाँच अलग-अलग coding mistakes हों।

एक common module-level issue कई resources को affect कर सकता है।

🧠 — NSG क्यों important है?

NSG यानी:

Network Security Group

यह Azure network traffic को control करने के लिए use होता है।

Concept:

Internet
   │
   ▼
Azure VNet
   │
   ▼
Subnet
   │
   ▼
NSG
   │
   ├── Allow
   └── Deny

अगर subnet के लिए appropriate NSG controls नहीं हैं तो network security कमजोर हो सकती है।

इसलिए Checkov ने warning दी।

🛠️ Step 07 — Finding को Fix कैसे Approach करें?

पहले requirement समझें:

Subnet
   ↓
Network Security Group
   ↓
Subnet ↔ NSG Association

Terraform architecture में generally अलग resources/modules हो सकते हैं:

NSG
 │
 └── NSG Rules
       │
       ▼
Subnet
 │
 └── Association

Fix करने से पहले यह decide करना चाहिए:

कौन सा NSG किस subnet के लिए होगा?
क्या सभी subnets के लिए अलग NSG होगा?
क्या shared NSG होगा?
कौन से inbound rules चाहिए?
कौन से outbound rules चाहिए?
management subnet के rules क्या होंगे?
application subnet के rules क्या होंगे?
data subnet को कौन access करेगा?

⚠️ केवल Checkov को PASS कराने के लिए blindly NSG create नहीं करना चाहिए।

Security architecture पहले define करें।

🔄 Step 08 — Fix के बाद हमेशा Re-Scan

Security finding fix करने के बाद:

cd terraform
checkov -d .

फिर result compare करें:

Before:

Passed checks: 5
Failed checks: 5

After:

Passed checks: X
Failed checks: Y

Goal:

Failed checks
      ↓
Reduce
      ↓
0

लेकिन किसी check को सिर्फ:

--skip-check

से hide करना automatic solution नहीं है।


# ⚠️ — Security Scanner का मतलब हमेशा Code खराब नहीं होता

यह बहुत important concept है।

अगर Checkov कहता है:

FAIL

तो इसका मतलब automatically यह नहीं है कि Terraform code broken है।

Difference:

Terraform Validate
       ↓
Syntax / Configuration correctness

और:

Checkov
       ↓
Security Best Practices

इसलिए दोनों results को अलग-अलग समझना चाहिए।

🚫 Step 09 — Finding को Ignore कब करें?

कभी-कभी Checkov policy हमारे architecture पर लागू नहीं होती।

ऐसी स्थिति में finding को suppress/skip किया जा सकता है।

लेकिन documentation जरूरी है:

Finding:
CKV2_AZURE_31

Decision:
Accepted / Exception

Reason:
<business / architecture reason>

Approved By:
<name/team>

Review Date:
<date>

Security scanning में:

FAIL → blindly ignore

गलत approach है।

🐳 Issue 02 — Trivy Installation Failure

अब दूसरा real-world issue।

हमने पहले यह command try की:

pip install trivy

लेकिन error आया:

ERROR: No matching distribution found for trivy

फिर:

ERROR: Could not find a version that satisfies the requirement trivy


🧠 Step 01 — Error को सही तरीके से पढ़ें

Error कह रहा है:

No matching distribution found for trivy

इसका मतलब यह जरूरी नहीं कि:

Internet खराब है

या:

pip खराब है

हमें पहले समझना चाहिए कि Trivy क्या है।

🔎 Step 02 — Trivy का Installation Model समझें

Trivy एक Python package की तरह install करने वाला primary tool नहीं है।

इसलिए:

pip install trivy

हमारे Windows setup के लिए सही installation approach नहीं थी।

यही reason है कि pip ने package नहीं पाया।

🛠️ Step 03 — Correct Windows Installation

हमने Windows पर:

winget install AquaSecurity.Trivy

run किया।

Output:

Found Trivy [AquaSecurity.Trivy]
Version 0.74.0

फिर:

Successfully installed

इसका मतलब installation successful था।

⚠️ Issue 03 — Installation Successful लेकिन Command नहीं चला

Installation के बाद हमने run किया:

trivy --version

लेकिन error:

trivy : The term 'trivy' is not recognized

यह नया issue था।

ध्यान दें:

Installation
    ↓
SUCCESS

Command execution
    ↓
FAIL

इसलिए हमें installation दोबारा करने की जरूरत नहीं थी।


⚠️ — Trivy Installed लेकिन Command नहीं चल रही?

Installation के बाद अगर:

trivy --version

चलाने पर:

trivy : The term 'trivy' is not recognized

आता है तो घबराने की जरूरत नहीं है।

अगर installation output में यह message आया:

Path environment variable modified;
restart your shell to use the new value.

तो इसका मतलब:

Trivy installed successfully
        ↓
PATH updated
        ↓
Current PowerShell session अभी पुराना PATH use कर रहा है


🔄 — Trivy PATH Fix

सबसे आसान तरीका:

1️⃣ Current PowerShell बंद करें

2️⃣ नया PowerShell खोलें

फिर:

trivy --version

चलाएँ।

Expected:

Version: 0.74.0

Version future में अलग हो सकती है।



🧪 — अगर नया PowerShell भी Trivy नहीं पहचानता

पहले check करें:

where.exe trivy

अगर path दिखाई देता है तो Trivy installed है।

फिर:

trivy --version

try करें।

अगर फिर भी नहीं चलता तो PowerShell restart या Windows Terminal restart करें।

🧠 Step 04 — Actual Root Cause

Installer ने खुद message दिया:

Path environment variable modified;
restart your shell to use the new value.

यह सबसे important line थी।

इसका मतलब:

Trivy installed
      ↓
PATH updated
      ↓
Current PowerShell session पुराना PATH use कर रहा था

इसलिए current terminal को नया PATH दिखाई नहीं दे रहा था।

🔄 Step 05 — Correct Resolution

पहला और simplest solution:

Current PowerShell
        ↓
Close
        ↓
New PowerShell
        ↓
trivy --version

या VS Code में terminal use कर रहे हों तो:

Terminal
   ↓
Kill Terminal
   ↓
New Terminal

फिर:

trivy --version

अब expected output:

Version: 0.74.0

या installed version के अनुसार version information।

🧪 Step 06 — अगर फिर भी Trivy नहीं मिले

अगर नया terminal खोलने के बाद भी:

trivy is not recognized

आए तो पहले check करें:

where.exe trivy

अगर path मिलता है:

C:\...\trivy.exe

तो executable मौजूद है।

अगर path नहीं मिलता:

where.exe trivy

कोई result नहीं देता।

तो PATH configuration verify करें।

🔍 Step 07 — PATH Troubleshooting

PowerShell में:

$env:Path -split ';'

इससे current PATH entries दिखाई देंगी।

यह verify करने के लिए useful है कि Trivy का installation directory PATH में मौजूद है या नहीं।

🧪 Step 08 — Trivy Verify

जब command available हो जाए:

trivy --version

फिर project directory से scan:

trivy config .

Terraform/IaC configuration scan के लिए Trivy का config scanner use किया जा सकता है।

🧠 Checkov vs Trivy — इस Project में

दोनों tools security के लिए useful हैं लेकिन उनका focus पूरी तरह identical नहीं है।

| Tool | Main Focus |
| :--- | :--- |
| 🔍 **Checkov** | IaC security policies |
| 🐳 **Trivy** | Vulnerabilities + Misconfiguration + Secrets आदि |

Simple understanding:

Checkov
   ↓
"क्या Terraform configuration security best practices follow कर रही है?"
Trivy
   ↓
"इस configuration में security risks / misconfigurations क्या हैं?"

दोनों tools overlap कर सकते हैं, लेकिन दोनों useful security perspectives दे सकते हैं।


हमारे Terraform project में:

Terraform
    │
    ├── Checkov
    │      ↓
    │   IaC Policy
    │
    └── Trivy
           ↓
       Misconfiguration
       Vulnerabilities
       Secrets
       Configuration Security



### 📊 हमारे Real Issues का Summary

| # | Issue | Root Cause | Resolution |
| :-: | :--- | :--- | :--- |
| **1** | **Checkov 5 failed checks** | Terraform subnet में NSG association missing | NSG architecture/design करके association configure करना |
| **2** | **Same Checkov finding कई बार** | `for_each` से multiple subnets create हो रहे थे | Common module-level security gap identify किया |
| **3** | **`pip install trivy` failed** | Trivy को Python package की तरह install करने की कोशिश | Windows package manager से Trivy install किया |
| **4** | **`trivy` command not recognized** | New PATH current terminal में load नहीं हुआ | PowerShell/VS Code terminal restart किया |
| **5** | **Checkov PASS/FAIL confusion** | Terraform validation और security policy अलग checks हैं | Tool output को अलग-अलग interpret किया |

🧭 Security Troubleshooting Decision Tree

जब कोई security tool fail हो:

Security Scan
     │
     ▼
Failed?
     │
     ▼
Read Check ID
     │
     ▼
Identify Resource
     │
     ▼
Identify File + Line
     │
     ▼
Understand Policy
     │
     ▼
Find Root Cause
     │
     ├───────────────┐
     ▼               ▼
Valid Finding    False Positive
     │               │
     ▼               ▼
Fix Code        Document Exception
     │
     ▼
Re-Scan
     │
     ▼
Verify Result


🔥 Golden Rule — Logs पढ़ने का तरीका

किसी भी tool के output में यह 5 चीजें पहले खोजें:

1. ERROR / FAILED
2. CHECK ID
3. RESOURCE
4. FILE / LINE
5. ROOT CAUSE / RECOMMENDATION

Example:

CKV2_AZURE_31
      ↓
Subnet
      ↓
modules/subnet/main.tf
      ↓
NSG missing
      ↓
Security architecture review

🚨 Installation Error पढ़ने का तरीका

Trivy case:

pip install trivy
        ↓
No matching distribution
        ↓
Installation method गलत
        ↓
Use Windows package manager
        ↓
winget install AquaSecurity.Trivy
        ↓
Successfully installed
        ↓
trivy not recognized
        ↓
PATH issue
        ↓
Restart terminal
        ↓
trivy --version

🧪 Local Scan vs Pipeline Scan

इस Phase से एक important DevSecOps practice समझ आती है।

Recommended workflow:

Developer Machine
       │
       ▼
Local Security Scan
       │
       ▼
Fix obvious findings
       │
       ▼
Git Push
       │
       ▼
GitHub Actions
       │
       ▼
Automated Security Scan
       │
       ▼
Pull Request

Local scan developer को जल्दी feedback देता है।

Pipeline scan यह ensure करता है कि developer security check bypass करके code merge न कर दे।

🔐 Security Scanning का Golden Principle
Local Scan
    +
CI/CD Scan
    =
Defense in Depth

केवल local scan पर depend नहीं करना चाहिए।

और केवल pipeline पर depend करने से developer feedback देर से मिलेगा।



🐙 Step 8 — Security Tool GitHub पर कैसे आएगा?

Important:

हम Security Tool को GitHub repository में install नहीं करेंगे।

Repository में रहेगा:

Terraform Code
Workflow YAML
Documentation
Configuration

Security tools GitHub Actions runner पर install/run होंगे।

Architecture:

GitHub Repository
       │
       ▼
GitHub Actions Runner
       │
       ├── Terraform
       │
       ├── Checkov
       │
       └── Trivy



🏗️ Step 9 — Local vs Pipeline

Best practice:

LOCAL
  ↓
Developer जल्दी feedback लेता है
  ↓
Security Scan

और:

GITHUB ACTIONS
  ↓
Central enforcement
  ↓
Security Scan

इसलिए दोनों useful हैं।

Local का फायदा
Fast feedback
Easy debugging
No GitHub workflow wait
Pipeline का फायदा
Every Pull Request
Every Feature Branch
Consistent security checks
Team-wide enforcement


🔐 Step 10 — हमारा Final Security Pipeline

आगे जाकर हमारा pipeline इस तरह बनेगा:

🐙 GitHub
     │
     ▼
⚙️ GitHub Actions
     │
     ▼
📥 Checkout
     │
     ▼
🔐 Azure OIDC Login
     │
     ▼
✨ Terraform fmt
     │
     ▼
📦 Terraform init
     │
     ▼
✅ Terraform validate
     │
     ▼
🔍 Checkov
     │
     ▼
🐳 Trivy
     │
     ▼
📋 Terraform plan
     │
     ▼
🚀 Approval
     │
     ▼
☁️ Azure
🚦 Step 24 — Security Scan Fail होने पर क्या होगा?

मान लो Checkov को critical security issue मिला:

Checkov
   ↓
❌ FAILED

तो pipeline को आगे नहीं जाना चाहिए।

Concept:

Terraform Validate
        ↓
      PASS
        ↓
Checkov Security Scan
        ↓
      FAIL
        ↓
     STOP ❌
        ↓
Terraform Plan
        ↓
    NOT RUN

इससे insecure configuration accidentally deployment तक नहीं जाएगी।

🧠 Step 11 — अभी Security Tool Pipeline में क्यों नहीं डाला?

इस Phase में हमारा learning sequence है:

Step 1
Install Tool

        ↓

Step 2
Run Locally

        ↓

Step 3
Understand Findings

        ↓

Step 4
Fix Findings

        ↓

Step 5
Run Again

        ↓

Step 6
Integrate with GitHub Actions

इसलिए अभी हम local testing कर रहे हैं।

📁 Step 12 — Phase 14 Repository Structure

Phase 14 के बाद documentation structure:

comsolve-cyberex-azure-landing-zone/
│
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
│
├── docs/
│   ├── phase-09-terraform-ci-pipeline.md
│   ├── phase-10-terraform-troubleshooting.md
│   ├── phase-11-github-actions-azure-oidc.md
│   ├── phase-12-github-actions-azure-oidc-authentication.md
│   ├── phase-13-pipeline-error-resolution.md
│   └── phase-14-security-tools-integration.md
│
└── terraform/
    ├── main.tf
    ├── providers.tf
    ├── variables.tf
    ├── outputs.tf
    └── modules/


📝 Step 13 — Important Commands
Checkov
pip install checkov
checkov --version
cd terraform
checkov -d .
Trivy
winget install AquaSecurity.Trivy

Restart PowerShell.

trivy --version

Terraform configuration scan:

trivy config terraform



🏆 Phase 15 Final Architecture
                  🐙 GitHub Repository
                           │
                           ▼
                    GitHub Actions
                           │
             ┌─────────────┴─────────────┐
             │                           │
             ▼                           ▼
       Terraform Checks            Security Checks
             │                           │
       ┌─────┼─────┐               ┌─────┴─────┐
       │     │     │               │           │
      fmt   init validate         Checkov     Trivy
       │     │     │               │           │
       └─────┼─────┘               └─────┬─────┘
             │                           │
             └─────────────┬─────────────┘
                           ▼
                    Terraform Plan
                           │
                           ▼
                         Azure

📝 Phase 15 Lessons Learned

इस Phase में हमने सीखा:

🔎 Security finding और Terraform error अलग चीजें हैं
📋 Checkov output को कैसे पढ़ना है
🆔 Check ID का importance
📂 File और line number से root cause कैसे locate करना है
🔁 for_each की वजह से एक finding multiple resources पर क्यों दिख सकती है
🛡️ NSG-related security finding को कैसे understand करना है
🐳 Trivy को pip से install करने की कोशिश क्यों fail हुई
🪟 Windows PATH issue को कैसे पहचानना है
🔄 Installation और command-discovery failure में difference
🧪 Fix के बाद security scan दोबारा क्यों करना चाहिए
🚫 Security finding को blindly skip क्यों नहीं करना चाहिए
🏗️ Local + CI security scanning का DevSecOps model
🏆 Final Troubleshooting Formula

हर बार इस formula को follow करें:

READ
 ↓
IDENTIFY
 ↓
UNDERSTAND
 ↓
ROOT CAUSE
 ↓
FIX
 ↓
RE-SCAN
 ↓
VERIFY
 ↓
DOCUMENT

यही हमारा DevSecOps Security Troubleshooting Workflow है।


🔜 Next Phase

🚀 Phase 16 — Security Scanning in GitHub Actions

अगले Phase में हम सीखेंगे:

Git Push
   ↓
GitHub Actions
   ↓
Terraform Validation
   ↓
Checkov Security Scan
   ↓
Trivy Security Scan
   ↓
Security Result
   ↓
PASS / FAIL

और सबसे important:

अगर Checkov या Trivy security finding detect करे, तो क्या pipeline automatically fail होनी चाहिए?

यही अगला practical DevSecOps concept होगा।


---


मेरी recommendation
Phase 15
Trivy scan समझा + clean result मिला
        ↓
Phase 16
🔐 Security Gate + Pull Request Security
        ↓
Phase 17
📊 Security Findings Analysis & Remediation
        ↓
Phase 18
🚀 Secure CI/CD Pipeline
        ↓
Phase 19
📈 Monitoring / Observability
        ↓
Phase 20
🏢 GitHub Organization + Repository Governance


🔥 Final Architecture
                 👨‍💻 Developer
                      │
                      ▼
              🌿 Feature Branch
                      │
                      ▼
               🔀 Pull Request
                      │
                      ▼
              ⚙️ Terraform CI
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       Checkov      Trivy       Plan
          │           │           │
          └───────────┼───────────┘
                      ▼
                🔐 Security Gate
                      │
                      ▼
                 👨‍💻 Review
                      │
                      ▼
                 🔀 Merge
                      │
                      ▼
                    main
                      │
                      ▼
          🚀 Deployment Workflow
                      │
                      ▼
                🔐 Azure OIDC
                      │
                      ▼
              Terraform Plan
                      │
                      ▼
              🛑 Manual Approval
                      │
                      ▼
              terraform apply
                      │
                      ▼
                 ☁️ Azure