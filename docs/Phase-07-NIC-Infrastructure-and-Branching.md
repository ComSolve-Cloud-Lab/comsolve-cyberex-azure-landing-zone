# 🌿 Phase 07 — NIC Infrastructure & Git Branching

<p align="center">

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

</p>

> 🎯 **Objective:** Create an Azure Network Interface using a reusable Terraform Child Module while following a proper Git Feature Branch workflow.

---

# 🧭 Phase Overview

```text
Developer
    │
    ▼
🌿 Feature Branch
    │
    ▼
🧩 Terraform NIC Module
    │
    ▼
🧪 Terraform Validation
    │
    ├── terraform fmt
    ├── terraform validate
    └── terraform plan
    │
    ▼
💾 Git Commit
    │
    ▼
🐙 GitHub Push
    │
    ▼
🔀 Pull Request
    │
    ▼
👀 Code Review
    │
    ▼
main
```

---

# 🏗️ Architecture

```text
☁️ Azure
   │
   ▼
📦 Resource Group
   │
   ▼
🌐 Virtual Network
   │
   ▼
📡 Subnet
   │
   ▼
🔌 Network Interface
```

The NIC will use the existing VNet and Subnet created in previous phases.

---

# 🎯 What We Will Learn

| Area | What We Learn |
|------|---------------|
| 🌿 Git | Feature Branch |
| 🧩 Terraform | Child Module |
| 🔄 Terraform | Parent → Child communication |
| 🔌 Azure | Network Interface |
| 🧪 Terraform | fmt / validate / plan |
| 💾 Git | Commit |
| 🐙 GitHub | Push |
| 🔀 GitHub | Pull Request |
| 👀 DevOps | Code Review |

---

# 📁 Step 01 — Create NIC Module

From the project root:

```powershell
New-Item terraform\modules\nic -ItemType Directory -Force
```

Create the module files:

```powershell
New-Item terraform\modules\nic\main.tf -ItemType File -Force
New-Item terraform\modules\nic\variables.tf -ItemType File -Force
New-Item terraform\modules\nic\outputs.tf -ItemType File -Force
```

---

# 🌿 Step 02 — Create Feature Branch

We do not develop directly on the `main` branch.

First move to the latest main branch:

```powershell
git checkout main
```

Pull the latest changes:

```powershell
git pull
```

Create the feature branch:

```powershell
git checkout -b feature/nic-infrastructure
```

Verify the current branch:

```powershell
git branch
```

Expected:

```text
* feature/nic-infrastructure
  main
```

The `*` indicates the current branch.

---

# 🧠 Why Feature Branch?

Direct development on `main` is avoided.

Instead:

```text
main
 │
 └── feature/nic-infrastructure
```

Development happens inside the feature branch.

After testing and review:

```text
feature/nic-infrastructure
          │
          ▼
     Pull Request
          │
          ▼
       Review
          │
          ▼
         main
```

This protects the main infrastructure code.

---

# 🧩 Step 03 — Terraform NIC Module

The NIC is implemented as a reusable Child Module.

```text
terraform/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
└── modules/
    │
    ├── resource-group/
    ├── vnet/
    ├── subnet/
    │
    └── nic/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

# 👨‍👦 Parent → Child Module Flow

The root Terraform configuration acts as the Parent.

The NIC module acts as the Child.

```text
terraform/main.tf
        │
        │ calls
        ▼
modules/nic
        │
        ├── variables.tf
        ├── main.tf
        └── outputs.tf
```

The Parent provides the required values.

The Child creates the Azure resource.

---

# 🔌 Step 04 — NIC Configuration

The NIC module requires information such as:

```text
NIC Name
    │
    ├── Resource Group
    ├── Azure Location
    ├── Virtual Network
    └── Subnet
```

The NIC is connected to the existing subnet.

```text
VNet
 │
 └── Subnet
       │
       └── NIC
```

---

# 🔗 Step 05 — Connect NIC Module

The root `main.tf` calls the NIC Child Module.

The module receives:

```text
NIC Name
Resource Group
Location
VNet/Subnet information
```

This keeps the actual Azure resource creation inside the Child Module.

---

# ⚙️ Step 06 — Terraform Formatting

From the Terraform directory:

```powershell
cd terraform
```

Run:

```powershell
terraform fmt -recursive
```

### 🎯 Purpose

Automatically formats Terraform files according to Terraform's standard formatting rules.

---

# 🔍 Step 07 — Terraform Validation

Run:

```powershell
terraform validate
```

### 🎯 Purpose

Checks whether the Terraform configuration is syntactically and structurally valid.

Expected:

```text
Success! The configuration is valid.
```

---

# 📋 Step 08 — Terraform Plan

Run:

```powershell
terraform plan
```

Terraform will calculate the infrastructure changes.

Example:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

### ⚠️ Important

`terraform plan` does NOT create the resource.

It only shows what Terraform intends to create, modify, or destroy.

---

# 💾 Step 09 — Check Git Changes

Return to project root:

```powershell
cd ..
```

Check:

```powershell
git status
```

Review the modified and new files.

---

# ➕ Step 10 — Stage Changes

```powershell
git add .
```

This stages the changes for commit.

---

# 💾 Step 11 — Create Commit

Use a meaningful commit message:

```powershell
git commit -m "feat: add Azure network interface module"
```

### 🧠 Commit Convention

```text
feat:     New feature
fix:      Bug fix
docs:     Documentation
chore:    Maintenance
refactor: Code restructuring
```

Example:

```text
feat: add Azure network interface module
```

---

# 🚀 Step 12 — Push Feature Branch

Push the branch to GitHub:

```powershell
git push -u origin feature/nic-infrastructure
```

Now the branch exists locally and remotely.

```text
Local Git
    │
    │ push
    ▼
🐙 GitHub
    │
    └── feature/nic-infrastructure
```

---

# 🔀 Step 13 — Create Pull Request

Open the GitHub repository.

Select:

```text
feature/nic-infrastructure
```

GitHub will provide the option:

```text
Compare & pull request
```

Click it.

---

# 📝 Pull Request

Use:

### Title

```text
feat: add Azure network interface infrastructure
```

### Description

```markdown
## 🎯 Objective

Add Azure Network Interface infrastructure using a reusable Terraform Child Module.

## 🔧 Changes

- Added NIC Terraform module
- Connected NIC with existing subnet
- Added Terraform variables
- Added module integration
- Validated Terraform configuration

## 🧪 Validation

- terraform fmt
- terraform validate
- terraform plan

## 🔐 Security

No secrets or credentials are committed to the repository.
```

---

# 👀 Step 14 — Code Review

The Pull Request should be reviewed before merging.

Review:

```text
☑ Terraform code
☑ Variable configuration
☑ Module structure
☑ Naming convention
☑ Terraform plan
☑ No secrets
☑ No unnecessary hard-coded values
```

---

# ✅ Step 15 — Merge to Main

After successful review:

```text
feature/nic-infrastructure
          │
          ▼
     Pull Request
          │
          ▼
      Code Review
          │
          ▼
        Approved
          │
          ▼
         main
```

Merge the Pull Request into `main`.

---

# 🧹 Step 16 — Update Local Main

After merging:

```powershell
git checkout main
```

Pull the latest changes:

```powershell
git pull
```

Now local `main` contains the NIC implementation.

---

# 🗑️ Step 17 — Delete Feature Branch

After successful merge:

```powershell
git branch -d feature/nic-infrastructure
```

If the remote branch also needs to be deleted:

```powershell
git push origin --delete feature/nic-infrastructure
```

---

# 🔌 Step 18 — Azure Network Interface

## 🧠 What is an Azure NIC?

**NIC = Network Interface Card**

An Azure Network Interface provides network connectivity to Azure Virtual Machines and other compute resources.

```text
☁️ Azure VM
    │
    ▼
🔌 Network Interface
    │
    ▼
🌐 Subnet
    │
    ▼
🌐 Virtual Network
```

The NIC can provide:

- Private IP address
- Subnet connectivity
- Network Security Group association
- Public IP association
- Network connectivity for Azure compute resources

> 💡 In this phase, we create a **private Network Interface** only.

---

# 📁 Step 19 — NIC Module Structure

```text
terraform/
│
├── main.tf
├── variables.tf
├── terraform.tfvars
│
└── modules/
    │
    └── nic/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

# 🧩 Step 20 — NIC Child Module

The NIC is implemented as a reusable Terraform Child Module.

```text
Parent Module
     │
     ▼
modules/nic
     │
     ├── variables.tf
     ├── main.tf
     └── outputs.tf
```

The Child Module receives:

```text
NIC Name
Azure Location
Resource Group
Subnet ID
```
```text

🧠 इसका मतलब

Child module बोल रहा है:

मुझे NIC बनाने के लिए 4 चीजें चाहिए।

nic_name
location
resource_group_name
subnet_id

Parent module ये values देगा।

```

---

# 🔌 Step 21 — Network Interface Configuration

The NIC contains an IP configuration.

```text
Network Interface
       │
       ▼
IP Configuration
       │
       ├── Configuration Name
       ├── Subnet ID
       └── Private IP Allocation
```

The private IP address is configured as:

```text
Dynamic
```

Azure automatically assigns an available private IP from the selected subnet.

---
```text

🧠 इसे समझ

सबसे ऊपर:

resource "azurerm_network_interface" "Nic"

Terraform को बोलता है:

Azure में Network Interface create करो।

फिर:

name = var.nic_name

NIC का नाम Parent से आएगा।

location = var.location

Azure region Parent से आएगा।

resource_group_name = var.resource_group_name

NIC किस RG में बनेगा, वो Parent बताएगा।

```

```text

🌐 ip_configuration

यह NIC का सबसे important हिस्सा है।

ip_configuration {

मतलब NIC की network configuration।

subnet_id = var.subnet_id

यह NIC को हमारे Phase 06 वाले existing subnet से connect करेगा।

और:

private_ip_address_allocation = "Dynamic"

मतलब Azure subnet के available IP pool से private IP automatically assign करेगा।

Example:

Subnet
10.10.1.0/24
     │
     ├── 10.10.1.4
     ├── 10.10.1.5
     ├── 10.10.1.6  ← NIC
     └── ...

```
----


# 🔗 Step 22 — NIC to Subnet Connection

The NIC is connected to the existing subnet created during Phase 06.

```text
Phase 06
   │
   ▼
VNet
   │
   ▼
Subnet
   │
   │ Subnet ID
   ▼
Phase 07
   │
   ▼
NIC
```

This demonstrates how Terraform modules can exchange resource information using outputs.

---

# 📤 Step 23 — NIC Outputs

The NIC module exposes useful information through Terraform outputs.

```text
NIC Module
    │
    ├── NIC ID
    │
    └── Private IP Address
```

These outputs can be consumed by future modules.

For example:

```text
NIC
 │
 └── NIC ID
       │
       ▼
    Azure VM
```


```text
🧠 Output क्यों?

मान लो आगे Phase में VM बनाते हैं।

VM को NIC चाहिए।

तो Parent को NIC की information चाहिए होगी।

हम Child से निकाल सकते हैं:

NIC Child
   │
   ├── nic_id
   └── private_ip_address

फिर Parent इसे दूसरे module में भेज सकता है।

यही Terraform modules का असली फायदा है। 🔥

```

---

# 🧪 Step 24 — Terraform Validation

Format the Terraform code:

```powershell
terraform fmt -recursive
```

Initialize Terraform:

```powershell
terraform init
```

Validate the configuration:

```powershell
terraform validate
```

Generate the execution plan:

```powershell
terraform plan
```

Expected result:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

> ⚠️ `terraform plan` only previews the changes. It does not create the Azure resource.

---

# 💾 Step 25 — Commit NIC Implementation

Check the changes:

```powershell
git status
```

Stage the files:

```powershell
git add .
```

Create the commit:

```powershell
git commit -m "feat: implement Azure network interface"
```

Push the feature branch:

```powershell
git push
```

---

# 🔀 Step 26 — Update Pull Request

The existing Pull Request will automatically receive the latest commit.

```text
feature/nic-infrastructure
          │
          ▼
      New Commit
          │
          ▼
       Git Push
          │
          ▼
     Existing PR
          │
          ▼
     Code Review
```

---

# 🎯 Phase 07 Final Architecture

```text
☁️ Azure
   │
   ▼
📦 Resource Group
   │
   ▼
🌐 VNet
   │
   ▼
🌐 Subnet
   │
   ▼
🔌 Network Interface
```

---

# 🏆 Phase 07 Skills Completed

- 🌿 Git Feature Branch
- 🧩 Terraform Child Module
- 👨‍👦 Parent → Child Module communication
- 🔌 Azure Network Interface
- 🌐 NIC → Subnet association
- 📤 Terraform Outputs
- 🧪 Terraform Format
- 🔍 Terraform Validate
- 📋 Terraform Plan
- 💾 Git Commit
- 🚀 Git Push
- 🔀 Pull Request
- 👀 Infrastructure Code Review

---


# 🧠 Complete Git Workflow

```text
                    main
                     │
                     │
             create feature branch
                     │
                     ▼
          feature/nic-infrastructure
                     │
                     ▼
               Write Code
                     │
                     ▼
             terraform fmt
                     │
                     ▼
          terraform validate
                     │
                     ▼
             terraform plan
                     │
                     ▼
                  commit
                     │
                     ▼
                  push
                     │
                     ▼
              Pull Request
                     │
                     ▼
                Code Review
                     │
                     ▼
                  Approved
                     │
                     ▼
                 Merge main
                     │
                     ▼
                    main
```

---

# 🎓 Key Concepts Learned

### 🌿 Feature Branch

Allows development without directly modifying `main`.

### 🧩 Terraform Module

Makes infrastructure reusable and maintainable.

### 🧪 Terraform Validation

Checks formatting, syntax and configuration before deployment.

### 📋 Terraform Plan

Shows the infrastructure changes before applying them.

### 🔀 Pull Request

Provides a controlled mechanism for reviewing infrastructure changes.

### 👀 Code Review

Ensures infrastructure changes are reviewed before reaching `main`.

---

# 🚀 What's Next?

## Phase 08 — GitHub Actions Terraform CI

In the next phase we will automate the Terraform validation process.

```text
Git Push
   │
   ▼
🐙 GitHub Actions
   │
   ├── Terraform Init
   ├── Terraform Format Check
   ├── Terraform Validate
   └── Terraform Plan
```

> 🔥 **Phase 08 will introduce our first Infrastructure CI Pipeline.**