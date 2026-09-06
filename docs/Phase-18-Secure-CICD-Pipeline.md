# 🚀 Phase 18 — Secure CI/CD Pipeline

<p align="center">

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Trivy](https://img.shields.io/badge/Trivy-IaC%20Security%20Scanning-1904DA?style=for-the-badge)
![Microsoft Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![OIDC](https://img.shields.io/badge/Azure%20OIDC-Passwordless%20Authentication-success?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-Enabled-success?style=for-the-badge)

</p>

> 🎯 **Objective:** Terraform-based Azure Infrastructure के लिए एक **secure, reliable और production-ready CI/CD pipeline** तैयार करना, जिसमें code validation, security scanning, Azure authentication, Terraform planning और Pull Request security controls properly integrated हों।

---

## 📌 Phase Overview

Phase 18 में हमारा focus सिर्फ pipeline को **run करवाना** नहीं है।

अब हमारा goal है कि pipeline:

- 🔍 Terraform code को validate करे
- 🔐 Infrastructure security scan करे
- ☁️ Azure से securely authenticate करे
- 📋 Terraform Plan generate करे
- 🚫 Security issue मिलने पर pipeline को fail करे
- 🔄 Pull Request पर automatically execute हो
- 🔑 Long-lived Azure credentials avoid करे
- 🛡️ Infrastructure deployment से पहले security gate provide करे

---

# 🏗️ Current CI/CD Flow

```text
Developer
    │
    ▼
GitHub Feature Branch
    │
    ▼
Pull Request → main
    │
    ▼
GitHub Actions
    │
    ├── Checkout
    │
    ├── Azure OIDC Login
    │
    ├── Terraform Setup
    │
    ├── Terraform Format Check
    │
    ├── Terraform Init
    │
    ├── Terraform Validate
    │
    ├── Trivy IaC Security Scan
    │
    └── Terraform Plan
            │
            ▼
       Security Gate
            │
       ┌────┴────┐
       ▼         ▼
     PASS       FAIL
       │         │
       ▼         ▼
   Continue     Stop
```

---

🔐 18.1 — Secure Azure Authentication

हमने Azure authentication के लिए GitHub Actions में:

permissions:
  contents: read
  id-token: write

और:

- name: Azure Login
  uses: azure/login@v2
  with:
    client-id: ${{ vars.AZURE_CLIENT_ID }}
    tenant-id: ${{ vars.AZURE_TENANT_ID }}
    subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}

का उपयोग किया।

इसका फायदा

Azure credentials को code में hard-code करने की आवश्यकता नहीं है।

GitHub Actions
      │
      │ OIDC Token
      ▼
Microsoft Entra ID
      │
      ▼
Azure Service Principal
      │
      ▼
Azure Subscription

यह traditional static password/secret-based authentication की तुलना में ज्यादा secure approach है।

🔍 18.2 — Terraform Code Validation

Pipeline में Terraform validation stages:

terraform fmt -check -recursive
terraform init
terraform validate

इनका उद्देश्य:

Terraform Format

Code proper Terraform formatting follow कर रहा है या नहीं।

Terraform Init

Required providers और modules properly initialize हो रहे हैं या नहीं।

Terraform Validate

Terraform configuration syntactically और structurally valid है या नहीं।

🛡️ 18.3 — Trivy IaC Security Scan

Checkov troubleshooting के बाद हमने Checkov को CI pipeline से remove किया और Trivy को primary IaC security scanner के रूप में continue किया।

Pipeline में:

- name: Trivy IaC Security Scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: config
    scan-ref: terraform
    severity: HIGH,CRITICAL
    exit-code: 1
Trivy क्या check करता है?

Trivy Terraform/IaC configuration में security misconfigurations detect करता है।

Example:

Terraform Code
      │
      ▼
    Trivy
      │
      ├── Network Security
      ├── Public Exposure
      ├── Identity / Access
      ├── Encryption
      ├── Cloud Configuration
      └── Other IaC Misconfigurations

अगर configured severity में finding आती है:

HIGH
CRITICAL

तो:

exit-code: 1

के कारण pipeline fail हो सकती है।

📋 18.4 — Terraform Plan

Security scan successfully complete होने के बाद:

- name: Terraform Plan
  run: terraform plan -input=false

execute होता है।

इससे Terraform Azure infrastructure में proposed changes दिखाता है।

Example:

Plan: 16 to add, 0 to change, 0 to destroy.

इसका मतलब Terraform ने:

16 Resources → Create
0 Resources  → Modify
0 Resources  → Destroy

identify किए।

🚦 18.5 — Security Gate

हमारी pipeline में security gate का basic principle:

Terraform Validation
        │
        ▼
Trivy Security Scan
        │
        ├── Security Finding
        │       │
        │       ▼
        │    Pipeline FAIL
        │
        └── No Finding
                │
                ▼
        Terraform Plan

इसका फायदा यह है कि insecure Terraform configuration को आगे जाने से रोका जा सकता है।

🔄 18.6 — Pull Request Security

Workflow में:

pull_request:
  branches:
    - main

configured है।

इसका मतलब जब feature branch से main के लिए Pull Request बनाई जाएगी, तब CI pipeline automatically execute हो सकती है।

feature/nic-infrastructure
             │
             ▼
       Pull Request
             │
             ▼
           main
             │
             ▼
      GitHub Actions
             │
      ┌──────┴──────┐
      ▼             ▼
   Security       Terraform
     Scan           Plan

इससे code merge होने से पहले validation और security checks किए जा सकते हैं।

🧹 18.7 — Checkov Removal

Previous phases में Checkov के साथ extensive troubleshooting की गई।

Final decision:

Checkov
   │
   └── Removed from CI Pipeline

और:

Trivy
   │
   └── Continued as IaC Security Scanner

इसका कारण Checkov को skip करना नहीं था।

हमने actual Checkov behavior troubleshoot किया, लेकिन CKV2_AZURE_31 के कारण repeated false/incorrect association detection का issue हमारे module structure के साथ resolve नहीं हुआ।

इसलिए pipeline को unnecessarily block करने के बजाय Trivy-based security scanning approach continue की गई।

### 🧪 Step 18.8 — Successful Pipeline Verification

Phase 16.3 में updated pipeline successfully execute हुई।

#### 📊 Trivy Scan Summary

| Target | Type | Misconfigurations | Status |
| :--- | :--- | :-: | :--- |
| **`.` (Root)** | `terraform` | **0** | ![Passed](https://img.shields.io/badge/Scan-PASSED-brightgreen?style=flat-square) |
| **`modules/public-ip`** | `terraform` | **0** | ![Passed](https://img.shields.io/badge/Scan-PASSED-brightgreen?style=flat-square) |

```text
Target              Type          Misconfigurations
----------------------------------------------------
.                   terraform             0
modules/public-ip   terraform             0
```

---

Terraform Plan
Plan: 16 to add, 0 to change, 0 to destroy.

इससे confirm हुआ कि:

Terraform Validation  → PASS
Trivy Security Scan   → PASS
Terraform Plan        → PASS
CI Pipeline           → PASS
🎯 Phase 18 Target Architecture

Phase 18 के बाद हमारा desired CI flow:

Developer
    │
    ▼
Feature Branch
    │
    ▼
Pull Request
    │
    ▼
GitHub Actions
    │
    ├── Checkout
    │
    ├── Azure OIDC Authentication
    │
    ├── Terraform Format
    │
    ├── Terraform Init
    │
    ├── Terraform Validate
    │
    ├── Trivy IaC Scan
    │
    └── Terraform Plan
             │
             ▼
        Security Gate
             │
       ┌─────┴─────┐
       ▼           ▼
     PASS         FAIL
       │           │
       ▼           ▼
   PR Continue   PR Block

---

# 📊 Phase 18 Status

| Component | Status |
| :--- | :--- |
| **GitHub Actions** | ![Status](https://img.shields.io/badge/Status-Configured-brightgreen?style=flat-square) |
| **Azure OIDC** | ![Status](https://img.shields.io/badge/Status-Configured-brightgreen?style=flat-square) |
| **Terraform Format** | ![Status](https://img.shields.io/badge/Status-Configured-brightgreen?style=flat-square) |
| **Terraform Init** | ![Status](https://img.shields.io/badge/Status-Configured-brightgreen?style=flat-square) |
| **Terraform Validate** | ![Status](https://img.shields.io/badge/Status-Configured-brightgreen?style=flat-square) |
| **Checkov** | ![Status](https://img.shields.io/badge/Status-Removed-red?style=flat-square) |
| **Trivy IaC Scan** | ![Status](https://img.shields.io/badge/Status-Configured-brightgreen?style=flat-square) |
| **Terraform Plan** | ![Status](https://img.shields.io/badge/Status-Working-brightgreen?style=flat-square) |
| **Security Gate** | ![Status](https://img.shields.io/badge/Status-Implemented-brightgreen?style=flat-square) |
| **Pull Request Trigger** | ![Status](https://img.shields.io/badge/Status-Configured-brightgreen?style=flat-square) |
| **Azure Infrastructure Deployment** | ![Status](https://img.shields.io/badge/Status-Next_Stage-blue?style=flat-square) |

---

# 🚧 Important: CI ≠ CD

अभी हमारी pipeline मुख्य रूप से CI + Security Validation + Terraform Plan तक है।

हमने अभी जानबूझकर:

terraform apply

को automatic CI pipeline में नहीं डाला है।

Current architecture:

Code
  ↓
Validate
  ↓
Security Scan
  ↓
Terraform Plan
  ↓
Review

Future production flow:

Code
  ↓
PR
  ↓
Security Scan
  ↓
Terraform Plan
  ↓
Approval
  ↓
Terraform Apply
  ↓
Azure Infrastructure
🏁 Phase 18 Outcome

Phase 18 का मुख्य outcome:

हमने Terraform Infrastructure के लिए एक secure CI pipeline foundation तैयार कर लिया है जिसमें GitHub Actions + Azure OIDC + Terraform Validation + Trivy IaC Security Scan + Terraform Plan + Security Gate integrated हैं।

अब अगला focus होगा:

Phase 19
   ↓
Monitoring / Observability

जहाँ हम infrastructure और CI/CD pipeline की visibility, logging, monitoring और operational awareness पर काम करेंगे।

---

