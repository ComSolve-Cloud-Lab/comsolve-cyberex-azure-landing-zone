# 🔐 Phase 01 — Azure App Registration

<p align="center">

![Microsoft Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Microsoft Entra ID](https://img.shields.io/badge/Microsoft%20Entra%20ID-5E5CE6?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Service Principal](https://img.shields.io/badge/Service%20Principal-Identity-success?style=for-the-badge)

</p>

> 🎯 **Objective:** Create a dedicated Azure identity for GitHub Actions to securely authenticate with Azure and manage infrastructure through Terraform.

---

## 🧭 Phase Overview

```text
                         ☁️ MICROSOFT AZURE
                                  │
                                  ▼
                         🆔 App Registration
                                  │
                                  ▼
                         👤 Service Principal
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
                    ▼             ▼             ▼
              🆔 Client ID    🆔 Tenant ID   🔐 Secret
                    │             │             │
                    └─────────────┼─────────────┘
                                  ▼
                         🎭 Azure RBAC
                                  │
                             Contributor
                                  │
                                  ▼
                       ☁️ Azure Subscription



🎯 Objective

The objective of this phase is to create a dedicated Microsoft Entra ID App Registration / Service Principal that will be used by GitHub Actions for Azure authentication.

This identity will later be used by:

⚙️ GitHub Actions
🏗️ Terraform
☁️ Azure Resource Deployment
🔐 Infrastructure Automation
🏗️ What We Created
Component	Configuration
🆔 App Registration	Shrikant_Nadgauda_GitHub_Actions
🏢 Tenant Model	Single Tenant
👤 Service Principal	Shrikant_Nadgauda_GitHub_Actions
🎭 Azure RBAC	Contributor
📍 RBAC Scope	Azure Subscription
🔄 Redirect URI	Not configured
🔐 Authentication	Client Credentials
🟦 Step 01 — Open App Registrations

Navigate to:

Azure Portal
   ↓
Microsoft Entra ID
   ↓
App registrations
   ↓
New registration

Click:

➕ New registration

🟦 Step 02 — Register the Application
📝 Application Name

Enter:

Shrikant_Nadgauda_GitHub_Actions
👤 Supported Account Types

Select:

Single tenant only - Default Directory
🔄 Redirect URI

Leave:

❌ Empty

Redirect URI is not required for this GitHub Actions authentication design.

Then click:

🟢 Register

🟦 Step 03 — Application Overview

After registration, open:

App registrations
   ↓
Shrikant_Nadgauda_GitHub_Actions
   ↓
Overview

Record the following:

🆔 Application (Client) ID
666a02fd-9186-4647-bcac-b9fd1943a1e7
🆔 Directory (Tenant) ID
402a28d6-9ea1-462e-8338-dc09423ff348
🆔 Object ID
26321fcc-5286-46f1-893e-202526f54094
🔐 Step 04 — Create Client Secret

Navigate to:

App Registration
   ↓
Certificates & secrets
   ↓
Client secrets
   ↓
New client secret
📝 Description
GitHub_Actions_Learning
⏳ Expiration

For the learning environment:

12 Months

Click:

🟢 Add

🚨 Step 05 — Secure the Client Secret

After creating the secret, Azure displays:

Secret ID
Value
Expires
⚠️ Important

The Secret Value must be copied immediately.

Azure does not display the complete secret value again after leaving the page.

❌ Never commit the secret to Git
❌ Terraform files
❌ YAML files
❌ README
❌ .tfvars
❌ GitHub repository
❌ Screenshots

The secret will later be stored securely in:

🐙 GitHub
   ↓
Settings
   ↓
Secrets and variables
   ↓
Actions
🟦 Step 06 — Verify Service Principal

Open:

App Registration
   ↓
Overview
   ↓
Managed application in local directory

Expected:

Shrikant_Nadgauda_GitHub_Actions

This represents the application's Service Principal in the Azure tenant.

🟦 Step 07 — Get Azure Subscription ID

Navigate:

Azure Portal
   ↓
Subscriptions
   ↓
Azure subscription 1
   ↓
Overview

Subscription ID:

7cf9c45e-0a1e-4828-9c98-3e8f25397732
🟦 Step 08 — Assign Contributor Role

Navigate:

Subscriptions
   ↓
Azure subscription 1
   ↓
Access control (IAM)
   ↓
Add
   ↓
Add role assignment
🎭 Role

Select:

Contributor
👤 Assign Access To

Select:

User, group, or service principal
🔍 Member

Search:

Shrikant_Nadgauda_GitHub_Actions

Select the Service Principal.

📍 Scope

Select:

Subscription

Then:

🟢 Review + assign

🟦 Step 09 — Verify RBAC

Navigate:

Azure subscription 1
   ↓
Access control (IAM)
   ↓
Check access

Search:

Shrikant_Nadgauda_GitHub_Actions

Expected:

Property	Value
👤 Identity	Shrikant_Nadgauda_GitHub_Actions
🎭 Role	Contributor
📍 Scope	Azure Subscription
🔑 Authentication Information

The following values are required for the next phase:

Variable	Purpose
AZURE_CLIENT_ID	Identifies the App Registration
AZURE_CLIENT_SECRET	Authenticates the Service Principal
AZURE_TENANT_ID	Identifies the Azure tenant
AZURE_SUBSCRIPTION_ID	Identifies the Azure subscription
🛡️ Security Notes
🔐 Principle of Least Privilege

The Service Principal currently has:

Contributor
   ↓
Subscription Scope

This is acceptable for the initial learning environment.

For a production implementation, permissions should be evaluated and reduced according to actual deployment requirements.

🚨 Secret Protection

Never expose:

AZURE_CLIENT_SECRET

in source code, Git commits, logs or documentation.

✅ Phase 01 Checklist
 🆔 App Registration created
 🏢 Single Tenant configured
 🔄 Redirect URI left empty
 🆔 Client ID obtained
 🆔 Tenant ID obtained
 🔐 Client Secret created
 👤 Service Principal verified
 🆔 Subscription ID obtained
 🎭 Contributor role assigned
 📍 Subscription scope configured
 🔍 RBAC access verified
🏁 Phase Status
<p align="center">
🟢 COMPLETED

Azure Identity Foundation Successfully Configured

</p>