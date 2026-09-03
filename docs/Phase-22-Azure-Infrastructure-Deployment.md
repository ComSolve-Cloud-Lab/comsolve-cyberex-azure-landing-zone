

Azure → Entra ID → App registrations → तुम्हारा GitHub App → Federated credentials
GitHub → Actions → Failed run → जहाँ Azure Login / OIDC fail हो रहा है
🚀 Phase 21 — GitHub Organization Security Validation & CI/CD Recovery
<p align="center">

</p>

🎯 Objective: ComSolve-Cloud-Lab Organization में repository transfer के बाद टूटे हुए GitHub Actions → Azure OIDC authentication, repository permissions, RBAC और CI/CD security controls को validate और restore करना।

🧠 Phase 21 में हम क्या करने वाले हैं?

हमने अभी तक:

Personal GitHub
      ↓
comsolve-cyberex-azure-landing-zone

से:

ComSolve-Cloud-Lab
      ↓
comsolve-cyberex-azure-landing-zone

कर दिया है।

अब architecture बदल गया:

GitHub Organization
        ↓
Repository
        ↓
GitHub Actions
        ↓
OIDC Token
        ↓
Microsoft Entra ID
        ↓
Federated Credential
        ↓
Azure Service Principal
        ↓
Azure Subscription

Pipeline अब इसी नए identity path से authenticate करेगी।

🔥 सबसे पहले — Pipeline क्यों fail हुई?

पहले repository शायद:

PersonalAccount/comsolve-cyberex-azure-landing-zone

था।

अब:

ComSolve-Cloud-Lab/comsolve-cyberex-azure-landing-zone

है।

GitHub Actions का OIDC token repository identity से जुड़ा होता है। Azure का Federated Credential उस token के subject (sub) को match करता है।

इसलिए:

```text

Old Repository Identity
        ↓
Old OIDC Subject
        ↓
Azure FIC
```

और अब:

```text

New Organization Repository
        ↓
New OIDC Subject
        ↓
Azure FIC must match
```
Sabse pehle pipeline failure ka important point: repository transfer ke baad OIDC/Federated Credential change hona expected hai, especially GitHub ke current immutable-subject behavior ki wajah se. GitHub docs ke according, 15 July 2026 ke baad transferred repositories immutable OIDC subject format use karte hain; Azure FIC ko naye subject ke saath match karna padta hai.

लेकिन exact FIC अभी बिना देखे change मत करना। पहले existing Azure App Registration में Federated Credentials का screenshot और pipeline का failed azure/login वाला error screenshot upload कर दे। इससे मैं exact subject देखकर बता दूँगा कि क्या बदलना है।

### 📸 ये 2 check कर दे: ###
Azure → Entra ID → App registrations → तुम्हारा GitHub App → Federated credentials
GitHub → Actions → Failed run → जहाँ Azure Login / OIDC fail हो रहा है

---

# 🧩 STEP 01 — अभी FIC को Change मत करो

पहले Azure में जाएँ:

```text

Azure Portal
    ↓
Microsoft Entra ID
    ↓
App registrations
    ↓
GitHub Actions App
    ↓
Federated credentials
```

यहाँ existing credential देखना है।

तुम्हें कुछ इस तरह information मिलेगी:

Name
Issuer
Subject
Audience

सबसे important:

Subject

है।

---

# 🧩 STEP 02 — GitHub Repository Check

GitHub में:

ComSolve-Cloud-Lab
    ↓
comsolve-cyberex-azure-landing-zone
    ↓
Settings
    ↓
Actions

और workflow check करो।

Workflow में Azure login लगभग इस concept पर होना चाहिए:

permissions:
  id-token: write
  contents: read

और:

- name: Azure Login
  uses: azure/login@v2

GitHub की Azure OIDC documentation भी id-token: write और azure/login का यही authentication model बताती है।

---

# 🧩 STEP 03 — Repository Name Confirm करो

हमारा exact repository होना चाहिए:

ComSolve-Cloud-Lab/comsolve-cyberex-azure-landing-zone

ध्यान देना:

ComSolve-Cloud-Lab
        ↑
Organization

और:

comsolve-cyberex-azure-landing-zone
        ↑
Repository

दोनों exact होने चाहिए।

🔐 STEP 04 — Azure Federated Credential का Concept

अगर workflow main branch से चल रहा है और repository अभी name-based subject use कर रही है, तो traditional subject ऐसा हो सकता है:

repo:ComSolve-Cloud-Lab/comsolve-cyberex-azure-landing-zone:ref:refs/heads/main

GitHub OIDC documentation इसी प्रकार के repository/branch subject का format बताती है।

लेकिन तुम्हारे case में अभी blindly यही value मत डालना।

क्योंकि 15 July 2026 के बाद transferred repositories immutable subject behavior में जा सकते हैं, जिसमें owner/repository IDs भी शामिल होते हैं।

इसलिए पहले screenshot से exact value निकालेंगे।

🧪 STEP 05 — Pipeline Failure Identify करना

GitHub:

Repository
    ↓
Actions
    ↓
Failed Workflow
    ↓
Job

देखना है कि failure किस stage पर है।

अगर ऐसा error है:
AADSTS70021
No matching federated identity record found

तो almost certainly:

GitHub OIDC Subject
        ≠
Azure Federated Credential Subject

है।

# 🛠️ STEP 06 — Azure Federated Identity Credential (FIC) Correct करना

> 🎯 **Objective:**
> GitHub Repository transfer के बाद Azure Login में आने वाले **OIDC Authentication Failure** को resolve करना।
> इस step में GitHub से आने वाले OIDC `sub` claim और Microsoft Entra ID में configured **Federated Identity Credential (FIC)** के `Subject` को exact match कराया जाएगा।

---

## 🔴 06.1 — Authentication Error क्यों आया?

Repository को GitHub Organization में transfer करने के बाद GitHub Actions का OIDC identity context बदल सकता है।

GitHub Actions Azure से login करते समय एक OIDC token generate करता है।

इस token में एक important claim होता है:

`sub`

Azure में configured **Federated Identity Credential** इसी `sub` value के आधार पर यह verify करता है कि:

> यह token किस GitHub Organization / Repository / Branch से आया है?

Authentication तभी successful होगी जब GitHub token का `sub` और Azure FIC का `Subject` match करें।

### Authentication Flow

GitHub Actions

↓

OIDC Token

↓

`sub` Claim

↓

Azure Federated Identity Credential

↓

Subject Match

↓

Microsoft Entra ID Authentication

↓

Azure Login Successful

---

## 🔴 06.2 — Subject Mismatch होने पर क्या होता है?

Example:

GitHub OIDC Token:

`sub = X`

Azure FIC:

`Subject = Y`

अगर:

`X ≠ Y`

तो Azure token को trust नहीं करेगा।

Result:

**❌ Azure Login Failed**

इसलिए हमें अंदाज़े से Subject नहीं लिखना है।

हमें पहले **GitHub का actual OIDC subject** identify करना है।

---

# 🔎 06.3 — सबसे पहले GitHub Actions का Exact Error देखो

GitHub Repository खोलो:

`Actions → Failed Workflow → Failed Job`

फिर उस step को खोलो:

`Azure Login`

या:

`Azure Login via OIDC`

Error में authentication-related message देखो।

Common error इस तरह का हो सकता है:

`AADSTS70021: No matching federated identity record found for presented assertion.`

या:

`No matching federated identity record found for presented assertion.`

अगर ऐसा error है, तो इसका मतलब है:

**GitHub ने OIDC token generate किया, लेकिन Azure में उसका matching FIC नहीं मिला।**

---

# 🛠️ 06.4 — Azure में Existing FIC Check करो

Azure Portal खोलो।

Path:

`Microsoft Entra ID`

↓

`App registrations`

↓

अपना GitHub Actions वाला App Registration खोलो।

फिर:

`Manage`

↓

`Certificates & secrets`

↓

`Federated credentials`

अब existing FIC दिखाई देगा।

---

# 🔍 06.5 — Existing FIC की तीन चीजें Check करो

FIC खोलकर नीचे की values check करो:

### 1. Issuer

Expected:

`https://token.actions.githubusercontent.com`

---

### 2. Audience

Expected:

`api://AzureADTokenExchange`

---

### 3. Subject

यही सबसे important field है।

पुराना Subject कुछ ऐसा हो सकता है:

`repo:OLD-OWNER/REPOSITORY:ref:refs/heads/main`

Repository Organization में transfer होने के बाद यह पुराना Subject invalid हो सकता है।

---

# 🧩 06.6 — Repository Transfer के बाद Subject क्यों बदल सकता है?

पहले repository personal account के under थी।

Example:

`OLD-OWNER/comsolve-cyberex-azure-landing-zone`

अब repository Organization के under है:

`ComSolve-Cloud-Lab/comsolve-cyberex-azure-landing-zone`

इसलिए GitHub OIDC identity भी repository ownership context के साथ बदल सकती है।

अब Azure FIC अगर अभी भी पुराने owner/repository identity को trust कर रहा है, तो:

`GitHub OIDC Subject`

और

`Azure FIC Subject`

match नहीं होंगे।

Result:

**❌ Authentication Failed**

---

# 🔎 06.7 — Exact GitHub OIDC Subject Identify करना

यह सबसे important step है।

Repository में जाओ:

`Settings → Actions → General`

और OIDC-related configuration/workflow को check करो।

साथ ही failed workflow के `Azure Login` step को खोलकर exact authentication error देखो।

हमें यह determine करना है कि workflow किस identity context से token generate कर रहा है:

### Case A — Main Branch

अगर workflow `main` branch से login कर रहा है, subject traditionally इस format में हो सकता है:

`repo:ComSolve-Cloud-Lab/comsolve-cyberex-azure-landing-zone:ref:refs/heads/main`

### Case B — Pull Request

अगर workflow `pull_request` event पर run हो रहा है:

`repo:ComSolve-Cloud-Lab/comsolve-cyberex-azure-landing-zone:pull_request`

### Case C — Environment

अगर workflow किसी GitHub Environment का use करता है:

`repo:ComSolve-Cloud-Lab/comsolve-cyberex-azure-landing-zone:environment:ENVIRONMENT_NAME`

**इसलिए Subject blindly replace नहीं करना है।**

पहले यह देखना जरूरी है कि workflow किस context में Azure Login कर रहा है।

---

# ⚠️ 06.8 — 2026 में Immutable OIDC Subject भी Important है

GitHub ने नए repository identity model में **immutable OIDC subjects** introduce किए हैं।

Repository transfer/rename के बाद GitHub OIDC subject immutable format में हो सकता है।

ऐसे subject का structure example:

`repo:ComSolve-Cloud-Lab@OWNER_ID/comsolve-cyberex-azure-landing-zone@REPO_ID:ref:refs/heads/main`

यहाँ:

* `OWNER_ID` = GitHub Organization/Owner ID
* `REPO_ID` = GitHub Repository ID

**इन IDs को guess नहीं करना है।**

Exact values GitHub से प्राप्त करनी हैं।

---

# 🛠️ 06.9 — FIC को Directly Delete मत करो

सबसे पहले existing FIC को note करो।

Example:

`github-actions-main`

उसका:

* Issuer
* Audience
* Subject

copy/save कर लो।

### Important

पुराना FIC तुरंत delete मत करो।

पहले नया correct FIC create करना बेहतर है।

इससे authentication में unnecessary downtime नहीं होगा।

---

# 🆕 06.10 — नया Correct FIC Create करना

Azure Portal में:

`App registrations`

↓

`GitHub Actions App`

↓

`Certificates & secrets`

↓

`Federated credentials`

↓

`Add credential`

अब:

### Federated credential scenario

Select:

`GitHub Actions deploying Azure resources`

फिर GitHub information भरनी होगी।

### Organization

`ComSolve-Cloud-Lab`

### Repository

`comsolve-cyberex-azure-landing-zone`

### Entity type

Workflow के अनुसार select करो:

`Branch`

या

`Pull request`

या

`Environment`

### Branch

अगर workflow `main` branch पर है:

`main`

फिर credential create करो।

---

# 🔐 06.11 — अगर GitHub Immutable Subject Use कर रहा है

अगर GitHub का actual OIDC token immutable subject use कर रहा है, तो FIC में exact immutable subject configure करना होगा।

Example:

`repo:ComSolve-Cloud-Lab@OWNER_ID/comsolve-cyberex-azure-landing-zone@REPO_ID:ref:refs/heads/main`

जहाँ:

`OWNER_ID`

और

`REPO_ID`

GitHub से exact values होंगी।

**Example values को production में copy नहीं करना है।**

---

# 🧪 06.12 — नया FIC Save करो

FIC create करने के बाद Azure में दो credentials दिखाई दे सकते हैं:

### Old

`github-actions-main-old`

Subject:

`OLD SUBJECT`

### New

`github-actions-main-immutable`

Subject:

`CORRECT SUBJECT`

यह expected है।

अभी old FIC delete नहीं करना है।

---

# ▶️ 06.13 — GitHub Actions दोबारा Run करो

अब GitHub Repository में:

`Actions`

↓

Failed Workflow

↓

`Re-run jobs`

या नया commit push करके workflow trigger करो।

अब सबसे पहले यह check करो:

`Azure Login`

Expected:

**✅ Login successful**

अगर Azure Login successful हो गया तो FIC correction successful है।

---

# ✅ 06.14 — Authentication Successful होने के बाद Pipeline Check करो

Azure Login के बाद pipeline को आगे continue होना चाहिए:

`Checkout`

↓

`Azure Login`

↓

`Terraform Init`

↓

`Terraform Validate`

↓

`Trivy Security Scan`

↓

`Terraform Plan`

Expected:

* Azure Login → **PASS**
* Terraform Init → **PASS**
* Terraform Validate → **PASS**
* Trivy → **PASS**
* Terraform Plan → **PASS**

---

# 🧹 06.15 — Old FIC कब Delete करना है?

Old FIC तभी delete करना है जब:

1. New FIC successfully created हो
2. GitHub Actions Azure Login successfully हो
3. Terraform pipeline successfully complete हो
4. New FIC से authentication confirm हो जाए

इसके बाद:

`Azure Portal → App Registration → Federated credentials`

में जाकर old/unused FIC remove किया जा सकता है।

---

# 🧠 06.16 — पूरा Issue एक Line में

Repository transfer के बाद:

`GitHub Repository Identity Changed`

↓

`OIDC sub Changed`

↓

`Azure FIC Subject Old था`

↓

`OIDC sub ≠ FIC Subject`

↓

`Azure Authentication Failed`

↓

`Correct FIC Subject Configure`

↓

`OIDC sub = FIC Subject`

↓

**✅ Azure Login Successful**

---

# 🎯 STEP 06 Completion Criteria

Step 06 तब complete माना जाएगा जब:

* [ ] GitHub OIDC authentication error identified
* [ ] Azure App Registration identified
* [ ] Existing FIC reviewed
* [ ] Issuer verified
* [ ] Audience verified
* [ ] GitHub repository identity verified
* [ ] Correct OIDC Subject identified
* [ ] New FIC created
* [ ] GitHub Actions re-run completed
* [ ] Azure Login successful
* [ ] Terraform pipeline continued successfully
* [ ] Old FIC removed only after successful validation

---

## 📌 Important Rule

**FIC Subject को manually guess करके replace नहीं करना है।**

पहले GitHub Actions के failed `Azure Login` error और workflow trigger को देखकर exact OIDC subject determine करना है।

फिर उसी exact identity को Azure Federated Credential में configure करना है।

यह इसलिए जरूरी है क्योंकि FIC का पूरा purpose ही यह verify करना है कि **trusted GitHub identity वही है जिसे Azure access दिया गया है।**


---

# 🔑 STEP 07 — Audience भी Check करना

Azure FIC में audience सामान्यतः:

api://AzureADTokenExchange

होना चाहिए।

GitHub की Azure OIDC guidance भी इसे recommended audience बताती है।

इसलिए verify:

Issuer:
https://token.actions.githubusercontent.com

Audience:
api://AzureADTokenExchange
🔐 STEP 08 — Azure Role Assignment अलग चीज है

एक important distinction:

Federated Credential
        ↓
Authentication

और:

Azure RBAC Role
        ↓
Authorization

दो अलग चीजें हैं।

Example:

OIDC
 ↓
"तुम कौन हो?"
 ↓
Authentication

Azure RBAC
 ↓
"तुम क्या कर सकते हो?"
 ↓
Authorization

इसलिए FIC सही होने के बाद भी अगर:

AuthorizationFailed

आता है तो Azure RBAC role check करना होगा।

🧪 STEP 09 — Azure Role Check

Azure में:

Subscription
    ↓
Access control (IAM)
    ↓
Role assignments

GitHub Actions वाले App/Service Principal को check करें।

Expected required role project requirement के अनुसार होगा, जैसे:

Contributor

या उससे कम privilege वाला custom/appropriate role।

Owner देने की जरूरत सिर्फ इसलिए नहीं है कि GitHub Actions चल रही है।

🔐 STEP 10 — GitHub Secrets Check

Repository:

Settings
    ↓
Secrets and variables
    ↓
Actions

verify:

AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID

Azure documentation भी OIDC setup में इन values को GitHub configuration में use करने का documented pattern देती है।

ध्यान:

Client ID
Tenant ID
Subscription ID

secret itself नहीं होते in the same sense as client secret, लेकिन workflow configuration में centrally manage करना सही practice है।

🧪 STEP 11 — Pipeline Test

सब correction के बाद:

GitHub
   ↓
Actions
   ↓
Terraform CI
   ↓
Run workflow

Expected:

Checkout
   ↓
Azure Login
   ↓
Terraform Init
   ↓
Terraform Validate
   ↓
Trivy
   ↓
Terraform Plan
   ↓
✅ SUCCESS
🔎 STEP 12 — Successful Authentication का मतलब

अगर:

Azure Login
    ↓
Success

तो इसका मतलब:

GitHub
   ↓
OIDC
   ↓
Entra ID
   ↓
Federated Credential

अब सही काम कर रहे हैं।

उसके बाद अगर Terraform fail होता है तो वह OIDC problem नहीं, बल्कि Terraform/Azure permission/configuration problem होगी।

🏢 STEP 13 — Team RBAC को भी Validate करेंगे

तुमने testing के लिए अभी 2 Teams बनाए हैं और users add करके repository access दिया है।

अब उनका test:

Team
 ↓
User
 ↓
Repository
 ↓
Permission

करना है।

Example:

Team-A
   ↓
Read

और:

Team-B
   ↓
Write

फिर test:

Read User
    ↓
Clone/View
    ↓
Push
    ↓
❌ Expected Fail

और:

Write User
    ↓
Create Branch
    ↓
Push
    ↓
✅ Expected Success
🛡️ STEP 14 — Branch Protection साथ में Validate

Repository:

Settings
    ↓
Rules
    ↓
Rulesets / Branch Rules

हमारा target:

main
 ↓
Protected
 ↓
PR required
 ↓
Required status checks
 ↓
Merge

इसका मतलब developer के पास:

Write

होने के बावजूद:

Direct main push

controlled रहेगा।

🧪 STEP 15 — Complete Security Test

Phase 21 के अंत में हमारा test matrix:

Test	Expected
Azure OIDC Authentication	✅
Azure Login	✅
Terraform Init	✅
Terraform Validate	✅
Trivy Scan	✅
Terraform Plan	✅
Read Team Access	✅
Write Team Access	✅
Unauthorized Push	❌
Direct main Push	❌
PR Required	✅
Required Status Check	✅
Azure RBAC	✅

```text
🏗️ Final Architecture
                         ComSolve-Cloud-Lab
                                │
                                ↓
              comsolve-cyberex-azure-landing-zone
                                │
                 ┌──────────────┴──────────────┐
                 │                             │
                 ↓                             ↓
              Teams                       GitHub Actions
                 │                             │
                 ↓                             ↓
             RBAC Access                     OIDC
                 │                             │
                 │                             ↓
                 │                     Microsoft Entra ID
                 │                             │
                 │                             ↓
                 │                    Federated Credential
                 │                             │
                 │                             ↓
                 │                          Azure
                 │
                 ↓
          Branch Protection
                 │
                 ↓
          Pull Request Review
                 │
                 ↓
          Required Status Checks
```
---
# 📋 Phase 21 Implementation Plan

```text

Phase 21
   │
   ├── 21.1 Repository Transfer Validation
   │
   ├── 21.2 Azure OIDC / FIC Recovery
   │
   ├── 21.3 GitHub Actions Authentication Test
   │
   ├── 21.4 Azure RBAC Validation
   │
   ├── 21.5 Team RBAC Testing
   │
   ├── 21.6 Branch Protection Validation
   │
   ├── 21.7 CI/CD Security Validation
   │
   └── 21.8 Final Security Evidence
```
---

# 🚨 अभी तुम्हारा सबसे पहला काम

Phase 21 में अभी Team/RBAC को आगे मत छेड़ना।

पहले pipeline वापस green करनी है।

इस order में काम करेंगे:

```text
1️⃣ Azure Federated Credential देखना
          ↓
2️⃣ Failed Azure Login error देखना
          ↓
3️⃣ GitHub OIDC Subject identify करना
          ↓
4️⃣ Azure FIC correct करना
          ↓
5️⃣ Pipeline Run
          ↓
6️⃣ Azure Login ✅
          ↓
7️⃣ Terraform Plan ✅
          ↓
8️⃣ उसके बाद Team RBAC Testing
```
---