# 🚀 Phase 20.3 — GitHub Required Status Checks & CI Security Gate

<p align="center">

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-623CE4?style=for-the-badge&logo=terraform&logoColor=white)

![Trivy](https://img.shields.io/badge/Trivy-Security%20Scan-1904DA?style=for-the-badge)

![Branch Protection](https://img.shields.io/badge/Branch%20Protection-Required-success?style=for-the-badge)

![Security Gate](https://img.shields.io/badge/Security%20Gate-Enforced-red?style=for-the-badge)

</p>

> 🎯 **Objective:** GitHub Repository की `main` branch पर GitHub Actions CI checks को **Required Status Checks** बनाना, ताकि Terraform validation या Trivy security scan fail होने पर Pull Request को `main` में merge न किया जा सके।

---

# 📌 1. Current Position

Phase 20.1 में हमने Repository Governance और Branch Protection की foundation तैयार की।

अब हमारा focus है:

```text
Pull Request
      ↓
GitHub Actions
      ↓
Terraform CI
      ↓
Trivy Security Scan
      ↓
Terraform Plan
      ↓
PASS / FAIL
      ↓
Merge Decision
```


### 🎯 Phase 20.2 Goals

| Control | Target Status |
| :--- | :--- |
| **GitHub Actions CI** | ![Required](https://img.shields.io/badge/Status-REQUIRED-blue?style=flat-square) |
| **Terraform Format** | ![Required](https://img.shields.io/badge/Status-REQUIRED-blue?style=flat-square) |
| **Terraform Validate** | ![Required](https://img.shields.io/badge/Status-REQUIRED-blue?style=flat-square) |
| **Trivy IaC Scan** | ![Required](https://img.shields.io/badge/Status-REQUIRED-blue?style=flat-square) |
| **Terraform Plan** | ![Required](https://img.shields.io/badge/Status-REQUIRED-blue?style=flat-square) |
| **Failed CI** | ![Merge Blocked](https://img.shields.io/badge/Behavior-MERGE_BLOCKED-red?style=flat-square) |
| **Successful CI** | ![Merge Allowed](https://img.shields.io/badge/Behavior-MERGE_ALLOWED-brightgreen?style=flat-square) |
| **Direct Main Push** | ![Blocked](https://img.shields.io/badge/Behavior-BLOCKED-red?style=flat-square) |


📂 3. Existing CI Pipeline

हमारे Repository में existing workflow:

.github/
└── workflows/
    └── terraform-ci.yml

Pipeline का current flow:

Checkout
   ↓
Azure Login
   ↓
Azure Subscription Verify
   ↓
Terraform Setup
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
🟢 STEP 01 — Repository में Workflow Verify करें

PowerShell में Repository root से run करें:

Get-Content .\.github\workflows\terraform-ci.yml

Check करें कि workflow में:

name: Terraform CI

मौजूद है।

और:

jobs:
  terraform:

मौजूद है।

🟢 STEP 02 — Workflow Name समझें

हमारे workflow में:

name: Terraform CI

है।

लेकिन Required Status Check configure करते समय GitHub में अक्सर पूरा job/check name दिखाई देता है।

इसलिए हमें अनुमान नहीं लगाना है।

पहले एक वास्तविक Pull Request create करके GitHub Actions का exact check name देखेंगे।

🟢 STEP 03 — Test Branch Create करें

PowerShell:

git checkout main

Latest code लें:

git pull origin main

अब testing branch बनाएँ:

git checkout -b feature/required-status-check

Verify करें:

git branch

Expected:

* feature/required-status-check
  main


तुम्हारे case में main से नई branch बनाकर test करना सही नहीं रहेगा, क्योंकि Azure/GitHub Actions की authentication/permission setup अभी feature/nic-infrastructure के साथ जुड़ी हुई है।

इसलिए Phase 20.2 की testing भी feature/nic-infrastructure से branch बनाकर करेंगे।

तुम्हारा current flow:

main
  ↓
❌ नई branch
  ↓
GitHub Actions
  ↓
Azure authentication / permissions issue
  ↓
Pipeline FAIL

हमारा practical flow:

feature/nic-infrastructure
          ↓
          ↓
feature/required-status-check
          ↓
GitHub Actions
          ↓
Azure Authentication
          ↓
Terraform CI
          ↓
Trivy
          ↓
Terraform Plan
          ↓
✅ PASS
इसलिए Step 03 को ऐसे बदलो
git checkout feature/nic-infrastructure

Latest code:

git pull origin feature/nic-infrastructure

Testing branch:

git checkout -b feature/required-status-check

Verify:

git branch

Expected:

  feature/nic-infrastructure
* feature/required-status-check
  main
⚠️ एक important बात

तुमने जो Azure Agent/Secrets को feature/nic-infrastructure तक restrict किया है, उसकी वजह से feature/* pattern automatically permission नहीं दे रहा — यह branch/ref restriction का behavior है।

इसलिए अभी हम existing working branch से ही testing branch बनाएँगे, ताकि पहले से working Azure authentication और CI setup को disturb न करें।

बाद में Phase 20.6 में हम इस permission model को properly organization/repository governance + environments + branch rules के हिसाब से clean करेंगे।

----


# 🟢 STEP 04 — Safe Test Change करें

किसी Terraform resource को modify नहीं करना है।

सिर्फ documentation में एक छोटी line add करें।

Example:

README.md

या:

docs/Phase-20.2-GitHub-Repository-Governance.md

में change करें।

# 🟢 STEP 05 — Commit करें
git status

फिर:

git add .

Commit:

git commit -m "docs: add required status checks governance"


### 🟢 STEP 06 — Branch Push करें
git push -u origin feature/required-status-check

अब GitHub पर branch दिखाई देगी।

🟢 STEP 07 — Pull Request Create

GitHub Repository → Pull requests → New pull request

अब branches ऐसे select करो:

base repository:
comsolve-cyberex-azure-landing-zone

base:
feature/nic-infrastructure

compare:
feature/required-status-check

फिर:

Create pull request
🔐 हमारा actual test
feature/nic-infrastructure
          ↑
          │ PR
          │
feature/required-status-check
          ↓
GitHub Actions
          ↓
Terraform CI
          ↓
Trivy
          ↓
Terraform Plan
          ↓
✅ PASS
          ↓
Required Approval
          ↓
Merge

यही हमारे environment के हिसाब से सही flow है। main को अभी touch करके testing नहीं करेंगे।


हाँ भाई, git push -u origin feature/required-status-check feature/nic-infrastructure में push नहीं करेगा।

यह नई branch को ही GitHub पर push करेगा:

LOCAL
feature/required-status-check
        ↓
        git push -u origin feature/required-status-check
        ↓
REMOTE
origin/feature/required-status-check

लेकिन ध्यान रखना:

feature/nic-infrastructure
        ↓
   (जिससे branch बनाई)
        ↓
feature/required-status-check
        ↓
   GitHub पर push

इसलिए code की starting point NIC branch की होगी, लेकिन push नई feature/required-status-check branch में होगा।

और PR में:

base    = feature/nic-infrastructure
compare = feature/required-status-check

रखोगे तो changes NIC branch में merge होंगे। ✅


🟢 STEP 08 — GitHub Actions Run होने दें

PR open करने के बाद GitHub Actions automatically run होगी।

Expected:

Terraform CI
     ↓
Terraform Format
     ↓
Terraform Init
     ↓
Terraform Validate
     ↓
Trivy
     ↓
Terraform Plan

सभी checks complete होने दें।

🟢 STEP 09 — Exact Status Check Name Identify करें

Pull Request में:

Checks

tab खोलें।

यहाँ हमें GitHub द्वारा generated exact check/job name देखना है।

Example:

Terraform Validation

या:

Terraform CI / Terraform Validation

या GitHub UI में जो exact name दिखाई दे।

⚠️ यहाँ manually name नहीं लिखना है। GitHub में जो exact check name दिखाई दे वही use करना है।

🔐 STEP 10 — Repository Settings Open करें

GitHub Repository:

Settings
   ↓
Branches

अब main branch की protection configuration खोलें।

अगर नया GitHub Rulesets interface दिखाई देता है तो:

Settings
   ↓
Rules
   ↓
Rulesets

का उपयोग किया जा सकता है।

🟢 STEP 11 — Main Branch Rule Select करें

Target branch:

main

है।

Rule का उद्देश्य:

main
 ↓
Protected
 ↓
PR Required
 ↓
Status Checks Required
🔒 STEP 12 — Required Status Checks Enable करें

Option:

Require status checks to pass before merging

को enable करें।

इसके बाद GitHub check search करने का option देगा।

🟢 STEP 13 — Terraform CI Check Add करें

अब Step 09 में जो exact check name मिला था उसे search करें।

Example:

Terraform Validation

उस check को select करें।

Expected:

Required Status Checks

☑ Terraform Validation
🔐 STEP 14 — Branch Protection Strict रखें

अगर option मिले:

Require branches to be up to date before merging

तो इसे enable करने से पहले team workflow consider करें।

Strict mode में PR branch को latest main के साथ updated रखना पड़ सकता है।

इस project के लिए शुरुआती implementation में:

Required CI Check
        +
PR Approval
        +
Protected main

मुख्य security controls हैं।

🧪 STEP 15 — Save Protection Rule

Configuration verify करें:

Target:
main

Pull Request:
Required

Approval:
Required

Status Check:
Required

Force Push:
Disabled

Deletion:
Disabled

फिर:

Save changes

करें।

🔥 STEP 16 — पहला Practical Test

अब वही Pull Request खुला रहने दें।

PR में:

Checks

section देखें।

Expected:

Terraform CI
   ✅ Passed

अब merge button available होना चाहिए, provided बाकी branch protection requirements भी satisfied हों।


# test fail ho gaya ahi

```text

Node 20 is being deprecated. This workflow is running with Node 24 by default. If you need to temporarily use Node 20, you can set the ACTIONS_ALLOW_USE_UNSECURE_NODE_VERSION=true environment variable. For more information see: https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/
Run azure/login@v2
Running Azure CLI Login.
/usr/bin/az cloud set -n azurecloud
Done setting cloud: "azurecloud"
Federated token details:
 issuer - https://token.actions.githubusercontent.com
 subject claim - repo:Shrikant-Nadgaudaa@247837213/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/required-status-check
 audience - api://AzureADTokenExchange
 job_workflow_ref - Shrikant-Nadgaudaa/comsolve-cyberex-azure-landing-zone/.github/workflows/terraform-ci.yml@refs/heads/feature/required-status-check
Attempting Azure CLI login by using OIDC...
Error: AADSTS700213: No matching federated identity record found for presented assertion subject 'repo:Shrikant-Nadgaudaa@247837213/comsolve-cyberex-azure-landing-zone@1338145312:ref:refs/heads/feature/required-status-check'. Check your federated identity credential Subject, Audience and Issuer against the presented assertion. https://learn.microsoft.com/entra/workload-id/workload-identity-federation Trace ID: 67e611a0-ba10-4b67-9602-577db58a2800 Correlation ID: 89d93192-1308-4c7a-9193-a77d7edc3b87 Timestamp: 2026-08-28 12:42:55Z

Error: Run the command below to authenticate interactively; additional arguments may be added as needed:
az logout
az login

Error: Login failed with Error: The process '/usr/bin/az' failed with exit code 1. Double check if the 'auth-type' is correct. Refer to https://github.com/Azure/login#readme for more information.

```

## ❓ महत्वपूर्ण प्रश्न

ऊपर बताए गए सभी Repository Protection, Pull Request Approval और Required Status Check rules configure करने के बाद भी `main` branch में Pull Request merge कैसे हो गया?

साथ ही, GitHub Actions में `Azure Login` step क्यों fail हुआ?

> 🔎 **Hypothesis:** संभव है कि Azure App Registration में Federated Identity Credential केवल `feature/nic-infrastructure` branch के लिए configured है। इसलिए जब GitHub Actions किसी दूसरी branch या Pull Request context से Azure authentication करने की कोशिश करता है, तो Azure OIDC authentication fail हो जाता है।

**इस issue का exact कारण और उसका समाधान हम अगले step में verify करेंगे।**

हाँ भाई, अब actual issue साफ हो गया है। तुम्हारा PR merge इसलिए हुआ क्योंकि जिस check को तुम देख रहे हो — Terraform Validation — वह जरूरी नहीं कि Ruleset में Required Status Check के रूप में configured हो।

GitHub में सिर्फ check का FAIL होना = automatically merge block होना नहीं है। केवल वही checks merge को रोकते हैं जिन्हें target branch के ruleset में explicitly required किया गया है।

अभी तुम्हारे case में flow
PR
 ↓
GitHub Actions
 ↓
Terraform Validation
 ↓
❌ FAIL
 ↓
लेकिन Ruleset में यह check REQUIRED नहीं है
 ↓
GitHub
 ↓
✅ Merge allowed

इसलिए तुम्हारा observation बिल्कुल सही है।


⚠️ एक और महत्वपूर्ण बात

तुम्हारा current failure:

AADSTS700213
No matching federated identity record

Azure OIDC authentication failure है, Trivy/Terraform code failure नहीं।

और अभी हमें इसे दो अलग चीजों की तरह देखना है:

Azure OIDC
   ↓
❌ Authentication problem

और

GitHub Required Status Check
   ↓
❌/✅ Merge Gate

पहले Ruleset में Terraform Validation को Required बनाओ। उसके बाद PR को दोबारा test करेंगे।


----

👍 पहले Azure OIDC login वाला issue solve करते हैं, फिर Required Status Check का fail/merge test करेंगे।

अभी तुम्हारा actual blocker यही है:

azure/login@v2
      ↓
OIDC Authentication
      ↓
AADSTS700213
      ↓
No matching federated identity record found

इसका मतलब GitHub Actions का OIDC token Azure तक पहुँच रहा है, लेकिन Azure App Registration में उसके subject से matching Federated Credential नहीं है।

पहले इसे fix करते हैं। उसके बाद ही Terraform Validation को intentionally fail करके governance test करेंगे।

हमारा flow
STEP 1
Azure App Registration
        ↓
STEP 2
Federated Credentials check
        ↓
STEP 3
GitHub branch / PR के लिए सही Subject configure
        ↓
STEP 4
GitHub Actions re-run
        ↓
azure/login
        ↓
✅ SUCCESS
        ↓
Terraform Validation
        ↓
Trivy
        ↓
Terraform Plan

अभी Terraform में कोई { } मत हटाना और कोई failure मत बनाना। पहले Azure authentication ठीक करते हैं।

---
आपके स्क्रीन पर अब जो फ़ील्ड्स बचे हैं, उनको इसी नए immutable-subject फ़ॉर्मेट में फ़िल करना है:

### 📋 OIDC Configuration Fields Reference

| Field | क्या select/enter करना है |
| :--- | :--- |
| **Issuer** | `https://token.actions.githubusercontent.com` |
| **Organization** | `Shrikant-Nadgaudaa` |
| **Organization ID** | GitHub का Organization ID |
| **Repository** | `comsolve-cyberex-azure-landing-zone` |
| **Repository ID** | GitHub repo का Repository ID |
| **Entity type** | Branch / Pull request — workflow के अनुसार |
| **Subject identifier** | Auto-generated रहने दो |
| **Name** | `github-actions-oidc` |
| **Audience** | `api://AzureADTokenExchange` |

---

1️⃣ Repository ID निकालो

GitHub पर अपना repository खोलो:

comsolve-cyberex-azure-landing-zone
        ↓
Settings
        ↓
General
        ↓
सबसे नीचे
Danger Zone

लेकिन Repository ID के लिए easiest तरीका GitHub API है।

PowerShell में:

(Invoke-RestMethod "https://api.github.com/repos/Shrikant-Nadgaudaa/comsolve-cyberex-azure-landing-zone").id

Output ऐसा number आएगा:

1338145312

यही:

Repository ID = 1338145312
2️⃣ Organization ID निकालो

तुम्हारे GitHub account/repository के organization का नाम यहाँ दिख रहा है:

Shrikant-Nadgaudaa

PowerShell:

(Invoke-RestMethod "https://api.github.com/orgs/Shrikant-Nadgaudaa").id

अगर यह organization नहीं बल्कि personal account है, तो command अलग होगी:

(Invoke-RestMethod "https://api.github.com/users/Shrikant-Nadgaudaa").id
🔥 पहले ये दो commands चला
(Invoke-RestMethod "https://api.github.com/repos/Shrikant-Nadgaudaa/comsolve-cyberex-azure-landing-zone").id
(Invoke-RestMethod "https://api.github.com/users/Shrikant-Nadgaudaa").id

---

Perfect bhai ✅ अब दोनों IDs मिल गईं।

तुम्हारे case में:

GitHub Account / Owner ID
247837213

Repository ID
1338145312


Azure के **Add a credential ➔ GitHub Actions deploying Azure resources** फ़ॉर्म में अभी ये भरें:

### 🔐 Azure OIDC Federated Credential Configuration

| Azure Field | Value |
| :--- | :--- |
| **Issuer** | `https://token.actions.githubusercontent.com` |
| **Organization** | `Shrikant-Nadgaudaa` |
| **Organization ID** | `247837213` |
| **Repository** | `comsolve-cyberex-azure-landing-zone` |
| **Repository ID** | `1338145312` |


⚠️ अब सबसे important — Entity type

तुम्हारा error PR से भी आया था:

subject ... :pull_request

और branch run से भी:

subject ... :ref:refs/heads/feature/required-status-check

इसलिए एक FIC से दोनों cases automatically cover नहीं होंगे अगर generated subject अलग है।

हमारा अभी objective है:

GitHub Pull Request
        ↓
Azure OIDC Login
        ↓
Terraform Validation
        ↓
Required Status Check

इसलिए पहले Pull request वाला credential बनाना सही रहेगा।

Entity type → Pull request select करो।

फिर Subject identifier को manually edit मत करना — Azure उसे automatically calculate करेगा।

बाकी:

Name:
github-actions-pr

Audience:
api://AzureADTokenExchange

फिर Add / Save करो।

इसके बाद GitHub Actions में Re-run failed jobs करेंगे और देखेंगे कि azure/login@v2 अब सफल होता है या नहीं।

---

✅ Azure Login successful hai, लेकिन इसका मतलब पूरी pipeline अभी automatically successful नहीं मानी जाएगी। यह सिर्फ azure/login@v2 authentication step का success है।

Markdown में यह short comment डाल:

> ✅ **Azure OIDC Login Successful:** GitHub Actions ने Azure के साथ OIDC-based authentication successfully complete किया। Azure subscription और tenant details successfully validate हो गईं और Service Principal के रूप में login successful रहा।

Flow:

GitHub Actions
      ↓
OIDC Token
      ↓
Microsoft Entra ID
      ↓
Federated Credential
      ↓
Azure Login ✅
      ↓
Terraform CI आगे execute



---


हाँ भाई, अब एक controlled retest करते हैं। इस बार हम यह verify करेंगे कि main पर required status check वास्तव में enforce हो रहा है या नहीं।

🧪 Retest — Required Status Check
STEP 01 — Current test branch पर रहो
git checkout feature/required-status-check

Check:

git branch

Expected:

  feature/nic-infrastructure
* feature/required-status-check
  main
STEP 02 — जानबूझकर CI fail कराओ

STEP 02 — Temporary Terraform Failure

उदाहरण के लिए किसी .tf file में:

resource "azurerm_resource_group" "test" {

को temporarily ऐसा कर दो:

resource "azurerm_resource_group" "test" {
  THIS_IS_A_TEST_ERROR

इससे Terraform validation fail होना चाहिए।

STEP 03 — नया commit बनाओ

फिर:

git add .
git commit -m "test: verify required status check failure"
git push

GitHub Actions चलेगा:

Pull Request
    ↓
Terraform Validation
    ↓
❌ FAIL
    ↓
Required Status Check
    ↓
🚫 MERGE BLOCKED
⚠️ लेकिन एक बात

Existing production/resource definition में यह मत डालना अगर उसी file में बहुत important infrastructure है। बेहतर है जिस .tf file को बदलो, उसका सिर्फ एक harmless syntax error डालो।

Test complete होने के बाद:

❌ THIS_IS_A_TEST_ERROR
        ↓
🗑️ Remove
        ↓
Terraform code वापस सही
        ↓
git add .
git commit -m "fix: restore terraform configuration after governance test"
git push

Curly bracket हटाने के बजाय यह तरीका ज्यादा साफ है, क्योंकि बाद में तुरंत पता रहेगा कि हमने जानबूझकर test failure बनाया था।


---

### Azure login

```text

Node 20 is being deprecated. This workflow is running with Node 24 by default. If you need to temporarily use Node 20, you can set the ACTIONS_ALLOW_USE_UNSECURE_NODE_VERSION=true environment variable. For more information see: https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/
Run azure/login@v2
Running Azure CLI Login.
/usr/bin/az cloud set -n azurecloud
Done setting cloud: "azurecloud"
Federated token details:
 issuer - https://token.actions.githubusercontent.com
 subject claim - repo:Shrikant-Nadgaudaa@247837213/comsolve-cyberex-azure-landing-zone@1338145312:pull_request
 audience - api://AzureADTokenExchange
 job_workflow_ref - Shrikant-Nadgaudaa/comsolve-cyberex-azure-landing-zone/.github/workflows/terraform-ci.yml@refs/pull/4/merge
Attempting Azure CLI login by using OIDC...
Subscription is set successfully.
Azure CLI login succeeds by using OIDC.
```

---
### verify Azure login
```text
0s
Run az account show
{
  "environmentName": "AzureCloud",
  "homeTenantId": "402a28d6-9ea1-462e-8338-dc09423ff348",
  "id": "7cf9c45e-0a1e-4828-9c98-3e8f25397732",
  "isDefault": true,
  "managedByTenants": [],
  "name": "Azure subscription 1",
  "state": "Enabled",
  "tenantId": "402a28d6-9ea1-462e-8338-dc09423ff348",
  "user": {
    "name": "***",
    "type": "servicePrincipal"
  }
}
1s
```

---

### verify Azure Subscription
```text
Run az account show --query "{subscription:id, tenant:tenantId, user:user.name}"
{
  "subscription": "7cf9c45e-0a1e-4828-9c98-3e8f25397732",
  "tenant": "402a28d6-9ea1-462e-8338-dc09423ff348",
  "user": "***"
}
1s
```

---
### terraform format check

```text

0s
Run terraform fmt -check -recursive
╷
│ Error: Argument or block definition required
│ 
│   on modules/resource-group/main.tf line 7, in resource "azurerm_resource_group" "Rgs":
│    7:   THIS_IS_A_TEST_ERROR ...
│ 
│ An argument or block definition is required here. To set an argument, use
│ the equals sign "=" to introduce the argument value.
╵

2s
```

---

### terraform format check

```text

0s
Run terraform fmt -check -recursive
╷
│ Error: Argument or block definition required
│ 
│   on modules/resource-group/main.tf line 7, in resource "azurerm_resource_group" "Rgs":
│    7:   THIS_IS_A_TEST_ERROR ...
│ 
│ An argument or block definition is required here. To set an argument, use
│ the equals sign "=" to introduce the argument value.
╵
```

---


### terraform init

``` text

0s
Run terraform init
Initializing the backend...

Initializing modules...
- resource_groups in modules/resource-group
- nsg in modules/nsg
- nics in modules/nic
- vnet in modules/vnet
- subnets in modules/subnet
╷
│ Error: Argument or block definition required
│ 
│   on modules/resource-group/main.tf line 7, in resource "azurerm_resource_group" "Rgs":
│    7:   THIS_IS_A_TEST_ERROR ...
│ 
│ An argument or block definition is required here. To set an argument, use
│ the equals sign "=" to introduce the argument value.
╵
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
0s
```

----

STEP 04 — GitHub PR खोलो

GitHub:

Pull requests
   ↓
feature/required-status-check → main

अगर existing PR है तो नई PR बनाने की जरूरत नहीं।

PR खोलकर:

Checks

section देखो।

STEP 05 — सबसे important verification

देखो:

Terraform Validation

क्या status है?

❌ Failed

और PR के नीचे GitHub क्या message देता है:

❌ Merge blocked

या:

Merging is blocked

या required checks वाला warning।

STEP 06 — अगर फिर भी Merge button available है

Merge मत करना।

PR में नीचे यह check करो:

Merge checks
   ↓
Required status checks

और देखो क्या Terraform Validation के सामने:

Required

लिखा है।

🔥 सबसे important test

हमारा expected final result:

feature/required-status-check
             ↓
          Pull Request
             ↓
            main
             ↓
   Terraform Validation
             ↓
          ❌ FAIL
             ↓
   Required Check = YES
             ↓
      🚫 MERGE BLOCKED

अगर इसके बाद भी Merge button से merge हो जाता है, तो कुछ भी change मत करना।

----


हाँ भाई 🔥 अब Azure OIDC वाला issue successfully solve हो गया है, और उसके बाद हमारा जानबूझकर बनाया हुआ Terraform failure भी पकड़ लिया गया है। यही हमें चाहिए था।

🔐 Actual Flow
Pull Request #4
      ↓
GitHub Actions
      ↓
OIDC Token
      ↓
Microsoft Entra ID
      ↓
Federated Identity Credential
      ↓
Azure Login ✅
      ↓
Terraform Init
      ↓
Terraform Modules Load
      ↓
Terraform Syntax Validation
      ↓
❌ TEST ERROR DETECTED
      ↓
Pipeline STOPPED
✅ Azure Login अब सही है

यह सबसे important change है:

Subscription is set successfully.
Azure CLI login succeeds by using OIDC.

मतलब:

GitHub ने OIDC token generate किया
Azure ने FIC से token match किया
Azure authentication successful हुआ
Service Principal के रूप में Azure subscription access मिल गया

इसलिए AADSTS700213 issue खत्म हो गया। ✅

❌ Terraform Failure भी Expected है

हमने जानबूझकर यह line डाली थी:

THIS_IS_A_TEST_ERROR

Terraform ने उसे पकड़ लिया:

Error: Argument or block definition required

modules/resource-group/main.tf line 7

THIS_IS_A_TEST_ERROR

इसका मतलब Terraform ने invalid configuration detect कर ली और pipeline को आगे जाने से रोक दिया।

इसलिए:

Terraform Init
     ↓
❌ Error
     ↓
Terraform exited with code 1
     ↓
Remaining steps SKIPPED

और यही कारण है कि Trivy / Plan जैसे बाद के steps इस run में नहीं चले।

### 🎯 Phase Execution — Proof of Concept

| Test Verification | Status |
| :--- | :--- |
| **Azure OIDC Authentication** | ![Passed](https://img.shields.io/badge/Status-PASSED-brightgreen?style=flat-square) |
| **Azure Subscription Access** | ![Passed](https://img.shields.io/badge/Status-PASSED-brightgreen?style=flat-square) |
| **Terraform Initialization** | ![Started](https://img.shields.io/badge/Status-STARTED-blue?style=flat-square) |
| **Terraform Error Detection** | ![Passed](https://img.shields.io/badge/Status-PASSED-brightgreen?style=flat-square) |
| **Pipeline Failure on Error** | ![Passed](https://img.shields.io/badge/Status-PASSED-brightgreen?style=flat-square) |
अब बहुत important: यह test पूरा हो गया है, इसलिए THIS_IS_A_TEST_ERROR को वापस हटाकर Terraform code सही करना है।

फिर:

Correct Terraform
      ↓
Push
      ↓
PR
      ↓
Azure OIDC Login       ✅
      ↓
Terraform Validation   ✅
      ↓
Trivy                  ✅
      ↓
Terraform Plan         ✅
      ↓
Required Status Check  ✅

### 🔄 Successful Pipeline Workflow

```mermaid
graph TD
    A[Correct Terraform] --> B[Push to Feature Branch]
    B --> C[Create Pull Request]
    C --> D[Azure OIDC Login ✅]
    D --> E[Terraform Validation ✅]
    E --> F[Trivy Security Scan ✅]
    F --> G[Terraform Plan ✅]
    G --> H[Required Status Check Passed ✅]

और उसके बाद हम वापस Phase 20.2 के मुख्य objective — Required Status Check के कारण failed CI पर Merge Block हो रहा है या नहीं — उसे verify करेंगे।
-----

# 🚨 STEP 17 — Failure Test

अब हमें security gate को practically test करना है।

Test branch में ऐसा temporary Terraform change करें जिससे validation fail हो।

उदाहरण के लिए intentionally invalid Terraform syntax डाल सकते हैं।

⚠️ यह change केवल test branch में करें। main में कभी नहीं।

फिर:

git add .
git commit -m "test: validate failed CI merge protection"
git push

GitHub Actions फिर से run होगी।

Expected:

Terraform Validate
        ↓
❌ FAILED

या कोई दूसरा required CI check fail होगा।

🚫 STEP 18 — Merge Blocking Verify करें

अब Pull Request में देखें।

Expected behavior:

Required check
      ↓
❌ Failed
      ↓
Merge blocked

GitHub को PR merge नहीं करने देना चाहिए।

यही हमारी CI Security Gate है।

🟢 STEP 19 — Test Fix करें

अब intentionally broken code को वापस सही करें।

git status

फिर:

git add .

Commit:

git commit -m "fix: restore valid terraform configuration"

Push:

git push
🟢 STEP 20 — Successful CI Verify करें

GitHub Actions फिर run होगी।

Expected:

Terraform Format
        ✅

Terraform Init
        ✅

Terraform Validate
        ✅

Trivy
        ✅

Terraform Plan
        ✅

अब:

Required Checks
       ↓
ALL PASS
       ↓
Merge Allowed
🔐 STEP 21 — Final Security Flow

हमारे Repository का final PR flow अब:

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
Trivy Security Scan
    ↓
Terraform Plan
    ↓
Required Status Checks
    ↓
Code Review
    ↓
Approval
    ↓
Merge to main
🚫 STEP 22 — Failure Scenario

अगर Trivy fail करता है:

Pull Request
     ↓
Trivy
     ↓
❌ FAILED
     ↓
Required Check Failed
     ↓
🚫 Merge Blocked

अगर Terraform Validate fail करता है:

Pull Request
     ↓
Terraform Validate
     ↓
❌ FAILED
     ↓
🚫 Merge Blocked
🟢 STEP 23 — Success Scenario
Pull Request
     ↓
Terraform Format
     ↓
Terraform Init
     ↓
Terraform Validate
     ↓
Trivy
     ↓
Terraform Plan
     ↓
✅ ALL REQUIRED CHECKS PASSED
     ↓
Reviewer Approval
     ↓
Merge
🧪 STEP 24 — Final Validation Checklist
Validation	Expected
Feature branch created	✅
Pull Request created	✅
GitHub Actions executed	✅
Exact CI check identified	✅
Required Status Check configured	⏳
CI failure blocks merge	⏳
CI success allows merge	⏳
Main branch protected	⏳
PR approval required	⏳
Force push disabled	⏳
📊 STEP 25 — Phase 20.2 Final State

Implementation complete होने के बाद:

                    GitHub Repository
                           │
                           ▼
                    Protected main
                           │
                    ┌──────┴──────┐
                    │             │
                    ▼             ▼
              Pull Request    No Direct Push
                    │
                    ▼
              Required CI
                    │
          ┌─────────┼─────────┐
          ▼         ▼         ▼
      Terraform    Trivy    Plan
      Validate     Scan
          │         │         │
          └─────────┼─────────┘
                    ▼
               All Passed
                    │
                    ▼
              Code Approval
                    │
                    ▼
                Merge main
📝 Phase 20.2 Status
Governance Control	Status
Main Branch Protection	✅ Phase 20.1
Pull Request Requirement	✅ Phase 20.1
Required Status Checks	⏳ Phase 20.2
Terraform CI Gate	⏳
Trivy Security Gate	⏳
Failed CI Merge Blocking	⏳
Successful CI Merge	⏳
Force Push Protection	⏳
Branch Deletion Protection	⏳
🧠 What We Implemented

इस Phase में हमारा मुख्य practical achievement होगा:

CI सिर्फ report नहीं करेगा
        ↓
CI अब Merge Gate बनेगा

मतलब:

Security/Infrastructure Check Failed
             ↓
       Merge नहीं होगा

और:

All Required Checks Passed
             ↓
       Review + Approval
             ↓
          Merge
🚀 Next Phase

Phase 20.2 के बाद:

Phase 20.3
     ↓
Secret Scanning
     ↓
Repository में accidentally committed
secrets / credentials को detect और protect करना

इसके बाद:

Phase 20.4
     ↓
Dependabot
Phase 20.5
     ↓
Repository Governance Policy
Phase 20.6
     ↓
GitHub Organization
+
Team-Based Access

🔐 Security Principle: कोई भी Pull Request तब तक main में merge नहीं होना चाहिए जब तक सभी mandatory CI और security checks सफलतापूर्वक pass न हो जाएँ।


**इस Phase में खास बात:** हम सिर्फ setting नहीं लगाएंगे—**एक बार intentionally CI fail करके merge-blocking behavior


Bilkul bhai 👍 manual approval लगा है, इसलिए CI PASS → Merge Allowed का मतलब automatic merge नहीं है। वहाँ wording थोड़ी confusing है।

हमारा actual flow यह है:

Developer
    ↓
feature branch पर code change
    ↓
Pull Request → main
    ↓
┌─────────────────────────┐
│ GitHub Actions          │
│ Terraform CI            │
│ Trivy Scan              │
│ Terraform Plan          │
└─────────────────────────┘
    ↓
   PASS
    ↓
Reviewer Approval
    ↓
   APPROVED
    ↓
GitHub Governance Rules
    ↓
✅ Merge Allowed
    ↓
Human / Maintainer
    ↓
Merge PR
    ↓
main

अगर CI fail:

Pull Request
    ↓
CI / Trivy / Terraform
    ↓
❌ FAIL
    ↓
Merge ❌ BLOCKED

और अगर CI PASS लेकिन reviewer approval नहीं है:

CI ✅
   ↓
Approval ❌
   ↓
Merge ❌ BLOCKED
इसलिए हमारे project में सही principle

CI PASS अकेले merge नहीं करता।
CI PASS + Required Reviewer Approval + सभी Repository Rules PASS होने के बाद ही human reviewer/maintainer merge करता है।

तो तुम्हारे document में:

CI PASS
   ↓
Merge Allowed

की जगह बेहतर होगा:

CI PASS
   ↓
Required Reviewer Approval
   ↓
Repository Rules PASS
   ↓
Human Reviewer / Maintainer
   ↓
Merge

यही हमारा Secure PR Flow है। 🔐
