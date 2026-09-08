# 🔐 Phase 25.11 — Deployment Approval

<p align="center">
  <img src="https://img.shields.io/badge/Phase-25.11-blue">
  <img src="https://img.shields.io/badge/GitHub-Environment-black">
  <img src="https://img.shields.io/badge/Deployment-Approval-orange">
  <img src="https://img.shields.io/badge/Terraform-Protected%20Apply-purple">
</p>

## 🎯 Objective

इस phase का objective Terraform deployment से पहले एक **controlled human approval boundary** establish करना है।

Terraform `plan` के बाद `apply` को automatically execute करने के बजाय deployment को एक protected GitHub Environment के through control किया जाएगा।

इससे production Azure infrastructure में कोई change करने से पहले authorized reviewer की approval required होगी।

---

# 🏗️ Deployment Approval Architecture

Current CD lifecycle:

```text
Feature Branch
      ↓
CI Validation
      ↓
Pull Request
      ↓
Code Review + Approval
      ↓
Merge to main
      ↓
CD Pipeline
      ↓
Azure OIDC Authentication
      ↓
Terraform Init
      ↓
Terraform Plan
      ↓
🔐 Deployment Approval
      ↓
Terraform Apply
      ↓
Azure Infrastructure
```

इसमें **Deployment Approval** एक security boundary की तरह काम करता है।

---

# 🔐 Why Deployment Approval is Required

अगर CD pipeline में सीधे:

```text
terraform plan
      ↓
terraform apply
```

कर दिया जाए, तो `main` में merge होते ही Azure infrastructure automatically modify/create हो सकता है।

इससे unexpected infrastructure changes production environment में बिना human verification के deploy हो सकते हैं।

इसलिए architecture:

```text
Terraform Plan
      ↓
⏸️ Approval Gate
      ↓
Terraform Apply
```

रखा जाएगा।

---

# 🌐 GitHub Environment as Deployment Boundary

GitHub Actions में एक dedicated Environment बनाया जाएगा:

```text
production
```

यह Environment production deployment के लिए **protected boundary** के रूप में काम करेगा।

Concept:

```text
GitHub Repository
       │
       ├── CI
       │
       ├── CD
       │
       └── Environment
              │
              └── production 🔐
                     │
                     └── Required Reviewer
```

---

# 🛡️ Why `production` Environment?

`production` Environment का purpose केवल naming नहीं है।

यह deployment को repository के normal workflow से अलग करके एक **protected deployment target** देता है।

इस Environment पर protection rules configure किए जा सकते हैं, जैसे:

* Required reviewers
* Deployment approval
* Environment-specific protection
* Deployment access control

हमारे project में मुख्य requirement:

> **Terraform Apply से पहले authorized reviewer approval.**

---

# 👤 Required Reviewer

`production` Environment में:

```text
Required reviewers
        ↓
Authorized Reviewer
```

configure किया जाएगा।

Reviewer का purpose:

1. Terraform Plan review करना
2. Expected resource changes verify करना
3. Unexpected changes identify करना
4. Deployment approve या reject करना

---

# 🔄 Deployment Approval Flow

जब CD pipeline Terraform Plan तक पहुँचती है:

```text
Terraform Plan
      │
      ▼
Plan Result
      │
      ▼
┌─────────────────────────┐
│ Deployment Approval     │
│                         │
│ Required Reviewer       │
│          ↓              │
│      Approve / Reject   │
└─────────────────────────┘
      │
      ├──────── Reject ───────→ Deployment Stops
      │
      ▼
    Approve
      │
      ▼
Terraform Apply
```

---

# ⚖️ PR Approval vs Deployment Approval

इन दोनों को अलग समझना जरूरी है।

## Pull Request Approval

PR approval का मतलब:

> **Code को `main` branch में merge करने की permission.**

Flow:

```text
Feature Branch
      ↓
Pull Request
      ↓
Code Review
      ↓
PR Approval
      ↓
main
```

---

## Deployment Approval

Deployment approval का मतलब:

> **Approved code के Terraform changes को Azure में actually deploy करने की permission.**

Flow:

```text
main
 ↓
CD
 ↓
Terraform Plan
 ↓
Deployment Approval
 ↓
Terraform Apply
 ↓
Azure
```

इसलिए दोनों अलग security controls हैं।

---

# 🔒 Security Boundary

हमारा complete governance model:

```text
              CODE BOUNDARY
                   │
Feature Branch
       ↓
CI Validation
       ↓
Pull Request
       ↓
Code Review
       ↓
PR Approval
       ↓
      main
                   │
                   ▼
            DEPLOYMENT BOUNDARY
                   │
            Terraform Plan
                   ↓
          🔐 production
                   ↓
         Deployment Approval
                   ↓
           Terraform Apply
                   ↓
                Azure
```

इस architecture में दो अलग checkpoints हैं:

```text
1️⃣ Code Approval
2️⃣ Deployment Approval
```

---

# 🧪 Deployment Decision

Reviewer को Terraform Plan देखकर deployment decision लेना है।

Example:

```text
Plan: 16 to add, 0 to change, 0 to destroy
```

अगर changes expected हैं:

```text
✅ Approve
```

तो:

```text
Terraform Apply
```

execute किया जा सकता है।

अगर unexpected changes हैं:

```text
❌ Reject
```

तो deployment आगे नहीं जाना चाहिए।

---

# 🚦 Approval Outcomes

### ✅ Approved

```text
Plan
 ↓
Approval
 ↓
Apply
 ↓
Azure Deployment
```

### ❌ Rejected

```text
Plan
 ↓
Approval
 ↓
Rejected
 ↓
Apply नहीं होगा
```

### ⏸️ Waiting

```text
Plan
 ↓
Waiting for reviewer
 ↓
No Apply
```

---

# ⚠️ Important Principle

`terraform plan` और `terraform apply` को एक ही automatic step में नहीं जोड़ना है।

Recommended controlled flow:

```text
Plan
 ↓
Human Review
 ↓
Approval
 ↓
Apply
```

इससे deployment decision और code execution के बीच एक स्पष्ट security boundary बनी रहती है।

---

# 🔧 GitHub Configuration

GitHub Repository में:

```text
Repository
   ↓
Settings
   ↓
Environments
   ↓
New Environment
   ↓
production
```

Environment:

```text
Name:
production
```

Protection:

```text
Required reviewers
        ↓
Authorized Reviewer
```

---

<p align="center">
  <img src="https://img.shields.io/badge/Phase-25.11-blue">
  <img src="https://img.shields.io/badge/GitHub-Environment-black">
  <img src="https://img.shields.io/badge/Deployment-Approval-orange">
  <img src="https://img.shields.io/badge/Production-Boundary-red">
</p>
---

# 🌐 Production Environment

GitHub Repository में dedicated Environment configure किया गया:

```text
Environment Name:
Comsolve_production
```

यह Environment production Azure deployment के लिए protected deployment target के रूप में काम करेगा।

> Environment का नाम project requirement के अनुसार `Comsolve_production` रखा गया है।

---

# 🛡️ Deployment Protection Rules

Environment configuration में:

```text
Deployment protection rules
```

का उपयोग किया जाता है।

इन rules का purpose है कि deployment आगे बढ़ने से पहले defined conditions satisfy हों।

Current configuration:

```text
Required Reviewers
        ↓
@Shrikant-Nadgauda
```

---

# 👤 Required Reviewer

Configured reviewer:

```text
@Shrikant-Nadgauda
```

इसका मतलब:

> Production deployment को आगे बढ़ाने से पहले configured reviewer की approval required होगी।

Reviewer Terraform Plan देखकर deployment decision लेगा।

---

# 🚫 Prevent Self-Review

Environment में:

```text
Prevent self-review
```

option उपलब्ध है।

इसका purpose है:

> जिस user ने workflow/deployment trigger किया है, वही user अपने deployment को approve न कर सके।

Recommended configuration:

```text
Prevent self-review
        ↓
Enabled ✅
```

इससे deployment approval में separation of responsibility maintain होती है।

---

# ⏱️ Wait Timer

GitHub Environment में optional:

```text
Wait timer
```

configure किया जा सकता है।

इसका purpose deployment से पहले predefined waiting period रखना है।

Current requirement में mandatory waiting period आवश्यक नहीं है।

इसलिए:

```text
Wait Timer:
Not Required
```

रखा जा सकता है।

---

# 🧩 Custom Deployment Protection Rules

GitHub additional custom deployment protection rules की सुविधा भी provide करता है।

इनका उपयोग external systems या GitHub Apps के through additional deployment conditions validate करने के लिए किया जा सकता है।

Current project scope में custom rules की आवश्यकता नहीं है।

```text
Custom Rules:
Not Required
```

---

# ⚠️ Allow Administrators to Bypass

Environment में option:

```text
Allow administrators to bypass configured protection rules
```

available है।

इसका purpose administrators को configured protection rules bypass करने की capability देना है।

Production deployment security को मजबूत रखने के लिए:

```text
Administrator Bypass
        ↓
Disabled / Not Used
```

रखना recommended है, जब तक emergency governance process में इसकी explicit आवश्यकता न हो।

---

# 🌿 Deployment Branches and Tags

Environment में यह भी control किया जा सकता है कि कौन-सी branches या tags production deployment कर सकती हैं।

Recommended production model:

```text
main
 ↓
Production Environment
```

Feature branches को directly production deployment नहीं करना चाहिए।

Recommended rule:

```text
Allowed Deployment Branch:
main
```

इससे production deployment केवल approved `main` code से होगा।

---

# 🔐 Environment Secrets

GitHub Environment में:

```text
Environment secrets
```

भी configure किए जा सकते हैं।

Environment secrets encrypted variables होते हैं और workflow में Environment context के अंदर उपलब्ध होते हैं।

इस project में Azure authentication के लिए existing OIDC configuration use हो रही है:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

इसलिए केवल approval mechanism के लिए नए Azure credentials create करने की आवश्यकता नहीं है।

---

# 🎯 Configuration Summary

| Configuration        | Status / Recommendation |
| -------------------- | ----------------------- |
| Environment          | `Comsolve_production`   |
| Required Reviewer    | `@Shrikant-Nadgauda`    |
| Prevent Self-Review  | Enable                  |
| Wait Timer           | Not Required            |
| Custom Rules         | Not Required            |
| Administrator Bypass | Disabled / Not Used     |
| Production Branch    | `main`                  |
| Purpose              | Protect Terraform Apply |

---

# 🔍 What to Validate

* `Comsolve_production` Environment successfully created
* Required reviewer configured
* Prevent self-review enabled
* Production deployment branch restricted to `main`
* Deployment requires reviewer approval
* Terraform Apply is placed behind the protected Environment
* Rejected deployment does not proceed to Apply

### ✅ Best Practice

* Production deployment के लिए dedicated GitHub Environment use करें।
* Required reviewer configure करें।
* `Prevent self-review` enable करें।
* Production deployment केवल approved `main` branch से allow करें।
* PR Approval और Deployment Approval को अलग security controls रखें।
* Production Environment को Terraform Apply से associate करें।
* Administrator bypass को सामान्य deployment के लिए use न करें।

### 🧪 Validation Test

1. `main` branch में approved Terraform code मौजूद हो।
2. CD workflow Terraform Plan execute करे।
3. Production Environment approval required हो।
4. Reviewer approval के बिना Apply आगे न बढ़े।
5. Authorized reviewer deployment approve करे।
6. Approval के बाद Terraform Apply stage execute हो।
7. Rejection की स्थिति में deployment stop हो।

---

### 📋 Evidence

* `Comsolve_production` Environment configuration screenshot
* Required reviewer configuration
* Prevent self-review configuration
* Deployment branch configuration
* CD workflow Environment configuration
* Terraform Plan result
* Deployment approval screen
* Approved deployment result
* Terraform Apply result

---


# 🔗 Terraform CD Integration

CD workflow में deployment job को protected Environment से associate किया जाएगा:

```yaml
environment:
  name: production
```

इसके कारण deployment job configured Environment protection rules के अधीन चलेगी।

Target architecture:

```text
terraform-plan
      ↓
production Environment
      ↓
Required Reviewer
      ↓
Approval
      ↓
terraform-apply
```

---

# 🎯 Phase Scope

इस phase में focus केवल:

* Deployment Approval
* GitHub Environment
* `production` boundary
* Required Reviewer
* Approval / Rejection behavior
* Terraform Apply protection

पर रहेगा।

Already validated components को unnecessarily repeat नहीं किया जाएगा:

```text
Azure OIDC        → Already validated
Terraform Init    → Already validated
Terraform Plan    → Already validated
Main → CD Trigger → Already validated
```

---

# 🔍 What to Validate

* `production` GitHub Environment exists
* Required reviewer protection is configured
* CD deployment is associated with `production`
* Terraform Apply is behind the approval boundary
* Unauthorized deployment cannot directly execute Apply
* Approved deployment can proceed to Terraform Apply

### ✅ Best Practice

* Production deployment के लिए dedicated GitHub Environment use करें।
* Required reviewers configure करें।
* Terraform Plan और Terraform Apply के बीच approval gate रखें।
* PR approval और deployment approval को अलग controls रखें।
* `terraform apply` को uncontrolled automatic execution से बचाएँ।

### 🧪 Validation Test

1. `main` में approved code मौजूद हो।
2. CD pipeline Terraform Plan execute करे।
3. Deployment approval required हो।
4. Reviewer approval के बिना Apply आगे न बढ़े।
5. Reviewer approval देने के बाद Apply stage proceed करे।
6. Reviewer rejection की स्थिति में deployment stop हो।

### 🎯 Expected Result

Expected deployment flow:

```text
main
 ↓
CD
 ↓
Terraform Plan
 ↓
⏸️ Deployment Approval
 ↓
✅ Approved
 ↓
Terraform Apply
 ↓
Azure
```

Approval के बिना:

```text
Terraform Apply
      ❌
```

execute नहीं होना चाहिए।

### 📋 Evidence

* GitHub `production` Environment screenshot
* Required reviewer configuration
* CD workflow Environment configuration
* Terraform Plan result
* Deployment approval screen
* Approved deployment evidence
* Terraform Apply execution result

---

# 🏁 Phase Completion

Phase 25.11 तब complete माना जाएगा जब:

```text
Production Environment
        +
Required Reviewer
        +
Deployment Approval
        +
Protected Terraform Apply
```

successfully configured और validated हो।

**Next Phase → `12-Terraform-Apply.md`**

---

# 🚀 Phase 25.10 — Deployment Approval

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Actions-181717)
![Approval](https://img.shields.io/badge/Approval-Required-orange)
![Environment](https://img.shields.io/badge/Environment-Production-red)

</p>

## 🎯 Objective

Terraform Apply से पहले production deployment के लिए manual approval control लागू करना।

---

## 🔐 GitHub Environment

```text
Comsolve_production
```

Apply job को इस environment के साथ associate किया गया है।

```yaml
environment:
  name: Comsolve_production
```

---

## 🔄 Approval Flow

```text
Terraform Plan
      ↓
Plan Artifact
      ↓
Deployment Approval
      ↓
Approved
      ↓
Terraform Apply
```

---

## 🛡️ Purpose

Approval gate का उद्देश्य:

* Unreviewed deployment रोकना
* Production changes पर human control रखना
* Deployment auditability improve करना
* Plan और Apply के बीच governance maintain करना

---

## 🏁 Outcome

Production deployment के लिए controlled manual approval mechanism configured है।

---