# 🏗️ Phase 03 — Terraform Foundation & Azure Core Infrastructure

<p align="center">

![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Infrastructure as Code](https://img.shields.io/badge/Infrastructure-as--Code-success?style=for-the-badge)
![Modules](https://img.shields.io/badge/Terraform-Modules-blue?style=for-the-badge)
![For Each](https://img.shields.io/badge/Terraform-for__each-orange?style=for-the-badge)

</p>

# 🎯 Phase Objective

The objective of Phase 03 is to start building the actual Azure Landing Zone infrastructure using **Terraform Infrastructure as Code (IaC)**.

In this phase we will establish the Terraform foundation using:

- 🏗️ Parent Module
- 🧩 Child Modules
- ♻️ Reusable Terraform Modules
- 🔄 `for_each`
- ☁️ Azure Resource Groups
- 🌐 Azure Virtual Network
- 🧩 Azure Subnets
- 🌍 Azure Public IPs
- 🏷️ Standardized Naming
- 🏷️ Resource Tagging

---

# 🧭 Phase Architecture

```text
                         🐙 GitHub
                            │
                            ▼
                     📁 Terraform Code
                            │
                            ▼
                    🏗️ Parent Module
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ▼                 ▼                 ▼
     Child Module      Child Module      Child Module
    Resource Group        VNet             Subnet
          │                 │                 │
          ▼                 ▼                 ▼
       3 × RG              1 × VNet          5 × Subnet
                            │
                            ▼
                      Public IP Module
                            │
                            ▼
                         2 × PIP