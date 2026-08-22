# 🔐 Phase 12 — GitHub Actions + Azure OIDC Authentication

<p align="center">

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-Automation-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

![Microsoft Azure](https://img.shields.io/badge/Microsoft%20Azure-Cloud-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)

![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?style=for-the-badge&logo=terraform&logoColor=white)

![OIDC](https://img.shields.io/badge/OIDC-Passwordless%20Authentication-success?style=for-the-badge)

</p>

---

# 🎯 Phase Objective

इस Phase में हम GitHub Actions को Microsoft Azure के साथ **secure OIDC authentication** के माध्यम से connect करेंगे।

इसका मुख्य उद्देश्य है:

- 🔐 Client Secret के बिना Azure authentication

- 🐙 GitHub Actions से Azure Login

- 🪪 Microsoft Entra ID Federated Identity Credential का उपयोग

- ☁️ Azure Subscription authentication verify करना

- 🏗️ Terraform को authenticated Azure environment में चलाना

- 📋 Terraform Plan को CI pipeline में execute करना

---

# 🧭 हमारा Starting Point

Phase 11 से पहले हमारी pipeline का flow था:

```text

🐙 GitHub
     │
     ▼
⚙️ GitHub Actions Runner
     │
     ▼
📥 Checkout Repository
     │
     ▼
🏗️ Setup Terraform
     │
     ▼
✨ Terraform fmt
     │
     ▼
📦 Terraform init
     │
     ▼
✅ Terraform validate
     │
     ▼
📋 Terraform plan

```
---

# 🚀 Updated terraform-ci.yml


अपने existing YAML को इससे replace कर सकते हो:

```text

        uses: actions/checkout@v4


      # ------------------------------------------------------------------------
      # Step 02 — Azure OIDC Login
      # ------------------------------------------------------------------------


      - name: Azure Login


        uses: azure/login@v2


        with:


          client-id: ${{ vars.AZURE_CLIENT_ID }}


          tenant-id: ${{ vars.AZURE_TENANT_ID }}


          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}


      # ------------------------------------------------------------------------
      # Step 03 — Verify Azure Login
      # ------------------------------------------------------------------------


      - name: Verify Azure Login


        run: az account show


      # ------------------------------------------------------------------------
      # Step 04 — Verify Azure Subscription
      # ------------------------------------------------------------------------


      - name: Verify Azure Subscription


        run: az account show --query "{subscription:id, tenant:tenantId, user:user.name}"


      # ------------------------------------------------------------------------
      # Step 05 — Setup Terraform
      # ------------------------------------------------------------------------


      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3


      # ------------------------------------------------------------------------
      # Step 06 — Terraform Format Check
      # ------------------------------------------------------------------------


      - name: Terraform Format Check
        run: terraform fmt -check -recursive


      # ------------------------------------------------------------------------
      # Step 07 — Terraform Init
      # ------------------------------------------------------------------------


      - name: Terraform Init
        run: terraform init


      # ------------------------------------------------------------------------
      # Step 08 — Terraform Validate
      # ------------------------------------------------------------------------


      - name: Terraform Validate
        run: terraform validate


      # ------------------------------------------------------------------------
      # Step 09 — Terraform Plan
      # ------------------------------------------------------------------------


      - name: Terraform Plan
        run: terraform plan -input=false
        # ------------------------------------------------------------------------

```
**🧠 अब इसे समझो — कहाँ क्या हो रहा है?**

---

# 🔐 Step 01 — permissions

तुम्हारे पुराने YAML में था:

permissions:
  contents: read

अब इसे:

permissions:
  contents: read
  id-token: write

कर दिया।

contents: read

GitHub Actions को repository का code पढ़ने देता है।

मतलब:

```text

GitHub Repository
       ↓
GitHub Runner
       ↓
Code Checkout
id-token: write
```

यह सबसे important line है।

GitHub Runner को OIDC token request करने की permission मिलती है।

```text

GitHub Runner
     ↓
OIDC Token
     ↓
Microsoft Entra ID
```

यही Azure authentication की foundation है। 🔐

---

**OIDC Authentication क्यों?**

Traditional authentication में GitHub को Azure credentials देने पड़ते हैं:
```text

GitHub
   │
   ├── Client ID
   ├── Tenant ID
   ├── Subscription ID
   └── Client Secret ❌
```

इस approach में Client Secret एक long-lived credential हो सकता है।

OIDC approach में:

```text

GitHub Actions
      │
      ▼
OIDC Token
      │
      ▼
Microsoft Entra ID
      │
      ▼
Federated Identity Credential
      │
      ▼
Azure Access
```

इसलिए हमें repository में Azure Client Secret रखने की आवश्यकता नहीं रहती।

---

**🛡️ OIDC Permission**

GitHub Actions workflow में यह permission जरूरी है:

permissions:


  contents: read


  id-token: write
contents: read

Repository का code checkout करने के लिए।

```text

GitHub Repository
        ↓
GitHub Runner
        ↓
Checkout Code
id-token: write
```

GitHub Actions को OIDC token request करने की permission देता है।

```text

GitHub Runner
      ↓
OIDC Token
      ↓
Microsoft Entra ID

```

🔥 id-token: write OIDC authentication का सबसे important permission है।

----

# 🔑 Step 02 — Azure Login

यह नया step है:

- name: Azure Login


  uses: azure/login@v2


  with:


    client-id: ${{ vars.AZURE_CLIENT_ID }}


    tenant-id: ${{ vars.AZURE_TENANT_ID }}


    subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}

इसका मतलब:

"GitHub Runner, Microsoft Entra ID में बने हमारे Application/Service Principal के साथ OIDC के जरिए Azure में login करो।"

यहाँ तीन values कहाँ से आएंगी?

GitHub में:

```text

Repository
   ↓
Settings
   ↓
Secrets and variables
   ↓
Actions
   ↓
Variables
```

वहाँ:

Variable  -------------------------------------> Value

AZURE_CLIENT_ID -------------------------------> App Registration → Application (client) ID

AZURE_TENANT_ID -------------------------------> Azure → Directory (tenant) ID

AZURE_SUBSCRIPTION_ID ---------------------------> Azure Subscription ID


⚠️ Client Secret यहाँ नहीं चाहिए।

क्योंकि हम OIDC/Federated Identity इस्तेमाल कर रहे हैं।

---

# 🧪 Step 03 — Verify Azure Login

- name: Verify Azure Login
  run: az account show

यह सिर्फ testing के लिए है।

यह पूछता है:

"Azure Login के बाद अभी कौन-सा Azure account authenticated है?"

अगर authentication successful है तो Azure account की information आएगी।

अगर यहाँ fail हुआ:

Azure Login
     ❌

तो आगे Terraform चलाने का कोई फायदा नहीं।

---

# 🔎 Step 04 — Subscription Verify

```text

- name: Verify Azure Subscription
  run: az account show --query "{subscription:id, tenant:tenantId, user:user.name}"

```

यह थोड़ा साफ output देने के लिए है।

यह तीन चीजें check करता है:

```text

Subscription ID

Tenant ID

Authenticated Identity

```

इससे troubleshooting में बहुत फायदा होगा।

---

# 🏗️ Step 05 — Setup Terraform

```text

- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3

```

GitHub Runner temporary machine है।

इसलिए Terraform पहले से installed मानकर नहीं चलेंगे।

यह action Runner में Terraform CLI setup करता है।

```text

Flow:

GitHub Runner
     ↓
setup-terraform@v3
     ↓
Terraform CLI Ready

```

---

# ✨ Step 06 — Terraform Format Check

```text

- name: Terraform Format Check
  run: terraform fmt -check -recursive

```

यह Terraform code की formatting check करता है।

अगर developer ने खराब formatting के साथ code push किया:

```text

terraform fmt
      ↓
Formatting Issue
      ↓
❌ Pipeline Fail

```

-check का मतलब:

Code को modify नहीं करता।

"Code को खुद format मत करो, सिर्फ check करो।"

-recursive का मतलब:

Terraform modules के अंदर भी formatting check करता है।

Main Terraform directory के अंदर modules में भी check करो।

```text

terraform/
   │
   ├── main.tf
   ├── variables.tf
   │
   └── modules/
        ├── resource-group/
        ├── vnet/
        ├── subnet/
        └── nic/
```
---

# 📦 Step 07 — Terraform Init

```text

- name: Terraform Init
  run: terraform init
```

यह Terraform project initialize करता है।

इसमें मुख्य रूप से:

```text

Terraform
   │
   ├── Modules
   │
   ├── Provider
   │
   └── Dependencies

```

initialize होते हैं।

तुम्हारे Azure project में azurerm provider और modules यहाँ initialize होंगे।

---

# ✅ Step 08 — Terraform Validate

```text

- name: Terraform Validate
  run: terraform validate
```


यह check करता है कि Terraform configuration syntactically और structurally valid है या नहीं।

```text

Example:

❌ Invalid Terraform syntaxWrong variable

❌ Invalid Terraform syntaxWrong argument

❌ Invalid Terraform syntaxInvalid Terraform syntax

❌ Invalid Terraform syntaxModule issue

```
अगर configuration valid है:

Success! The configuration is valid.

⚠️ terraform validate Azure में resources create नहीं करता।

तो यहाँ failure आ सकता है।


---

# 📋 Step 09 — Terraform Plan

```text

- name: Terraform Plan
  run: terraform plan -input=false

```

यह सबसे important step है।

Terraform Azure को देखकर calculate करता है:

Terraform Azure infrastructure का proposed change calculate करेगा।

Flow:

```text

Current Azure State
        +
Terraform Configuration
        ↓
Terraform Plan
        ↓
What Terraform wants to create/change/destroy


Example:

Plan: 1 to add
      0 to change
      0 to destroy
-input=false क्यों?
``` 
यही तुम्हारे पुराने 5 घंटे pipeline stuck होने वाले issue से directly related है। 🔥

पहले:

terraform plan

अगर कोई required variable GitHub Runner environment में missing थी, Terraform input मांग सकता था:

var.nic_location

और Runner input का इंतजार करता रह सकता था।

अब:

terraform plan -input=false

**🛑-input=false क्यों लगाया?**

का मतलब:

"Terraform, कोई interactive input मत मांगना।"

Local machine पर Terraform user से input मांग सकता है।

लेकिन GitHub Runner में कोई manually input देने वाला नहीं है।

इससे workflow कई घंटे चल सकता है।

इसलिए:

```text

terraform plan -input=false

```

use करते हैं।

इसका मतलब:

Terraform किसी interactive input का इंतजार मत करो।

Variable missing है तो तुरंत:

❌ Error

देकर pipeline fail होगी।

अगर variable missing है:

```text

Missing Variable
      ↓
❌ Immediate Failure

```

यह CI/CD के लिए ज्यादा safe और predictable behavior है।


**🏆 पूरा Final Flow**

अब तुम्हारी Phase 11 pipeline का flow यह है:

```text

🐙 GitHub
     │
     ▼
⚙️ GitHub Actions Runner
     │
     ▼
📥 Checkout Repository
     │
     ▼
🔐 OIDC Permission
     │
     ▼
🔑 Azure Login
     │
     ▼
🧪 Azure Account Verify
     │
     ▼
🔎 Subscription Verify
     │
     ▼
🏗️ Setup Terraform
     │
     ▼
✨ Terraform fmt
     │
     ▼
📦 Terraform init
     │
     ▼
✅ Terraform validate
     │
     ▼
📋 Terraform plan -input=false
     │
     ▼
☁️ Azure
```

**सबसे important बात ❤️**

इस Phase में हम Azure में कुछ Apply नहीं कर रहे हैं।

अभी pipeline का काम है:

"Code सही है? Terraform सही है? Azure authentication सही है? और क्या infrastructure बनाया जाएगा?"

बस यह verify करना।

अगले चरण में इसी foundation के ऊपर security scanning + Plan artifact + PR checks + approval + main branch Apply बनाएँगे।

----

# 🎓 What We Learned

इस Phase में हमने सीखा:

🔐 GitHub OIDC Authentication

🪪 Federated Identity Credential

👤 Azure App Registration

🔑 Azure Login Action

📦 GitHub Repository Variables

🛡️ id-token: write

🧪 Azure Authentication Verification

☁️ Azure Subscription Verification

🏗️ Terraform CI Integration

✨ Terraform Format Check

📦 Terraform Init

✅ Terraform Validate

📋 Terraform Plan

🛑 terraform plan -input=false

🔒 Passwordless Azure Authentication
---