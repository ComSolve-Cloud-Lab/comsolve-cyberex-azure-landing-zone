# 🐙 Phase 02 — GitHub Repository & Secrets

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Microsoft Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Security](https://img.shields.io/badge/Security-First-success?style=for-the-badge)

</p>

> 🎯 **Objective:** Establish a secure authentication foundation between GitHub Actions and Microsoft Azure for future Terraform-based infrastructure automation.

---

# 🧭 Phase Overview

```text
                         🐙 GITHUB
                            │
                            ▼
                    📦 GitHub Repository
                            │
                            ▼
                   ⚙️ GitHub Actions
                            │
                            ▼
                    🔐 GitHub Secrets
                            │
              ┌─────────────┼─────────────┐
              │             │             │
              ▼             ▼             ▼
        Client ID       Tenant ID    Subscription ID
              │
              ▼
        Client Secret
              │
              └─────────────┬─────────────┘
                            ▼
                    Microsoft Entra ID
                            │
                            ▼
                  👤 Service Principal
                            │
                       🎭 Contributor
                            │
                            ▼
                     ☁️ Azure
🎯 Objective

The objective of this phase is to prepare the GitHub repository for secure Azure authentication.

The Azure identity created in Phase 01 will be used by GitHub Actions for future:

⚙️ GitHub Actions automation
🏗️ Terraform execution
☁️ Azure infrastructure deployment
🔐 Secure authentication
🚀 Infrastructure CI/CD
📦 Repository Information
Property	Value
🏢 Organization / Owner	Shrikant-Nadgaudaa
📦 Repository	comsolve-cyberex-azure-landing-zone
☁️ Cloud Platform	Microsoft Azure
🏗️ IaC	Terraform
⚙️ CI/CD	GitHub Actions
🔐 Identity Provider	Microsoft Entra ID
🎯 Purpose	Azure Landing Zone
🟦 Step 01 — GitHub Repository

The GitHub repository was created for managing the Azure Landing Zone infrastructure.

Repository Name
comsolve-cyberex-azure-landing-zone
Repository Purpose

The repository will contain:

☁️ Azure Infrastructure
🏗️ Terraform Modules
🔐 Security Configuration
🏛️ Governance Configuration
📋 Compliance Controls
⚙️ GitHub Actions Workflows
📚 Infrastructure Documentation
🟦 Step 02 — Repository Security

For the learning and infrastructure project, the repository is maintained as:

🔒 Private Repository

This provides an additional layer of protection for infrastructure source code and configuration.

🟦 Step 03 — Open GitHub Actions Secrets

Navigate to:

GitHub Repository
        │
        ▼
    Settings
        │
        ▼
Secrets and variables
        │
        ▼
      Actions

Then select:

New repository secret

🔐 Step 04 — Configure Azure Secrets

The following four values are required for the initial authentication model.

Secret Name	Purpose
AZURE_CLIENT_ID	Identifies Azure App Registration
AZURE_CLIENT_SECRET	Authenticates Service Principal
AZURE_TENANT_ID	Identifies Microsoft Entra tenant
AZURE_SUBSCRIPTION_ID	Identifies Azure subscription
🔐 Secret 01 — AZURE_CLIENT_ID
Name
AZURE_CLIENT_ID
Value
666a02fd-9186-4647-bcac-b9fd1943a1e7
Purpose

Identifies the Azure App Registration created in Phase 01.

🔐 Secret 02 — AZURE_CLIENT_SECRET
Name
AZURE_CLIENT_SECRET
Value
<AZURE_CLIENT_SECRET_VALUE>

⚠️ Replace the placeholder with the actual secret value generated in Azure.

🚨 Security Warning

The actual secret value must never be added to:

❌ README.md
❌ Terraform files
❌ YAML files
❌ .tfvars files
❌ Git commits
❌ Screenshots
❌ Documentation

Store it only inside GitHub encrypted secrets.

🔐 Secret 03 — AZURE_TENANT_ID
Name
AZURE_TENANT_ID
Value
402a28d6-9ea1-462e-8338-dc09423ff348
Purpose

Identifies the Microsoft Entra ID tenant.

🔐 Secret 04 — AZURE_SUBSCRIPTION_ID
Name
AZURE_SUBSCRIPTION_ID
Value
7cf9c45e-0a1e-4828-9c98-3e8f25397732
Purpose

Identifies the Azure subscription where infrastructure will be deployed.

📋 Final GitHub Secrets

After configuration, the repository should contain:

Secret	Status
AZURE_CLIENT_ID	✅ Configured
AZURE_CLIENT_SECRET	✅ Configured
AZURE_TENANT_ID	✅ Configured
AZURE_SUBSCRIPTION_ID	✅ Configured

🔒 GitHub encrypts and protects repository secrets. Secret values are not displayed after they are stored.

🔄 Authentication Flow
                    👨‍💻 Developer
                          │
                          ▼
                     🐙 GitHub
                          │
                          ▼
                  ⚙️ GitHub Actions
                          │
                          ▼
                   🔐 GitHub Secrets
                          │
             ┌────────────┼────────────┐
             │            │            │
             ▼            ▼            ▼
        Client ID      Tenant ID   Subscription ID
             │
             ▼
       Client Secret
             │
             ▼
      Microsoft Entra ID
             │
             ▼
     👤 Service Principal
             │
        🎭 Contributor
             │
             ▼
          ☁️ Azure
🏗️ Future Terraform Flow

The secrets configured in this phase will later support the following automation flow:

                    🐙 GitHub
                        │
                        ▼
                 ⚙️ GitHub Actions
                        │
                        ▼
                 🔐 Azure Login
                        │
                        ▼
                   🏗️ Terraform
                        │
                 ┌──────┴──────┐
                 │             │
                 ▼             ▼
            Terraform Plan  Validation
                 │
                 ▼
             Approval
                 │
                 ▼
          Terraform Apply
                 │
                 ▼
             ☁️ Azure
                 │
                 ▼
       🏗️ Landing Zone Infrastructure
🛡️ Security Principles
🔐 1. Never Hard-Code Credentials

Credentials must never be written directly inside workflows.

❌ Incorrect
client_secret: "my-secret-value"
✅ Correct
client_secret: ${{ secrets.AZURE_CLIENT_SECRET }}
🔐 2. Never Commit Secrets

Never commit:

.env
*.tfvars
*.tfvars.json
client secrets
passwords
API keys
private keys
certificates
🎭 3. Least Privilege

The current Service Principal has:

Role:
Contributor


Scope:
Azure Subscription

This configuration is being used for the initial learning environment.

For production implementation, permissions should be reviewed and reduced according to the actual infrastructure requirements.

🔍 Verification Checklist
GitHub
 🐙 Repository created
 🔒 Repository configured as Private
 ⚙️ GitHub Actions settings opened
 🔐 Repository secrets configured
Azure
 🆔 Client ID available
 🆔 Tenant ID available
 🆔 Subscription ID available
 👤 Service Principal available
 🎭 Contributor role assigned
Security
 🔐 Client Secret stored as GitHub Secret
 🚫 Secret not committed to Git
 🚫 Secret not stored in README
 🚫 Secret not hard-coded in workflow
📊 Phase Completion
Area	Status
🐙 GitHub Repository	✅ Completed
⚙️ GitHub Actions Configuration	✅ Prepared
🔐 Repository Secrets	✅ Completed
🆔 Azure Identity	✅ Completed
🎭 Azure RBAC	✅ Completed
🏗️ Terraform Integration	⏳ Next Phase
🚀 CI/CD Pipeline	⏳ Future
🏁 Phase Status
<p align="center">
🟢 PHASE 02 COMPLETED
GitHub → Azure Authentication Foundation Ready 🚀
</p>
⏭️ Next Phase
🌿 Phase 03 — Repository & Branching Strategy

The next phase will cover:

🌿 main branch
🧪 Development branch
🚀 Feature branches
🔀 Pull Requests
👀 Code Review
🔒 Branch Protection
🏷️ Commit Strategy
📦 Repository Structure
⚙️ GitHub Actions Workflow Structure
<p align="center">

🔐 Secure by Design • 🏗️ Infrastructure as Code • ⚙️ Automation First

</p> ```
🔥 अब बस 3 काम कर
पुरानी phase-02-github-repository-secrets.md की पूरी content delete कर।
ऊपर वाला पूरा content एक साथ paste कर।
Save Ctrl + S.

फिर terminal:

git add docs/phase-02-github-repository-secrets.md
git commit -m "docs: improve phase 2 github secrets documentation"
git push

बस। इस बार GitHub पर Phase 02 proper headings, badges, tables और diagrams के साथ render होना चाहिए। 🚀