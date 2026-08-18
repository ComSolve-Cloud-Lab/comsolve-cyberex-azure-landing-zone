# 📁 Phase 04 — Terraform Project Structure

<p align="center">

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Infrastructure](https://img.shields.io/badge/Infrastructure-as--Code-success?style=for-the-badge)
![Modules](https://img.shields.io/badge/Architecture-Modules-blue?style=for-the-badge)
![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)

</p>

> 🎯 **Objective:** Establish a clean, scalable and reusable Terraform project structure using Parent and Child Modules.

---

## 🧭 Phase Overview

```text
🏗️ Terraform Root Module
        │
        ├── 📄 main.tf
        ├── 📄 providers.tf
        ├── 📄 variables.tf
        ├── 📄 locals.tf
        ├── 📄 outputs.tf
        │
        └── 📦 modules
              │
              ├── 📦 resource-group
              │     ├── main.tf
              │     ├── variables.tf
              │     └── outputs.tf
              │
              ├── 📦 vnet
              │     ├── main.tf
              │     ├── variables.tf
              │     └── outputs.tf
              │
              ├── 📦 subnet
              │     ├── main.tf
              │     ├── variables.tf
              │     └── outputs.tf
              │
              └── 📦 public-ip
                    ├── main.tf
                    ├── variables.tf
                    └── outputs.tf



📂 Step 01 — Create Terraform Directory

From the project root:

mkdir terraform
📦 Step 02 — Create Module Directories
mkdir terraform\modules
mkdir terraform\modules\resource-group
mkdir terraform\modules\vnet
mkdir terraform\modules\subnet
mkdir terraform\modules\public-ip
📄 Step 03 — Create Root Terraform Files
New-Item terraform\main.tf -ItemType File
New-Item terraform\providers.tf -ItemType File
New-Item terraform\variables.tf -ItemType File
New-Item terraform\locals.tf -ItemType File
New-Item terraform\outputs.tf -ItemType File
📄 Step 04 — Create Resource Group Module Files
New-Item terraform\modules\resource-group\main.tf -ItemType File
New-Item terraform\modules\resource-group\variables.tf -ItemType File
New-Item terraform\modules\resource-group\outputs.tf -ItemType File
📄 Step 05 — Create VNet Module Files
New-Item terraform\modules\vnet\main.tf -ItemType File
New-Item terraform\modules\vnet\variables.tf -ItemType File
New-Item terraform\modules\vnet\outputs.tf -ItemType File
📄 Step 06 — Create Subnet Module Files
New-Item terraform\modules\subnet\main.tf -ItemType File
New-Item terraform\modules\subnet\variables.tf -ItemType File
New-Item terraform\modules\subnet\outputs.tf -ItemType File
📄 Step 07 — Create Public IP Module Files
New-Item terraform\modules\public-ip\main.tf -ItemType File
New-Item terraform\modules\public-ip\variables.tf -ItemType File
New-Item terraform\modules\public-ip\outputs.tf -ItemType File
🔍 Step 08 — Verify Project Structure

Run:

tree terraform /F

Expected structure:

terraform
│
├── locals.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
│
└── modules
    │
    ├── public-ip
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    ├── resource-group
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    ├── subnet
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    └── vnet
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
🐙 Step 09 — Push Structure to GitHub

At this stage, Terraform code will not be added yet.

Only the project structure will be committed.

git add terraform
git commit -m "chore: add terraform project structure"
git push
🎯 Phase Completion
Component	Status
📁 Terraform Root	✅ Created
📦 Modules Directory	✅ Created
📦 Resource Group Module	✅ Created
📦 VNet Module	✅ Created
📦 Subnet Module	✅ Created
📦 Public IP Module	✅ Created
🐙 GitHub Push	✅ Completed
🏗️ Terraform Code	⏳ Next Phase
📝 One-Line Phase Comment

Phase 04 establishes a scalable Terraform folder structure using reusable Parent and Child Modules for future Azure infrastructure deployment.

⏭️ Next Phase
🏗️ Phase 05 — Terraform Provider & Azure Authentication

In the next phase we will start writing the actual Terraform code:

☁️ Azure Provider
        ↓
🔐 Azure Authentication
        ↓
📦 Resource Groups
        ↓
🌐 Virtual Network
        ↓
🧩 Subnets
        ↓
🌍 Public IPs

