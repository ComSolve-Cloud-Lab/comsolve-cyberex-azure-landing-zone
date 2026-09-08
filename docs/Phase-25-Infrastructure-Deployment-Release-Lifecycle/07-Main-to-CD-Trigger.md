# 🚀 Phase 25.07 — Terraform CD Init

<p align="center">

![Terraform](https://img.shields.io/badge/Terraform-CD-623CE4)
![Backend](https://img.shields.io/badge/Backend-Azure%20Storage-0078D4)
![Status](https://img.shields.io/badge/Status-Completed-success)

</p>

## 🎯 Objective

इस stage का उद्देश्य CD runner पर Terraform को initialize करना और configured **remote backend** के साथ Terraform working environment तैयार करना है।

---

## 🔄 Execution Flow

```text
GitHub Actions Runner
        ↓
Checkout Repository
        ↓
Azure OIDC Login
        ↓
Setup Terraform
        ↓
terraform init
        ↓
Azure Remote Backend
        ↓
Terraform Working Environment Ready
```

---

## 🔐 Remote Backend

Terraform state Azure Storage Account में maintain किया जाता है।

| Component       | Value                          |
| --------------- | ------------------------------ |
| Storage Account | `cyberexterraformstate`        |
| Container       | `tfstate`                      |
| State Key       | `cyberex-landing-zone.tfstate` |

---

## 🔧 CD Command

```powershell
terraform init
```

### 🧠 Purpose

Required Terraform providers और configured remote backend को initialize करता है।

---

## ✅ Validation

Successful initialization confirms:

* Terraform backend reachable है।
* Required provider available है।
* CD runner Terraform execution के लिए ready है।

---

## 🏁 Outcome

**Terraform CD initialization completed successfully.**

---