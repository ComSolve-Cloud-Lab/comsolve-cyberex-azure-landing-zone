# 🔐 Phase 01 — Checkov Troubleshooting & Decision History

<p align="center">

![Checkov](https://img.shields.io/badge/Checkov-IaC%20Security%20Scanning-blue?style=for-the-badge)

![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-623CE4?style=for-the-badge&logo=terraform&logoColor=white)

![Microsoft Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

![Trivy](https://img.shields.io/badge/Trivy-IaC%20Security%20Scanning-1904DA?style=for-the-badge)

</p>

> 🎯 **Objective:** Document the complete Checkov troubleshooting journey, commands executed, Terraform configuration changes, errors encountered, investigation performed, and the final decision to remove Checkov from the CI pipeline.

---

## 📌 Project

**Project:** ComSolve Cyberex Azure Landing Zone  
**Repository:** `comsolve-cyberex-azure-landing-zone`  
**Branch:** `feature/nic-infrastructure`

---

# 📖 1. Background

इस project में Azure Landing Zone infrastructure को **Terraform** के माध्यम से deploy किया जा रहा है।

Infrastructure को secure और production-oriented रखने के लिए CI pipeline में multiple validation और security scanning tools integrate किए गए थे।

Initial CI pipeline में मुख्य stages थे:

```text
GitHub
   │
   ▼
GitHub Actions
   │
   ├── Azure OIDC Login
   │
   ├── Terraform Format
   │
   ├── Terraform Init
   │
   ├── Terraform Validate
   │
   ├── Checkov Security Scan
   │
   ├── Trivy IaC Security Scan
   │
   └── Terraform Plan

```
---

# 1. Phase Objective

इस phase का उद्देश्य Terraform CI pipeline में Checkov security scanning को successfully integrate करना था।

Initial objective:

```text
Developer
   ↓
GitHub Feature Branch
   ↓
GitHub Actions
   ↓
Terraform Format
   ↓
Terraform Init
   ↓
Terraform Validate
   ↓
Checkov Security Scan
   ↓
Trivy IaC Security Scan
   ↓
Terraform Plan

इस phase में मुख्य समस्या यह थी कि Terraform configuration technically valid होने के बावजूद Checkov का:

CKV2_AZURE_31

लगातार 5 subnet resources पर FAILED हो रहा था।

2. Initial Terraform Architecture

हमारे Terraform project में infrastructure को modules में divide किया गया है।

Current module structure:

terraform/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── locals.tf
├── providers.tf
│
└── modules/
    │
    ├── resource-group/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── vnet/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── subnet/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── nsg/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── nic/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── output.tf
    │
    └── public-ip/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
3. Terraform Provider Environment

Terraform version:

Terraform v1.14.6

AzureRM provider:

hashicorp/azurerm v5.1.0

Provider configuration:

terraform {

  required_version = ">= 1.6.0"

  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.1.0"
    }

  }
}

provider "azurerm" {

  features {}

}

Terraform lock file में भी AzureRM provider version:

5.1.0

locked था।

4. Network Architecture

Current VNet:

VNet
Name:
vnet-comsolve-cyberex-dev

Address Space:
10.10.0.0/16

Subnets:

web
10.10.1.0/24

application
10.10.2.0/24

data
10.10.3.0/24

management
10.10.4.0/24

security
10.10.5.0/24
5. NSG Architecture

एक Network Security Group module बनाया गया:

Module:
modules/nsg/

NSG:

Name:
cyberex-nsg

Resource Group:

rg-comsolve-cyberex-network

NSG module:

resource "azurerm_network_security_group" "this" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

NSG का output:

output "id" {

  description = "NSG resource ID"

  value = azurerm_network_security_group.this.id
}

इसका मतलब root module को NSG ID मिलती है:

module.nsg.id
6. Subnet Architecture

Subnet module में subnets for_each के द्वारा create किए गए हैं।

Current subnet resource:

resource "azurerm_subnet" "Subnets" {

  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes = each.value.address_prefixes
}

Subnet module variables:

variable "subnets" {

  description = "Subnet configuration"

  type = map(object({

    name             = string
    address_prefixes = list(string)

  }))
}

variable "virtual_network_name" {

  description = "Virtual Network name"

  type = string
}

variable "resource_group_name" {

  description = "Resource Group name"

  type = string
}

variable "network_security_group_id" {

  description = "Network Security Group ID associated with subnets"

  type = string
}
7. NSG Association Implementation

Subnet को NSG से associate करने के लिए अलग Terraform resource इस्तेमाल किया गया:

resource "azurerm_subnet_network_security_group_association" "this" {

  for_each = azurerm_subnet.Subnets

  subnet_id                 = each.value.id
  network_security_group_id = var.network_security_group_id
}

यह architecture intentionally अलग resource के रूप में रखा गया।

Concept:

azurerm_subnet
       │
       │ subnet_id
       ▼
azurerm_subnet_network_security_group_association
       │
       │ network_security_group_id
       ▼
azurerm_network_security_group
8. Root Module में NSG Association

Root main.tf में subnet module को NSG ID दी गई:

module "subnets" {

  source = "./modules/subnet"

  subnets = var.subnets

  virtual_network_name = var.vnet_name

  resource_group_name = var.resource_groups["network"].name

  depends_on = [
    module.vnet
  ]

  network_security_group_id = module.nsg.id
}

NSG module:

module "nsg" {

  source = "./modules/nsg"

  name                = "cyberex-nsg"
  location            = var.nic_location
  resource_group_name = var.resource_groups["network"].name

  tags = {
    Environment = "Development"
    Project     = "Cyberex"
    ManagedBy   = "Terraform"
  }
}
9. Initial Git Status

Troubleshooting के दौरान branch:

feature/nic-infrastructure

Current branch status:

On branch feature/nic-infrastructure

Your branch is up to date with
'origin/feature/nic-infrastructure'.

nothing to commit, working tree clean

Command used:

git status
10. Git Commit History Check

Troubleshooting के दौरान recent commits verify किए गए:

git log --oneline --all -10

Relevant commits:

9ceceb0 chore: re-enable Terraform CI workflow
2f80d21 Implement NSG for subnet security
eb1535b update phase 21 -6
ed40961 update phase 21 -5
4c225b7 update phase 21 -4
473db9a update phase 21 -3
0c79515 update phase 21 -2
834c2bf update phase 21 email signature
c284366 adding phase 21 devops email signature
2080014 Add Phase 16 security gate and pull request security

Important commit:

2f80d21 Implement NSG for subnet security

इस commit में subnet security / NSG implementation से संबंधित changes थे।

11. First Checkov Problem

Checkov scan के दौरान result:

Passed checks: 9
Failed checks: 5
Skipped checks: 0

Failed check:

CKV2_AZURE_31

Description:

Ensure VNET subnet is configured with a Network Security Group (NSG)

Failed resources:

module.subnets.azurerm_subnet.Subnets["web"]

module.subnets.azurerm_subnet.Subnets["application"]

module.subnets.azurerm_subnet.Subnets["data"]

module.subnets.azurerm_subnet.Subnets["management"]

module.subnets.azurerm_subnet.Subnets["security"]

Important observation:

सभी 5 subnets fail हो रहे थे।

12. Initial Interpretation

पहले यह possibility consider की गई:

Checkov शायद NSG association detect नहीं कर रहा है।

क्योंकि Terraform में association resource मौजूद था:

resource "azurerm_subnet_network_security_group_association" "this"

लेकिन Checkov failure केवल:

azurerm_subnet

resource पर report कर रहा था।

13. Checkov Failure का Important Evidence

Checkov failure में resource:

module.subnets.azurerm_subnet.Subnets["web"]

और source:

modules/subnet/main.tf

था।

Checkov subnet resource को इस प्रकार देख रहा था:

resource "azurerm_subnet" "Subnets" {

  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes = each.value.address_prefixes
}

लेकिन association अलग resource में थी।

14. First Wrong Approach — Subnet Resource में NSG ID डालना

Checkov को satisfy करने के लिए initially यह possibility investigate की गई:

resource "azurerm_subnet" "Subnets" {

  ...

  network_security_group_id = var.network_security_group_id
}

लेकिन Terraform validation ने इसे reject किया।

Error:

Error: Value for unconfigurable attribute

और:

Can't configure a value for
"network_security_group_id":
its value will be decided automatically
based on the result of applying this configuration.

इससे prove हुआ कि current AzureRM provider version में:

azurerm_subnet.network_security_group_id

को इस resource implementation में manually configure नहीं किया जा सकता।

15. Important Decision

इस error के बाद यह decision लिया गया:

Subnet resource में
network_security_group_id
manually add नहीं करना है।

क्योंकि इससे Terraform configuration invalid हो रही थी।

इसलिए proper separate association resource को maintain किया गया:

resource "azurerm_subnet_network_security_group_association" "this"
16. Terraform Validation Test

Command:

terraform validate

जब गलत network_security_group_id subnet resource में था, तब error आया।

गलत configuration हटाने के बाद validation successful हुआ।

17. Terraform Plan Verification

Command:

terraform plan

Successful result:

Plan: 16 to add, 0 to change, 0 to destroy.

इससे important conclusion निकला:

Terraform configuration valid है।

और Terraform infrastructure plan generate कर पा रहा है।

18. Terraform Format

Command:

terraform fmt -recursive

यह command successfully execute हुई।

इसका purpose:

Terraform files को standard formatting में रखना।
19. Checkov Version

Checkov version verify किया गया:

checkov --version

Result:

3.3.13

Environment:

Windows
Python 3.13

एक message भी आया:

File association not found for extension .py

लेकिन Checkov executable run हो रहा था और scan execute कर रहा था।

20. Terraform Version

Command:

terraform version

Relevant result:

Terraform v1.14.6
on windows_amd64

provider:
registry.terraform.io/hashicorp/azurerm v5.1.0
21. Checkov Directory Scan Issue

एक point पर command गलत directory path के साथ run की गई:

checkov -d terraform

जब current working directory पहले से:

...\terraform

थी।

Result:

Directory terraform does not exist; skipping it

इससे सीख:

अगर current directory:

project\terraform

है तो scan:

checkov -d .

से करना चाहिए।

अगर project root:

project

है तो:

checkov -d terraform

use किया जा सकता है।

22. Checkov Unicode / Encoding Error

एक scan में Checkov Python encoding error भी आया:

UnicodeDecodeError:
'charmap' codec can't decode byte 0x90

Error Python 3.13 environment में Checkov के file reading stage से आया।

Relevant error:

UnicodeDecodeError: 'charmap' codec can't decode byte
0x90 in position 3124

यह Checkov scan execution / Windows encoding से संबंधित अलग issue था।

इसके बाद scan फिर successfully execute किया गया और actual Terraform Checkov findings प्राप्त हुईं।

23. Full Checkov Result

Valid Terraform configuration के साथ Checkov result:

Passed checks: 9
Failed checks: 5
Skipped checks: 0

Passed checks:

CKV_AZURE_118
CKV_AZURE_160
CKV_AZURE_9
CKV_AZURE_10
CKV_AZURE_77
CKV_AZURE_183
CKV_AZURE_182
CKV_AZURE_119
CKV2_AZURE_39

Failed:

CKV2_AZURE_31

और यह पाँचों subnets पर fail हुआ:

web
application
data
management
security
24. Checkov Failed Check Analysis

Failed check:

CKV2_AZURE_31

Description:

Ensure VNET subnet is configured with a Network Security Group (NSG)

लेकिन Terraform code में actual association मौजूद थी:

resource "azurerm_subnet_network_security_group_association" "this" {

  for_each = azurerm_subnet.Subnets

  subnet_id                 = each.value.id
  network_security_group_id = var.network_security_group_id
}

इसलिए architecture:

Subnet
  ↓
Separate NSG Association Resource
  ↓
NSG

था।

25. Checkov Graph-Based Detection Investigation

CKV2 checks सामान्य resource attribute checks से अलग तरीके से graph relationships evaluate कर सकते हैं।

इस case में:

azurerm_subnet

और:

azurerm_subnet_network_security_group_association

के बीच relationship को Checkov ने expected तरीके से recognize नहीं किया।

विशेष रूप से project में:

module
+
for_each
+
separate association resource

का combination था।

Architecture:

Root Module
     │
     ├───────────────┐
     │               │
     ▼               ▼
module.nsg      module.subnets
     │               │
     ▼               ▼
NSG             Subnets
                     │
                     ▼
              NSG Association

Terraform इस relationship को correctly plan कर रहा था।

Checkov CKV2_AZURE_31 इसे expected graph relationship के रूप में detect नहीं कर पा रहा था।

26. Checkov Upstream Investigation

Checkov के upstream GitHub issue tracker में Azure subnet security association से संबंधित issue मिला।

Relevant pattern:

CKV2_AZURE_31
+
NSG Association
+
Module

Issue का context यह था कि Checkov graph-based Azure checks कुछ module-based association patterns को properly recognize नहीं कर रहे थे।

इससे हमारे observed behavior को external evidence मिला।

27. Targeted Checkov Test

Root cause isolate करने के लिए सिर्फ problematic check को target किया गया।

Command:

checkov -d . --framework terraform --check CKV2_AZURE_31

Result:

Passed checks: 9
Failed checks: 0
Skipped checks: 0

यह result initially confusing था क्योंकि full scan में फिर 5 failures आ रहे थे।

28. Targeted vs Full Scan Difference

Targeted check:

checkov -d . --framework terraform --check CKV2_AZURE_31

ने:

Failed checks: 0

दिया।

लेकिन full scan:

checkov -d . --framework terraform

ने:

Passed checks: 9
Failed checks: 5
Skipped checks: 0

दिया।

और वही:

CKV2_AZURE_31

फिर पाँच subnets पर fail हुआ।

इसलिए targeted scan को final resolution नहीं माना गया।

29. Why Terraform Code Was NOT Changed Further

Repeated attempts के बाद यह clear हुआ कि Checkov को satisfy करने के लिए Terraform subnet resource में:

network_security_group_id = ...

add करना गलत था।

Terraform ने इसे reject किया।

इसलिए निम्न architecture retain किया गया:

resource "azurerm_subnet" "Subnets" {
    ...
}

और:

resource "azurerm_subnet_network_security_group_association" "this" {
    ...
}

यह separation intentionally maintain किया गया।

30. Backup File Decision

Troubleshooting के दौरान backup files बनाने का विचार आया।

लेकिन repository में actual Terraform files पहले से मौजूद थीं और Git history भी available थी।

इसलिए unnecessary backup copies रखने का decision नहीं लिया गया।

Git repository itself version history provide कर रही है:

git log
git diff
git checkout
git restore

इसलिए:

Extra backup .tf files

बनाना unnecessary माना गया।

31. CI Pipeline में Checkov

Initial GitHub Actions pipeline में Checkov था:

- name: Checkov Security Scan
  uses: bridgecrewio/checkov-action@master
  with:
    directory: terraform
    framework: terraform

इसका उद्देश्य था:

Terraform
   ↓
Checkov Security Scan
   ↓
Fail pipeline on security findings

लेकिन CKV2_AZURE_31 के कारण pipeline unnecessarily fail/block हो रही थी।

32. Existing Trivy Integration

Pipeline में पहले से Trivy मौजूद था:

- name: Trivy IaC Security Scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: config
    scan-ref: terraform
    severity: HIGH,CRITICAL
    exit-code: 1

Trivy का role:

Infrastructure as Code
Misconfiguration Scanning

था।

इसलिए project में दो IaC security scanners हो रहे थे:

Checkov
   +
Trivy
33. Final Decision

काफी troubleshooting के बाद final decision:

Checkov → Remove from CI Pipeline

Trivy → Keep as Primary IaC Security Gate

महत्वपूर्ण:

यह decision इसलिए नहीं लिया गया कि:

Checkov खराब tool है

बल्कि इसलिए लिया गया क्योंकि:

Terraform configuration valid है
        +
NSG association correctly implemented है
        +
Terraform plan successful है
        +
Checkov CKV2_AZURE_31 लगातार false/incorrect failure दे रहा है
        +
Trivy पहले से pipeline में मौजूद है
        +
CI pipeline को unnecessary scanner limitation से block नहीं करना है
34. Final CI Direction

Final desired pipeline:

GitHub Push
     │
     ▼
Checkout
     │
     ▼
Azure OIDC Login
     │
     ▼
Terraform Setup
     │
     ▼
terraform fmt -check -recursive
     │
     ▼
terraform init
     │
     ▼
terraform validate
     │
     ▼
Trivy IaC Security Scan
     │
     ▼
terraform plan
     │
     ▼
SUCCESS

Checkov को इस pipeline से remove किया जाएगा।

35. What Was NOT Changed

Troubleshooting के बाद निम्न चीजें intentionally unchanged रखी गईं:

VNet architecture
        ↓
Subnet architecture
        ↓
for_each implementation
        ↓
NSG module
        ↓
NSG association resource
        ↓
NIC module
        ↓
Terraform provider version

विशेष रूप से:

azurerm_subnet_network_security_group_association

को remove नहीं किया गया।

36. Final Technical Conclusion

इस troubleshooting phase का final conclusion:

Terraform configuration = VALID

Terraform Plan = SUCCESSFUL

NSG Resource = VALID

Subnet Resource = VALID

NSG Association = VALID

Checkov CKV2_AZURE_31 = Problematic in current scanning pattern

Trivy = Retained as IaC Security Gate

इसलिए Checkov failure को Terraform infrastructure defect नहीं माना गया।

37. Commands Used During Troubleshooting

नीचे इस phase में commonly used commands की consolidated list है:

git status
git log -1 --oneline
git branch --show-current
git push origin feature/nic-infrastructure
git log --oneline --all -10
terraform fmt -recursive
terraform fmt -check -recursive
terraform validate
terraform plan
terraform version
checkov --version
checkov -d .
checkov -d terraform
checkov -d . --framework terraform
checkov -d . --framework terraform --check CKV2_AZURE_31
Get-Content .\main.tf
Get-Content .\providers.tf
Get-Content .\modules\nsg\main.tf
Get-Content .\modules\nsg\variables.tf
Get-Content .\modules\nsg\outputs.tf
Get-Content .\modules\subnet\main.tf
Get-Content .\modules\subnet\variables.tf
Get-Content .\modules\subnet\outputs.tf
Get-ChildItem .\modules -Directory | Select-Object Name
Get-ChildItem .\modules -Recurse -File | Select-Object FullName
Get-ChildItem -Filter "*.tf" | Select-Object Name
38. Lessons Learned
Lesson 1 — Security Scanner Failure हमेशा Terraform Failure नहीं होता

अगर:

Terraform validate = PASS
Terraform plan = PASS

लेकिन scanner fail है, तो पहले यह verify करना चाहिए कि:

Scanner finding

actual infrastructure problem है या scanner detection problem।

Lesson 2 — Terraform Architecture को Scanner के लिए खराब नहीं करना चाहिए

सिर्फ scanner को satisfy करने के लिए invalid Terraform syntax/configuration नहीं डालना चाहिए।

Lesson 3 — Graph-Based Security Checks की limitations हो सकती हैं

CKV2 checks resource relationships पर depend कर सकते हैं।

इसलिए:

module
+
for_each
+
association resource

जैसे patterns में scanner behavior अलग हो सकता है।

Lesson 4 — Multiple Security Scanners का मतलब हमेशा Better नहीं होता

अगर:

Checkov
+
Trivy

दोनों same IaC area scan कर रहे हैं, तो:

duplicate findings
+
false positives
+
pipeline complexity
+
maintenance

बढ़ सकती है।

Lesson 5 — Git History का उपयोग करें

Unnecessary backup files रखने के बजाय:

git log
git diff
git restore
git checkout

जैसे Git features का उपयोग करके changes track और recover किए जा सकते हैं।

39. Phase 1 Final Status
Phase: Checkov Troubleshooting

Status: CLOSED

Terraform Configuration:
PASS

Terraform Validation:
PASS

Terraform Plan:
PASS

NSG Association:
IMPLEMENTED

Checkov:
REMOVED FROM CI DECISION

Trivy:
RETAINED

Next Phase:
CI Pipeline Cleanup + Trivy Validation
40. Final Decision Record
Decision

Checkov को Terraform CI pipeline से हटाया जाएगा और Trivy को primary IaC security scanner/gate के रूप में रखा जाएगा।

Reason

CKV2_AZURE_31 ने module + for_each + separate subnet NSG association architecture के साथ repeated false/incorrect failures generate किए, जबकि Terraform configuration valid और plan successful था।

Important

यह decision security scanning को disable करने का decision नहीं है।

Security scanning जारी रहेगा:

Trivy

के माध्यम से।

Terraform Architecture

NSG association को Terraform में अलग resource के रूप में maintain किया जाएगा:

resource "azurerm_subnet_network_security_group_association" "this"

क्योंकि यही current valid implementation है।


### Phase 1 का सार

भाई, यह **सिर्फ “Checkov हटाया” वाली note नहीं है**। इसमें हमने पूरी chain preserve कर दी है:

**Problem → Architecture → Commands → गलत approach → Terraform error → validation → Checkov results → targeted test → graph investigation → Trivy → final decision → lessons learned.**

अगले **Phase 2** में हम सिर्फ **`.github/workflows/terraform-ci.yml` cleanup + duplicate Terraform setup हटाना + Ch


---

🔎 2. Initial Checkov Execution

सबसे पहले Terraform directory से Checkov execute किया गया।

Command
checkov -d terraform
Error
File association not found for extension .py

[ERROR] Directory terraform does not exist; skipping it
Root Cause

Command पहले से ही terraform directory के अंदर execute किया जा रहा था:

D:\Projects3\comsolve-cyberex-azure-landing-zone\terraform

इसलिए:

checkov -d terraform

गलत path को target कर रहा था।

Correct Command

Terraform directory के अंदर:

checkov -d .

या repository root से:

checkov -d terraform
🧪 3. Checkov Security Results

Correct directory से Checkov run करने के बाद security scan execute हुआ।

Initial result:

Passed checks: 9
Failed checks: 5
Skipped checks: 0

Failed checks सभी एक ही policy से संबंधित थे:

CKV2_AZURE_31
Ensure VNET subnet is configured with a Network Security Group (NSG)

Checkov ने निम्न पाँच subnets को fail किया:

web
application
data
security
management
🔐 4. Checks That Were Already Passing

Checkov ने अन्य Azure security controls successfully pass किए।

Network Interface
CKV_AZURE_118
Ensure that Network Interfaces disable IP forwarding

Status:

PASSED
HTTP Access
CKV_AZURE_160
Ensure that HTTP (port 80) access is restricted from the internet

Status:

PASSED
RDP Access
CKV_AZURE_9
Ensure that RDP access is restricted from the internet

Status:

PASSED
SSH Access
CKV_AZURE_10
Ensure that SSH access is restricted from the internet

Status:

PASSED
UDP Services
CKV_AZURE_77
Ensure that UDP Services are restricted from the Internet

Status:

PASSED
VNET DNS
CKV_AZURE_183
Ensure that VNET uses local DNS addresses

Status:

PASSED
VNET DNS Endpoints
CKV_AZURE_182
Ensure that VNET has at least 2 connected DNS Endpoints

Status:

PASSED
Public IP on NIC
CKV_AZURE_119
Ensure that Network Interfaces don't use public IPs

Status:

PASSED
VM Public IP / Serial Console
CKV2_AZURE_39
Ensure Azure VM is not configured with public IP and serial console access

Status:

PASSED
❌ 5. Main Failing Check

The problematic check was:

CKV2_AZURE_31
Ensure VNET subnet is configured with a Network Security Group (NSG)

The failure appeared for:

module.subnets.azurerm_subnet.Subnets["web"]

module.subnets.azurerm_subnet.Subnets["application"]

module.subnets.azurerm_subnet.Subnets["data"]

module.subnets.azurerm_subnet.Subnets["security"]

module.subnets.azurerm_subnet.Subnets["management"]
🧱 6. Original Subnet Terraform Configuration

The subnet module initially contained:

resource "azurerm_subnet" "Subnets" {

  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes = each.value.address_prefixes

}

Checkov specifically identified this resource:

azurerm_subnet.Subnets

as failing.

🔐 7. Existing NSG Association Design

The Terraform design already used a separate NSG association resource:

resource "azurerm_subnet_network_security_group_association" "this" {

  for_each = azurerm_subnet.Subnets

  subnet_id                 = each.value.id
  network_security_group_id = var.network_security_group_id

}

This is an important point in the troubleshooting history.

The infrastructure design was already attempting to associate the NSG with every subnet using:

azurerm_subnet_network_security_group_association

Therefore, the intention was not to leave the subnets without NSGs.

🧩 8. NSG Module Investigation

The following files were inspected:

terraform/modules/nsg/main.tf
terraform/modules/nsg/variables.tf
terraform/modules/nsg/outputs.tf
NSG main.tf
resource "azurerm_network_security_group" "this" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
NSG output
output "id" {

  description = "NSG resource ID"

  value = azurerm_network_security_group.this.id

}

The NSG module itself was correctly creating an Azure Network Security Group and exposing its ID.

🔗 9. Root Module NSG Connection

The root main.tf contained:

module "nsg" {

  source = "./modules/nsg"

  name                = "cyberex-nsg"
  location            = var.nic_location
  resource_group_name = var.resource_groups["network"].name

  tags = {
    Environment = "Development"
    Project     = "Cyberex"
    ManagedBy   = "Terraform"
  }
}

The subnet module received the NSG ID:

module "subnets" {

  source = "./modules/subnet"

  subnets = var.subnets

  virtual_network_name = var.vnet_name

  resource_group_name = var.resource_groups["network"].name

  depends_on = [
    module.vnet
  ]

  network_security_group_id = module.nsg.id

}

Therefore, the Terraform dependency chain was:

module.nsg
    │
    │ output: id
    ▼
module.subnets
    │
    ▼
azurerm_subnet_network_security_group_association
⚠️ 10. Terraform Configuration Error During Troubleshooting

एक point पर NSG को directly azurerm_subnet resource के अंदर configure करने का प्रयास किया गया।

इससे Terraform validation error आया:

Error: Value for unconfigurable attribute

Specifically:

network_security_group_id = var.network_security_group_id

Terraform ने बताया:

Can't configure a value for "network_security_group_id":
its value will be decided automatically based on the result of applying this configuration.
Important Finding

इससे स्पष्ट हुआ कि current AzureRM provider configuration में इस attribute को इस तरीके से manually configure करना valid approach नहीं था।

इसलिए यह configuration हटाई गई और separate association resource को retain किया गया।

🔄 11. Correct Terraform Association Approach

Final Terraform subnet module design में:

resource "azurerm_subnet" "Subnets" {

  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes = each.value.address_prefixes

}

और separate association:

resource "azurerm_subnet_network_security_group_association" "this" {

  for_each = azurerm_subnet.Subnets

  subnet_id                 = each.value.id
  network_security_group_id = var.network_security_group_id

}

Terraform validation और plan इस design के साथ successfully complete हुए।

🧪 12. Terraform Validation

Terraform formatting:

terraform fmt -recursive

Terraform validation:

terraform validate

Terraform plan:

terraform plan

Final plan:

Plan: 16 to add, 0 to change, 0 to destroy.

यह महत्वपूर्ण था क्योंकि इससे confirm हुआ कि Terraform configuration syntactically और structurally valid थी।

🔍 13. Checkov फिर से Run किया गया

Terraform configuration valid होने के बाद Checkov को दोबारा execute किया गया:

checkov -d .

Result फिर आया:

Passed checks: 9
Failed checks: 5
Skipped checks: 0

और वही policy फिर fail हुई:

CKV2_AZURE_31

सभी पाँच subnets पर:

web
application
data
security
management
🧠 14. Checkov Skip Approach का परीक्षण

Troubleshooting के दौरान Checkov skip comment का भी परीक्षण किया गया।

Example:

#checkov:skip=CKV2_AZURE_31:Subnet NSG association is explicitly managed using azurerm_subnet_network_security_group_association
resource "azurerm_subnet" "Subnets" {

इस approach का उद्देश्य केवल Checkov को bypass करना नहीं था, बल्कि यह verify करना था कि Checkov का inline skip mechanism किस तरह behave करता है।

हालांकि final objective security check को blindly skip करना नहीं था।

🧪 15. Checkov Local Execution में एक अलग समस्या

Checkov को Windows environment पर execute करते समय एक अलग error भी दिखाई दिया:

File association not found for extension .py

और बाद में:

UnicodeDecodeError:
'charmap' codec can't decode byte 0x90

इससे पता चला कि local Windows environment में Checkov execution के दौरान Python encoding / file-reading issue भी मौजूद था।

इस issue का संबंध सीधे Azure subnet NSG security finding से अलग था।

📦 16. Installed Versions

Troubleshooting के दौरान installed versions verify किए गए।

Checkov
checkov --version

Result:

3.3.13
Terraform
Terraform v1.14.6
on windows_amd64
AzureRM Provider
registry.terraform.io/hashicorp/azurerm v5.1.0
🗂️ 17. Terraform Project Structure

Troubleshooting के दौरान module structure verify किया गया:

terraform/
│
├── main.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── outputs.tf
│
└── modules/
    │
    ├── nic/
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    │
    ├── nsg/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    ├── public-ip/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    ├── resource-group/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    ├── subnet/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    └── vnet/
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
🔬 18. Important Investigation Finding

Checkov लगातार इस resource को identify कर रहा था:

azurerm_subnet.Subnets

और उसी resource पर:

CKV2_AZURE_31

fail कर रहा था।

जबकि Terraform configuration में NSG association अलग resource द्वारा explicitly managed थी:

azurerm_subnet_network_security_group_association.this

इसलिए समस्या simple:

"NSG बनाया नहीं गया"

या:

"NSG association लिखी नहीं गई"

जैसी समस्या नहीं थी।

यह Checkov की static analysis / resource relationship detection और Terraform configuration design के बीच compatibility/recognition issue के रूप में investigate किया गया।

🚦 19. CI Pipeline Context

GitHub Actions workflow में Checkov इस तरह configured था:

- name: Checkov Security Scan
  uses: bridgecrewio/checkov-action@master
  with:
    directory: terraform
    framework: terraform

Checkov के बाद Trivy भी configured था:

- name: Trivy IaC Security Scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: config
    scan-ref: terraform
    severity: HIGH,CRITICAL
    exit-code: 1

Pipeline का intended flow था:

Terraform Format
        ↓
Terraform Init
        ↓
Terraform Validate
        ↓
Checkov
        ↓
Trivy
        ↓
Terraform Plan
🧭 20. Decision Point

काफी troubleshooting के बाद दो facts clear हुए:

Terraform
terraform fmt       → PASS
terraform validate  → PASS
terraform plan      → PASS

Final plan:

16 to add
0 to change
0 to destroy
Checkov
Passed checks: 9
Failed checks: 5
Skipped checks: 0

और लगातार:

CKV2_AZURE_31

fail होता रहा।

⚠️ 21. Why We Did Not Modify Valid Terraform Just for Checkov

Security scanner को satisfy करने के लिए Terraform architecture को गलत या unsupported तरीके से modify करना उचित नहीं माना गया।

विशेष रूप से:

network_security_group_id = var.network_security_group_id

को directly subnet resource में डालने से Terraform validation failure आया।

इसलिए केवल Checkov को खुश करने के लिए invalid Terraform configuration रखना acceptable नहीं था।

🎯 22. Phase 01 Conclusion

इस troubleshooting phase में निम्न बातें establish हुईं:

Checkov successfully installed था।
Checkov version 3.3.13 था।
Terraform version 1.14.6 था।
AzureRM provider version 5.1.0 था।
Terraform configuration valid थी।
NSG module successfully defined था।
NSG ID subnet module को pass किया जा रहा था।
azurerm_subnet_network_security_group_association explicitly configured था।
Terraform plan successfully generated हुआ।
Checkov फिर भी CKV2_AZURE_31 को पाँच subnets पर fail कर रहा था।
Direct subnet attribute approach Terraform validation में invalid साबित हुई।
Inline Checkov skip approach भी desired architectural solution नहीं माना गया।
Windows environment में Checkov के अलग Python/encoding issues भी observe हुए।
Checkov को security gate के रूप में रखना troubleshooting effort को disproportionately बढ़ा रहा था।
🏁 23. Final Decision

After extensive troubleshooting, the project decision was:

Checkov को GitHub Actions CI pipeline से remove किया जाएगा।

लेकिन इसका अर्थ यह नहीं है कि Infrastructure Security Scanning बंद की जा रही है।

Existing Trivy IaC scanning को security gate के रूप में continue किया जाएगा:

Terraform
    │
    ├── Format
    ├── Init
    ├── Validate
    │
    ├── Trivy IaC Security Scan ✅
    │
    └── Terraform Plan
🔜 Next Phase

Phase 02 — Checkov Root Cause Analysis

अगले phase में specifically document किया जाएगा:

CKV2_AZURE_31 का behavior
Checkov का Terraform resource relationship analysis
for_each का impact
azurerm_subnet और NSG association relationship
Checkov और Terraform provider behavior का difference
क्यों Checkov association को expected तरीके से recognize नहीं कर रहा था
Checkov बनाम Trivy का role
Security scanning strategy का technical evaluation
<p align="center">

Phase 01 — Completed

Status: Checkov Troubleshooting Completed

Final Decision: Move CI Security Gate to Trivy

</p> ```