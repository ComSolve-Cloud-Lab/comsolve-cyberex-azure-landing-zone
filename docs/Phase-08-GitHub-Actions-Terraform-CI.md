# ⚙️ Phase 08 — GitHub Actions Terraform CI

<p align="center">

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![CI](https://img.shields.io/badge/CI-Automated-success?style=for-the-badge)

</p>

> 🚀 **Objective:** Automate Terraform validation using GitHub Actions.

---

# 🧭 Phase Overview

```text
👨‍💻 Developer
      │
      ▼
🌿 Feature Branch
      │
      │ git push
      ▼
🐙 GitHub
      │
      ▼
⚙️ GitHub Actions
      │
      ▼
🖥️ Ubuntu Runner
      │
      ├── 📥 Checkout
      ├── 🏗️ Terraform Setup
      ├── 🎨 Format Check
      ├── 🔧 Terraform Init
      ├── 🔍 Terraform Validate
      └── 📋 Terraform Plan
      │
      ▼
✅ CI Result
```

---

# 🎯 What We Learn

| Concept | Purpose |
|---|---|
| ⚙️ GitHub Actions | Automation |
| 📄 YAML | Pipeline configuration |
| 🖥️ Runner | Executes pipeline |
| 📥 Checkout | Downloads repository |
| 🏗️ Terraform Setup | Installs Terraform |
| 🎨 Format Check | Code formatting validation |
| 🔧 Terraform Init | Initialize Terraform |
| 🔍 Validate | Validate configuration |
| 📋 Plan | Preview infrastructure changes |

---

# 📁 Project Structure

```text
comsolve-cyberex-azure-landing-zone/
│
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
│
├── docs/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   │
│   └── modules/
│
├── .gitignore
└── README.md
```

---

# ⚙️ Step 01 — Create GitHub Actions Directory

```powershell
New-Item .github\workflows -ItemType Directory -Force
```

---

# 📄 Step 02 — Create Workflow

```powershell
New-Item .github\workflows\terraform-ci.yml -ItemType File -Force
```

GitHub automatically detects workflow files stored inside:

```text
.github/workflows/
```

---

# 🧠 Step 03 — Understand YAML

YAML is used to define the GitHub Actions workflow.

The workflow defines:

```text
WHEN should it run?
        │
        ▼
WHAT should it do?
        │
        ▼
WHERE should it run?
        │
        ▼
WHAT commands should execute?
```

---

# 🚦 Step 04 — Workflow Trigger

The workflow runs when:

### 🌿 Feature Branch Push

```text
feature/*
```

A push to a feature branch starts CI.

### 🔀 Pull Request

A Pull Request targeting `main` also starts CI.

```text
feature branch
      │
      ▼
Pull Request
      │
      ▼
main
```

---

# 🔐 Step 05 — Security Permission

The workflow uses:

```text
contents: read
```

The pipeline only needs to read repository contents at this stage.

This follows the principle of:

> 🔐 Least Privilege

---

# 🖥️ Step 06 — GitHub Runner

The workflow runs on:

```text
ubuntu-latest
```

GitHub provides a temporary Ubuntu runner.

```text
GitHub
   │
   ▼
Ubuntu Runner
   │
   ▼
Execute Terraform
```

---

# 📁 Step 07 — Terraform Working Directory

Terraform code exists inside:

```text
terraform/
```

The workflow therefore uses the Terraform directory as its working directory.

This allows commands such as:

```text
terraform init
terraform validate
terraform plan
```

to execute against the correct Terraform configuration.

---

# 📥 Step 08 — Checkout Repository

GitHub Actions checks out the repository using:

```text
actions/checkout
```

Flow:

```text
GitHub Repository
       │
       ▼
Ubuntu Runner
       │
       ▼
Terraform Source Code
```

---

# 🏗️ Step 09 — Setup Terraform

The workflow uses the HashiCorp Terraform setup action.

Purpose:

```text
Install / configure Terraform
        │
        ▼
Terraform CLI available
```

---

# 🎨 Step 10 — Terraform Format Check

Command:

```text
terraform fmt -check -recursive
```

Purpose:

```text
Check Terraform formatting
```

Unlike:

```text
terraform fmt
```

the CI command does not modify the developer's code.

It only checks whether the code is properly formatted.

---

# 🔧 Step 11 — Terraform Init

Command:

```text
terraform init
```

Purpose:

```text
Initialize Terraform
        │
        ├── Providers
        ├── Modules
        └── Backend configuration
```

---

# 🔍 Step 12 — Terraform Validate

Command:

```text
terraform validate
```

Purpose:

```text
Check Terraform configuration
```

It helps identify:

- Syntax problems
- Invalid arguments
- Invalid references
- Configuration issues

---

# 📋 Step 13 — Terraform Plan

Command:

```text
terraform plan
```

Purpose:

> Preview the infrastructure changes before deployment.

Example:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

⚠️ **No `terraform apply` exists in this pipeline.**

Therefore this CI pipeline does not deploy infrastructure.

---

# 🔄 Complete CI Workflow

```text
Git Push
   │
   ▼
GitHub Actions
   │
   ▼
Checkout
   │
   ▼
Terraform Setup
   │
   ▼
Format Check
   │
   ▼
Terraform Init
   │
   ▼
Terraform Validate
   │
   ▼
Terraform Plan
   │
   ▼
✅ PASS
```

---

# 🧪 Step 14 — Run the Pipeline

Commit the workflow:

```powershell
git add .github\workflows\terraform-ci.yml
```

```powershell
git commit -m "ci: add Terraform GitHub Actions pipeline"
```

Push:

```powershell
git push
```

Then open:

```text
GitHub Repository
      │
      ▼
Actions
      │
      ▼
Terraform CI
```

---

# 👀 Step 15 — Pipeline Result

A successful pipeline should show:

```text
✅ Checkout Repository
✅ Setup Terraform
✅ Terraform Format Check
✅ Terraform Init
✅ Terraform Validate
✅ Terraform Plan
```

---

# ❌ What Happens When CI Fails?

```text
Developer
   │
   ▼
Push Code
   │
   ▼
GitHub Actions
   │
   ▼
❌ Failed Step
   │
   ▼
Read Error
   │
   ▼
Fix Terraform
   │
   ▼
Commit
   │
   ▼
Push
   │
   ▼
🔄 Pipeline Runs Again
```

This is the basic **Continuous Integration loop**.

---

# 🏆 Phase 08 Completed

- ⚙️ GitHub Actions
- 📄 YAML Workflow
- 🖥️ GitHub Runner
- 📥 Repository Checkout
- 🏗️ Terraform Setup
- 🎨 Terraform Format Check
- 🔧 Terraform Init
- 🔍 Terraform Validate
- 📋 Terraform Plan
- 🔄 Automated CI

---

# 🚀 Next Phase

## 🔐 Phase 09 — Terraform Security Scanning

The next phase will introduce automated security checks.

```text
Terraform Code
      │
      ▼
GitHub Actions
      │
      ├── Terraform Format
      ├── Terraform Validate
      ├── Terraform Plan
      │
      ├── 🔐 Security Scan
      ├── 🔍 IaC Analysis
      └── 🔑 Secret Detection
      │
      ▼
     ✅ / ❌
```

> 🔥 **Phase 08 is our first CI foundation. Phase 09 turns it into DevSecOps.**