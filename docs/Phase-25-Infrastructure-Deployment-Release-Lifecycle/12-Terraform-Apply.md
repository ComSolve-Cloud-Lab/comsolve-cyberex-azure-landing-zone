# 🚀 Phase 25.09 — Terraform CD Apply

<p align="center">

![Terraform](https://img.shields.io/badge/Terraform-Apply-623CE4)
![Deployment](https://img.shields.io/badge/Deployment-Controlled-orange)
![Status](https://img.shields.io/badge/Status-Completed-success)

</p>

## 🎯 Objective

Approved Terraform execution plan को Azure infrastructure पर apply करना।

---

## 🔄 Execution Flow

```text
terraform-plan
      ↓
Deployment Approval
      ↓
Download tfplan
      ↓
terraform apply tfplan
      ↓
Azure Infrastructure
```

---

## 📥 Plan Retrieval

CD Apply job पहले generated plan artifact download करता है।

```text
terraform-plan
      ↓
tfplan
```

---

## 🔧 Apply Command

```powershell
terraform apply -input=false tfplan
```

### 🧠 Purpose

Previously generated exact Terraform plan को execute करता है।

---

## 🔐 Safety Control

Local machine से:

```text
❌ terraform apply
```

perform नहीं किया गया।

Deployment GitHub Actions CD pipeline के controlled workflow से execute किया गया।

---

## 🏁 Outcome

Terraform Apply stage successfully executed through the controlled CD pipeline.

---