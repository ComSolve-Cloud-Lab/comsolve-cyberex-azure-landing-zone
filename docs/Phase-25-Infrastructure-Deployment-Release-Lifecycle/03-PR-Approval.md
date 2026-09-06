# 🔐 Phase 25.03 — Pull Request Approval

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-Pull%20Request-black?logo=github)
![Pull Request](https://img.shields.io/badge/Pull%20Request-Approval-blue?logo=github)
![Terraform](https://img.shields.io/badge/Terraform-Code%20Review-purple?logo=terraform)
![Security](https://img.shields.io/badge/Security-Review-red)
![Status](https://img.shields.io/badge/Status-Completed-success)

</p>

---

## 📌 Objective

इस phase का objective `feature/vnet` से `main` branch में जाने वाले Pull Request को **proper review और approval process** से validate करना है।

इस phase में हमने:

* Pull Request checks verify किए
* Terraform Plan review किया
* Files Changed review किए
* Security validation verify की
* Code review किया
* GitHub branch protection behavior validate किया
* Self-approval restriction identify की
* Repository access और Teams permissions check किए
* Dedicated reviewer/approver के लिए existing second GitHub account identify किया
* पूरे team को Write access देने के बजाय सिर्फ required user को repository-level Write access दिया
* दूसरे account से PR approval complete किया

---

# 🏗️ Pull Request Lifecycle

हमारे infrastructure deployment lifecycle में Pull Request Approval का flow:

```text
Feature Branch
      │
      ▼
Terraform CI
      │
      ├── Terraform Format
      ├── Terraform Init
      ├── Terraform Validate
      ├── Trivy Security Scan
      └── Terraform Plan
      │
      ▼
Pull Request
      │
      ▼
PR Review
      │
      ├── Checks Validation
      ├── Terraform Plan Review
      ├── Files Changed Review
      ├── Security Review
      └── Code Review
      │
      ▼
Reviewer Approval
      │
      ▼
PR Approved
      │
      ▼
Feature → main Merge
```

---

# 🎯 Current PR Status

हमारे lab में Pull Request:

```text
PR Number       : #6
PR Title        : feat: propose VNet infrastructure changes
Source Branch   : feature/vnet
Target Branch   : main
PR Author       : Shrikant-Nadgaudaa
```

PR creation के बाद GitHub ने following status दिखाया:

```text
CI Checks       : ✅ Passed
Terraform CI    : ✅ Passed
Security Scan   : ✅ Passed
Terraform Plan  : ✅ Passed
Merge Conflict  : ❌ None
Approval        : ❌ Required
Merge           : 🔒 Blocked
```

GitHub का message:

```text
Review required
At least 1 approving review is required
```

और बाद में review screen पर:

```text
Pull request authors can't approve their own pull requests.
```

यहीं से approval-related issue identify हुआ।

---

# 🔐 GitHub Review Protection

हमारे repository में Pull Request approval requirement enabled है।

इसका मतलब:

```text
PR Author
   │
   ├── PR create कर सकता है
   ├── Code review कर सकता है
   ├── Changes देख सकता है
   └── अपना PR खुद Approve ❌ नहीं कर सकता
```

GitHub जानबूझकर PR author को अपने Pull Request को approve करने से रोकता है।

इसका purpose है कि:

> जिस व्यक्ति ने infrastructure change बनाया है, वही व्यक्ति अकेले उस change को approve करके production/main branch में merge न कर सके।

इससे **four-eyes / peer-review principle** maintain होता है।

---

# 🔹 Step 1 — Pull Request Open करो

GitHub Repository खोलें:

```text
ComSolve-Cloud-Lab
        ↓
comsolve-cyberex-azure-landing-zone
        ↓
Pull requests
        ↓
PR #6
```

PR:

```text
feat: propose VNet infrastructure changes
```

Verify करें:

```text
feature/vnet → main
```

---

# 🔹 Step 2 — Checks Verify करो

PR page के **Checks** section में जाएँ।

हमारे PR में दो successful checks दिखाई दिए:

```text
Terraform CI on: push
        ✅ This job succeeded

Terraform CI on: pull_request
        ✅ This job succeeded
```

CI pipeline ने successfully execute किया:

```text
Terraform Format Check
        ↓
Terraform Init
        ↓
Terraform Validate
        ↓
Trivy IaC Security Scan
        ↓
Terraform Plan
```

### Expected

```text
All required CI checks = PASS
```

### Actual

```text
✅ PASS
```

इसका मतलब PR basic automated validation successfully complete कर चुका था।

---

# 🔹 Step 3 — Terraform Plan Review

PR में Terraform Plan result review किया गया।

हमारे CI pipeline में:

```bash
terraform plan -input=false
```

execute हुआ।

Plan में expected infrastructure changes verify किए गए।

हमारे validation के अनुसार:

```text
Resources to Add       : 16
Resources to Change    : 0
Resources to Destroy   : 0
```

इसका मतलब Terraform plan में:

```text
Create  → Expected
Change  → None
Destroy → None
```

था।

### Review Objective

Verify करना कि:

* Unexpected resource deletion नहीं है
* Unexpected modification नहीं है
* Infrastructure change expected scope में है
* Terraform plan successfully generated है

### Result

```text
Terraform Plan Review = ✅ PASS
```

---

# 🔹 Step 4 — Files Changed Review

PR में:

```text
Files changed: 94
```

दिखाई दिए।

Files Changed section में जाकर review किया गया:

```text
Pull Request
    ↓
Files changed
    ↓
Terraform files
    ↓
Module changes
    ↓
Documentation changes
```

Review के दौरान check किया गया:

* Terraform configuration
* VNet related configuration
* Terraform modules
* Variables
* Outputs
* Provider configuration
* Related documentation
* Unwanted files
* Unexpected changes

### Result

```text
Files Changed Review = ✅ PASS
```

> **Note:** PR में 76 commits और 94 changed files दिखाई देने का कारण branch में accumulated changes थे। इसलिए review करते समय केवल expected infrastructure changes पर focus किया गया।

---

# 🔹 Step 5 — Security Review

PR में Terraform Infrastructure changes के लिए security validation भी verify की गई।

हमारे CI pipeline में:

```text
Trivy IaC Security Scan
```

run हुआ।

Configuration:

```text
Scan Type : config
Severity  : HIGH, CRITICAL
Exit Code : 1
```

CI result:

```text
Misconfigurations = 0
```

इसका मतलब configured Trivy scan में कोई blocking **HIGH/CRITICAL IaC misconfiguration** नहीं मिली।

### Result

```text
Security Review = ✅ PASS
```

---

# 🔹 Step 6 — Code Review

अब reviewer को actual Terraform implementation review करनी थी।

Review के दौरान मुख्यतः verify किया गया:

```text
Terraform Structure
        ↓
Module Usage
        ↓
Resource Configuration
        ↓
Variables / Outputs
        ↓
Naming
        ↓
Dependencies
        ↓
Security
        ↓
Unwanted Changes
```

Reviewer का objective था यह confirm करना कि:

```text
Code technically acceptable है
        +
Infrastructure scope expected है
        +
CI validation successful है
        +
Security scan successful है
```

### Result

```text
Code Review = Ready for Approval
```

---

# 🔹 Step 7 — Review Decision

Review complete होने के बाद GitHub में:

```text
Review changes
```

option से review submit किया जाता है।

GitHub में तीन review events available होते हैं:

```text
Comment
Approve
Request changes
```

---

# 🔴 Request Changes

अगर reviewer को कोई blocking issue मिलता है:

```text
Request changes
```

select किया जाता है।

इसका मतलब:

```text
PR → Changes Required
```

हो जाता है और author को requested changes fix करने होते हैं।

Fix के बाद:

```text
New Commit
    ↓
CI Re-run
    ↓
Reviewer Re-review
    ↓
Approve
```

---

# 🟢 Approve

अगर reviewer satisfied है:

```text
Approve
```

select किया जाता है।

Approval का मतलब:

```text
Code Review
      +
Terraform Validation
      +
Security Validation
      +
Reviewer Acceptance
```

successfully complete है।

---

# 🔹 Step 8 — Approval Comment

Reviewer approval के साथ review comment add किया गया:

```text
Reviewed the Terraform VNet changes.

CI checks, Terraform validation, security scan, and Terraform plan have passed successfully.

No blocking issues identified.

Approved for merge.
```

इसके बाद:

```text
Review event → Approve
        ↓
Submit review
```

किया जाता है।

---

# 🔹 Step 9 — Issue Encountered: Approver Available नहीं था

Review submit करते समय एक important issue मिला।

हम PR के author account:

```text
Shrikant-Nadgaudaa
```

से logged in थे।

GitHub में **Approve** option greyed out था।

GitHub ने स्पष्ट message दिया:

```text
Pull request authors can't approve their own pull requests.
```

### इसका मतलब

PR:

```text
Author = Shrikant-Nadgaudaa
```

और वही account:

```text
Approve → ❌ Not Allowed
```

कर सकता था।

भले ही account repository/org का owner/admin हो, **PR author का self-approval allowed नहीं था**।

### Root Cause

```text
PR Author
     +
Self Approval Attempt
     ↓
GitHub Protection
     ↓
Approval Blocked
```

यह GitHub का expected security behavior था, कोई Terraform या CI failure नहीं था।

---

# 🔹 Step 10 — Reviewer / Approver Access Investigation

अब हमने check किया कि repository में कौन-कौन users और teams available हैं।

Path:

```text
Repository
    ↓
Settings
    ↓
Collaborators and teams
```

हमारे repository में following access structure मिला:

```text
Developers
DevOps-Admins
Shrikant-Nadgaudaa
```

Organization में दूसरा GitHub account पहले से मौजूद था:

```text
Shrikant-Nadgauda
```

लेकिन उसकी existing access स्थिति थी:

```text
All-repository read
```

और यह access:

```text
DevOps-Admins
```

team के माध्यम से inherited था।

---

## ❗ Problem

हमें दूसरे account से PR approve करवाना था।

लेकिन:

```text
Team Member
+
Read Access
```

approval के लिए sufficient नहीं था।

Reviewer को repository पर appropriate permission चाहिए थी।

---

## ❌ Team को Write Access क्यों नहीं दिया?

हमने यह decide किया कि:

```text
DevOps-Admins
       ↓
पूरी Team
       ↓
Write Access ❌
```

नहीं दिया जाएगा।

क्योंकि इससे team के सभी members को repository में Write permission मिल जाती।

हमारा requirement था:

```text
Only required reviewer
        ↓
Repository Write
```

इसलिए **least-privilege principle** follow किया गया।

---

# 🔹 Step 11 — Dedicated Reviewer Account Select करना

हमें organization में existing दूसरा account मिला:

```text
Shrikant-Nadgauda
```

यह account पहले से organization में मौजूद था।

इसलिए नया organization member बनाने की जरूरत नहीं पड़ी।

अब requirement:

```text
Shrikant-Nadgauda
        ↓
Repository
        ↓
Write Access
        ↓
PR Reviewer / Approver
```

रखी गई।

---

# 🔹 Step 12 — दूसरे Account को Repository-Level Write Access देना

हमने team-level permission बदलने के बजाय **individual repository access** use किया।

Target:

```text
User:
Shrikant-Nadgauda
```

Permission:

```text
Repository Role:
Write
```

Important:

```text
DevOps-Admins Team
        ↓
Read Access
        ↓
UNCHANGED
```

और:

```text
Shrikant-Nadgauda
        ↓
Direct Repository Access
        ↓
Write
```

इससे केवल required account को Write permission मिली।

### Final Access Model

```text
Organization
│
├── Developers
│      └── Existing team permissions
│
├── DevOps-Admins
│      └── Read access remains unchanged
│
└── Shrikant-Nadgauda
       └── Direct Repository Write
```

### Security Benefit

पूरी team को elevated permission देने के बजाय:

```text
Required User Only
        ↓
Required Repository
        ↓
Required Permission
```

provide की गई।

यह **least privilege** approach है।

---

# 🔹 Step 13 — Reviewer को PR में Request करना

अब दूसरे account को repository-level Write access मिलने के बाद PR review workflow continue किया गया।

PR खोलें:

```text
Pull Request #6
```

Reviewer section में:

```text
Request reviewers
```

option available होने पर authorized reviewer:

```text
Shrikant-Nadgauda
```

select किया जाता है।

Reviewer को PR review request भेजी जाती है।

---

# 🔹 Step 14 — दूसरे Account से PR Review

अब दूसरे GitHub account:

```text
Shrikant-Nadgauda
```

से login किया गया।

PR #6 open किया गया:

```text
Pull Requests
      ↓
PR #6
      ↓
Files changed
```

Reviewer ने फिर से:

```text
Files Changed
Terraform Changes
CI Checks
Terraform Plan
Security Validation
```

verify किया।

---

# 🔹 Step 15 — दूसरे Account से Approval

Reviewer account से:

```text
Files changed
      ↓
Review changes
      ↓
Approve
```

select किया गया।

Approval comment:

```text
Reviewed the Terraform VNet changes.

CI checks, Terraform validation, security scan, and Terraform plan have passed successfully.

No blocking issues identified.

Approved for merge.
```

फिर:

```text
Submit review
```

click किया गया।

### Result

```text
Reviewer Approval = ✅
```

---

# 🔹 Step 16 — Approval के बाद PR Status

Approval मिलने के बाद PR की state:

```text
CI Checks
    ↓
    ✅ Passed

Security Scan
    ↓
    ✅ Passed

Terraform Plan
    ↓
    ✅ Passed

Reviewer Approval
    ↓
    ✅ Approved
```

हो जाती है।

पहले:

```text
Merging is blocked
```

था।

Approval मिलने के बाद merge requirement satisfy होनी चाहिए।

---

# 🔹 Step 17 — Merge अभी भी तुरंत नहीं करना

⚠️ **Important**

इस phase का objective सिर्फ:

```text
Pull Request
      ↓
Review
      ↓
Approval
```

complete करना है।

इस phase में **Merge operation intentionally अलग रखा गया है**।

Merge अगले phase में होगा:

```text
Phase 25.04
Feature-to-Main Merge
```

इससे lifecycle clearly separated रहता है:

```text
Phase 25.03
PR Approval
      ↓
Phase 25.04
Feature → main Merge
```

---

# 🧪 Practical Validation

हमारे lab में validation इस sequence में की गई:

```text
1. PR Created
       ↓
2. CI Checks Verified
       ↓
3. Terraform Plan Reviewed
       ↓
4. Files Changed Reviewed
       ↓
5. Security Scan Verified
       ↓
6. Code Review Completed
       ↓
7. Approval Attempt
       ↓
8. Self-Approval Block Identified
       ↓
9. Repository Access Checked
       ↓
10. Existing Second Account Identified
       ↓
11. Team Permission Strategy Reviewed
       ↓
12. Individual Repository Write Access Provided
       ↓
13. Reviewer Requested
       ↓
14. Second Account Reviewed PR
       ↓
15. PR Approved
```

---

# 🔐 Governance Validation

इस phase में हमने यह validate किया कि:

```text
PR Author
   ↓
Cannot Self-Approve
```

और:

```text
Authorized Reviewer
   ↓
Can Review
   ↓
Can Approve
```

साथ ही:

```text
Entire Team
   ↓
No unnecessary Write Access
```

और:

```text
Required Reviewer
   ↓
Repository-Level Write Access
```

का model implement किया गया।

यह approach **separation of duties** और **least privilege** principles के अनुरूप है।

---

# 🔍 What to Validate

### 1. Pull Request

Verify करें:

```text
Source = feature/vnet
Target = main
PR = #6
```

---

### 2. CI Validation

Verify करें:

```text
Terraform CI on push
Terraform CI on pull_request
```

दोनों:

```text
✅ Passed
```

---

### 3. Terraform Plan

Verify करें:

```text
Add    = 16
Change = 0
Destroy = 0
```

---

### 4. Security Scan

Verify करें:

```text
Trivy IaC Scan
HIGH/CRITICAL blocking issues = 0
```

---

### 5. Review Requirement

Verify करें:

```text
At least 1 approving review required
```

---

### 6. Self Approval Protection

PR author account से:

```text
Approve
```

attempt करें।

Expected behavior:

```text
❌ Self-approval blocked
```

---

### 7. Reviewer Access

Verify करें:

```text
Reviewer Account
        ↓
Repository
        ↓
Write Access
```

---

### 8. Reviewer Approval

दूसरे authorized account से:

```text
Review changes
      ↓
Approve
      ↓
Submit review
```

करें।

Expected:

```text
✅ PR Approved
```

---

# ✅ Best Practice

इस phase में following best practices follow की गईं:

### 🔹 1. Self Approval Avoid करें

PR author को अपना infrastructure change approve नहीं करना चाहिए।

```text
Developer
    ↓
Create PR
    ↓
Independent Reviewer
    ↓
Approve
```

---

### 🔹 2. Least Privilege

पूरी team को Write access देने के बजाय केवल required reviewer को repository-level Write access दिया गया।

```text
Team → Read
Reviewer → Write
```

---

### 🔹 3. Separate Reviewer

PR author और reviewer अलग accounts होने चाहिए।

```text
Author ≠ Reviewer
```

---

### 🔹 4. CI Before Approval

Reviewer approval से पहले:

```text
Terraform Validation
+
Security Scan
+
Terraform Plan
```

successful होना चाहिए।

---

### 🔹 5. Merge अलग Phase में रखें

Approval और Merge को अलग lifecycle steps में रखना बेहतर है:

```text
Approval
   ↓
Merge
```

---

# 🧪 Validation Test

## Test 01 — CI Validation

PR Checks में verify करें:

```text
Terraform CI on push
Terraform CI on pull_request
```

**Expected:**

```text
✅ PASS
```

---

## Test 02 — Terraform Plan

CI result में verify करें:

```text
16 to add
0 to change
0 to destroy
```

**Expected:**

```text
✅ Expected infrastructure plan
```

---

## Test 03 — Security Scan

Trivy result verify करें।

**Expected:**

```text
HIGH/CRITICAL blocking misconfiguration
= 0
```

---

## Test 04 — Review Requirement

PR status verify करें।

**Expected:**

```text
At least 1 approving review required
```

---

## Test 05 — Self Approval Protection

PR author account से approval attempt करें।

**Expected:**

```text
❌ Author cannot approve own PR
```

---

## Test 06 — Reviewer Access

दूसरे account की repository permission verify करें।

**Expected:**

```text
Reviewer
   ↓
Direct Repository Access
   ↓
Write
```

---

## Test 07 — Reviewer Approval

Authorized reviewer से:

```text
Review changes
      ↓
Approve
      ↓
Submit review
```

करें।

**Expected:**

```text
✅ Review approved
```

---

## Test 08 — PR Ready for Merge

Approval के बाद PR status verify करें।

**Expected:**

```text
CI                  ✅
Terraform Plan      ✅
Security Scan       ✅
Required Approval   ✅
Merge Conflict      ❌ None
```

PR अब next lifecycle phase के लिए ready होना चाहिए।

---

# 🎯 Expected Result

Phase 25.03 के अंत में expected state:

```text
Pull Request
     │
     ├── Source: feature/vnet
     ├── Target: main
     │
     ├── CI Checks        ✅
     ├── Terraform Plan   ✅
     ├── Security Scan    ✅
     ├── Files Review     ✅
     ├── Code Review      ✅
     │
     ├── Self Approval    ❌ Blocked
     │
     └── Independent Reviewer
              │
              └── Approval ✅
```

Final expected state:

```text
PR #6
   ↓
Reviewed
   ↓
Approved
   ↓
Ready for Merge
```

---

# 📋 Evidence

Phase 25.03 के लिए निम्न evidence capture करें:

### Evidence 01 — PR Overview

Screenshot:

```text
PR #6
feature/vnet → main
```

---

### Evidence 02 — CI Checks

Screenshot:

```text
Terraform CI on push      ✅
Terraform CI on PR        ✅
```

---

### Evidence 03 — Terraform Plan

Screenshot/log:

```text
16 to add
0 to change
0 to destroy
```

---

### Evidence 04 — Security Scan

Screenshot/log:

```text
Trivy IaC Scan
0 blocking HIGH/CRITICAL misconfigurations
```

---

### Evidence 05 — Self Approval Block

Screenshot:

```text
Pull request authors can't approve their own pull requests.
```

---

### Evidence 06 — Repository Access

Screenshot:

```text
Shrikant-Nadgauda
Direct Repository Access
Write
```

---

### Evidence 07 — Reviewer Approval

Screenshot:

```text
Approved
```

और reviewer account का approval दिखाई देना चाहिए।

---

### Evidence 08 — Final PR Status

Screenshot:

```text
Required approval satisfied
CI passed
PR ready for merge
```

---

# 🔄 Phase Flow

```text
Phase 25.02
Pull Request Creation
        │
        ▼
Phase 25.03
Pull Request Approval
        │
        ├── CI Validation
        ├── Terraform Plan Review
        ├── Security Review
        ├── Code Review
        │
        ├── Self Approval Block
        │        ↓
        │   Access Investigation
        │        ↓
        │   Reviewer Account
        │        ↓
        │   Repository Write
        │
        └── Reviewer Approval
                 │
                 ▼
Phase 25.04
Feature-to-Main Merge
```

---

# 🏁 Phase Completion Criteria

Phase 25.03 complete माना जाएगा जब:

* [x] Pull Request successfully created
* [x] Source branch verified
* [x] Target branch verified
* [x] CI checks passed
* [x] Terraform Plan reviewed
* [x] Files Changed reviewed
* [x] Security scan verified
* [x] Code review completed
* [x] Review requirement identified
* [x] Self-approval protection validated
* [x] Repository access investigated
* [x] Existing reviewer account identified
* [x] Team-level unnecessary Write access avoided
* [x] Required reviewer को repository-level Write access दिया गया
* [x] Reviewer requested
* [x] Reviewer reviewed PR
* [x] Reviewer approval received
* [x] PR merge के लिए ready है
* [ ] Feature → main merge — **Next Phase**

---

# 📌 Final Status

```text
Phase 25.03 — Pull Request Approval

PR Created              : ✅
CI Validation            : ✅
Terraform Plan           : ✅
Security Review          : ✅
Code Review              : ✅
Self Approval Protection : ✅
Reviewer Access          : ✅
Independent Approval     : ✅
PR Ready for Merge       : ✅
```

---

# 🚀 Next Phase

## Phase 25.04 — Feature-to-Main Merge

Next phase में हम approved Pull Request को:

```text
feature/vnet
      ↓
    main
```

merge करेंगे और उसके बाद **CD / Infrastructure Deployment lifecycle** शुरू होगा।
