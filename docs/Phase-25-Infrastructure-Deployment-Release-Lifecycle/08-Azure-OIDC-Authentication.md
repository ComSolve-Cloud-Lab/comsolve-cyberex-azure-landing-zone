# 🚀 Phase 25.08 — Terraform CD Plan

<p align="center">

![Terraform](https://img.shields.io/badge/Terraform-Plan-623CE4)
![CI/CD](https://img.shields.io/badge/CD-Automated-blue)
![Status](https://img.shields.io/badge/Status-Completed-success)

</p>

## 🎯 Objective

इस stage में Terraform configuration और current infrastructure state को compare करके deployment plan generate किया जाता है।

---

## 🔄 Execution Flow

```text
Terraform Configuration
        +
Remote Terraform State
        +
Azure Infrastructure
        ↓
terraform plan
        ↓
Terraform Execution Plan
        ↓
Saved tfplan Artifact
```

---

## 🔧 CD Command

```powershell
terraform plan -out=tfplan -input=false
```

### 🧠 Purpose

Terraform deployment plan को `tfplan` file में save करता है।

`-input=false` automated pipeline execution को non-interactive रखता है।

---

## 📦 Plan Artifact

Generated plan को GitHub Actions artifact के रूप में store किया जाता है।

```text
terraform-plan
      ↓
tfplan
```

---

## 🔐 Deployment Safety

Apply stage नया plan generate नहीं करता।

वही **reviewed and approved `tfplan`** आगे Apply stage में use होता है।

---

## 🏁 Outcome

Terraform CD Plan successfully generated and stored as a deployment artifact.


---