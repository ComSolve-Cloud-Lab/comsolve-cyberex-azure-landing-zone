# 🔐 Phase 02 — Checkov Root Cause Analysis

<p align="center">

![Checkov](https://img.shields.io/badge/Checkov-IaC%20Security%20Scanning-blue?style=for-the-badge)

![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-623CE4?style=for-the-badge&logo=terraform&logoColor=white)

![Microsoft Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)

![Trivy](https://img.shields.io/badge/Trivy-IaC%20Security%20Scanning-1904DA?style=for-the-badge)

</p>

> 🎯 **Objective:** `CKV2_AZURE_31` Checkov failure के वास्तविक technical root cause को समझना, Terraform configuration और NSG association architecture को validate करना, तथा यह निर्धारित करना कि Checkov failure वास्तविक security gap था या Checkov द्वारा Terraform resource relationship को correctly interpret न कर पाने से उत्पन्न समस्या थी।

---

## 1. समस्या का संक्षिप्त परिचय

## 2. CKV2_AZURE_31 क्या Check करता है

## 3. हमारा Terraform Network Architecture

## 4. Subnet Module की वास्तविक Configuration

## 5. NSG Module की वास्तविक Configuration

## 6. NSG Association कैसे Implement की गई

## 7. `for_each` का उपयोग

## 8. Root Module से Module Dependency

## 9. पहला Troubleshooting Attempt

## 10. `network_security_group_id` को `azurerm_subnet` में जोड़ने का प्रयास

## 11. Terraform Validation Error

## 12. Association Resource क्यों जरूरी है

## 13. Checkov ने फिर भी Failure क्यों दिखाया

## 14. पाँचों Subnets पर समान Failure

## 15. Checkov Output से मिलने वाला Evidence

## 16. Terraform Plan का परिणाम

## 17. Checkov Failure बनाम वास्तविक Azure Security State

## 18. Skip Directive क्यों इस्तेमाल नहीं किया गया

## 19. Configuration को बदलकर False Positive ठीक करने की कोशिश क्यों सफल नहीं हुई

## 20. Root Cause

## 21. Technical Conclusion

---

> 🎯 **Objective:** `CKV2_AZURE_31` Checkov failure के वास्तविक technical root cause को समझना, Terraform configuration और NSG association architecture को validate करना, तथा यह निर्धारित करना कि Checkov failure वास्तविक security gap था या Checkov द्वारा Terraform resource relationship को correctly interpret न कर पाने से उत्पन्न समस्या थी।

---

# 1. समस्या का संक्षिप्त परिचय

Terraform Infrastructure-as-Code project में Azure VNet, Subnets, Network Security Group (NSG) और Network Interfaces को Terraform modules के माध्यम से बनाया गया था।

CI pipeline में Infrastructure Security Scanning के लिए Checkov जोड़ा गया था।

Initial Checkov scan में अधिकांश Azure security checks successfully pass हुए।

लेकिन निम्न check लगातार fail हुआ:

`CKV2_AZURE_31`

Check name:

`Ensure VNET subnet is configured with a Network Security Group (NSG)`

इस check ने project के सभी पांच subnets को failed report किया:

- `web`
- `application`
- `data`
- `security`
- `management`

---

# 2. CKV2_AZURE_31 क्या Check करता है

`CKV2_AZURE_31` का उद्देश्य यह verify करना है कि Azure VNet का subnet किसी Network Security Group (NSG) से associated है।

Security perspective से यह important है क्योंकि NSG subnet-level network traffic control प्रदान करता है।

यदि subnet पर NSG लागू नहीं है, तो network segmentation और traffic filtering कमजोर हो सकती है।

इसलिए शुरुआत में यह assumption reasonable था कि Terraform configuration में NSG association missing हो सकती है।

लेकिन आगे की investigation में यह पाया गया कि Terraform configuration में NSG association पहले से मौजूद थी।

---

# 3. हमारा Terraform Network Architecture

Project में infrastructure को reusable Terraform modules में divide किया गया था।

Current module structure:

```text
terraform/
│
├── main.tf
├── variables.tf
├── locals.tf
├── outputs.tf
├── providers.tf
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

```



## 20. Root Cause

इस investigation के आधार पर मुख्य समस्या Terraform में NSG association की अनुपस्थिति नहीं थी।

Subnet और NSG के बीच association को अलग Terraform resource:

`azurerm_subnet_network_security_group_association`

के माध्यम से explicitly manage किया गया था।

लेकिन Checkov का `CKV2_AZURE_31` analysis हमारे module-based Terraform structure में इस explicit association को उसी तरह correlate नहीं कर पाया जिस तरह Terraform resource graph इसे resolve करता है।

विशेष रूप से:

- Subnets `for_each` के माध्यम से बनाए गए।
- प्रत्येक subnet एक अलग resource instance के रूप में मौजूद था।
- NSG अलग module में बनाया गया।
- NSG का ID `module.nsg.id` से प्राप्त किया गया।
- Subnet और NSG association अलग resource द्वारा manage की गई।
- Terraform dependency graph इस relationship को correctly resolve कर रहा था।
- इसके बावजूद Checkov ने प्रत्येक subnet को NSG के बिना report किया।

इसलिए `CKV2_AZURE_31` का repeated failure हमारे Terraform configuration में वास्तविक NSG absence का पर्याप्त प्रमाण नहीं था।

---

## 21. Technical Conclusion

Investigation के दौरान Terraform configuration को Checkov के अनुसार satisfy करने के लिए कई approaches test किए गए।

लेकिन ऐसे बदलाव जो Terraform resource model को बदल देते, वे उचित नहीं थे।

विशेष रूप से `network_security_group_id` को सीधे `azurerm_subnet` resource में configure करने का प्रयास Terraform द्वारा स्वीकार नहीं किया गया क्योंकि वर्तमान AzureRM provider version में यह attribute computed/unconfigurable था।

इसलिए सही Terraform architecture को केवल Checkov result बदलने के लिए modify करना उचित नहीं था।

अंतिम निर्णय यह रहा कि:

1. Terraform में explicit NSG association architecture रखा जाएगा।
2. `azurerm_subnet_network_security_group_association` resource हटाया नहीं जाएगा।
3. Terraform configuration को केवल Checkov को satisfy करने के लिए गलत तरीके से modify नहीं किया जाएगा।
4. Checkov को current CI pipeline से हटाया जाएगा।
5. Infrastructure security scanning के लिए Trivy को CI pipeline में रखा जाएगा।

---

इस architecture में:

Resource Group
      │
      └── VNet
           │
           ├── Web Subnet
           ├── Application Subnet
           ├── Data Subnet
           ├── Security Subnet
           └── Management Subnet
                    │
                    └── NSG Association
4. Subnet Module की वास्तविक Configuration

Subnet module में subnet creation के लिए निम्न Terraform resource उपयोग किया गया:

resource "azurerm_subnet" "Subnets" {

  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes = each.value.address_prefixes

}

इस resource का purpose केवल subnet create करना है।

यहाँ सभी subnet definitions for_each के माध्यम से dynamically create किए जाते हैं।

इसका परिणाम पाँच अलग subnet instances के रूप में मिलता है:

Subnets["web"]
Subnets["application"]
Subnets["data"]
Subnets["security"]
Subnets["management"]
5. for_each का उपयोग

Subnet module में:

for_each = var.subnets

का उपयोग किया गया।

इसका मतलब है कि एक ही Terraform resource block से multiple subnet resources create किए जा रहे हैं।

उदाहरण:

var.subnets
   │
   ├── web
   ├── application
   ├── data
   ├── security
   └── management

Terraform इन्हें अलग resource instances के रूप में manage करता है।

यह architecture valid और reusable Terraform pattern है।

6. NSG Module की वास्तविक Configuration

Network Security Group के लिए अलग module बनाया गया था।

modules/nsg/main.tf:

resource "azurerm_network_security_group" "this" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

NSG का ID output के माध्यम से expose किया गया:

modules/nsg/outputs.tf

output "id" {
  description = "NSG resource ID"
  value       = azurerm_network_security_group.this.id
}

इसका मतलब root module NSG का ID इस प्रकार प्राप्त कर सकता है:

module.nsg.id
7. NSG Association की वास्तविक Configuration

महत्वपूर्ण point यह है कि NSG association missing नहीं थी।

Subnet module में अलग association resource बनाया गया था:

resource "azurerm_subnet_network_security_group_association" "this" {

  for_each = azurerm_subnet.Subnets

  subnet_id                 = each.value.id
  network_security_group_id = var.network_security_group_id

}

यह resource प्रत्येक created subnet को NSG से associate करता है।

Architecture:

azurerm_subnet.Subnets
        │
        │ for_each
        ▼
azurerm_subnet_network_security_group_association
        │
        ▼
Network Security Group
8. NSG ID Root Module से कैसे आया

Root main.tf में subnet module को NSG ID provide किया गया:

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

यहाँ:

network_security_group_id = module.nsg.id

के माध्यम से NSG module का output subnet module को दिया गया।

इसलिए dependency chain मौजूद थी:

module.nsg
    │
    │ id
    ▼
module.subnets
    │
    ▼
azurerm_subnet_network_security_group_association
9. Checkov का Initial Result

Initial Checkov scan में कुल result:

Passed checks: 9
Failed checks: 5
Skipped checks: 0

Passed checks में निम्न महत्वपूर्ण checks शामिल थे:

CKV_AZURE_118
CKV_AZURE_160
CKV_AZURE_9
CKV_AZURE_10
CKV_AZURE_77
CKV_AZURE_183
CKV_AZURE_182
CKV_AZURE_119
CKV2_AZURE_39

लेकिन:

CKV2_AZURE_31

पाँच resources के लिए fail हुआ।

10. पाँचों Subnets पर Failure

Checkov ने निम्न सभी subnet instances को failed report किया:

module.subnets.azurerm_subnet.Subnets["web"]

module.subnets.azurerm_subnet.Subnets["application"]

module.subnets.azurerm_subnet.Subnets["data"]

module.subnets.azurerm_subnet.Subnets["security"]

module.subnets.azurerm_subnet.Subnets["management"]

हर failure में same check था:

CKV2_AZURE_31
Ensure VNET subnet is configured with a Network Security Group (NSG)

इससे investigation का focus subnet और NSG relationship पर गया।

11. Checkov ने Subnet Resource को कैसे Report किया

Checkov failure में केवल subnet resource की definition दिखाई गई:

resource "azurerm_subnet" "Subnets" {

  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  address_prefixes = each.value.address_prefixes

}

विशेष रूप से Checkov output में resource range:

File: \terraform\modules\subnet\main.tf:4-14

दिखाया गया।

महत्वपूर्ण बात यह थी कि failure report subnet resource पर थी, जबकि NSG association एक अलग Terraform resource में मौजूद थी।

12. पहला मुख्य Troubleshooting Approach

पहले यह verify किया गया कि क्या azurerm_subnet resource के अंदर सीधे:

network_security_group_id

configure किया जा सकता है।

इस approach का उद्देश्य था कि Checkov को subnet resource के अंदर ही NSG relationship दिखाई दे।

लेकिन यह Terraform provider configuration के साथ compatible नहीं था।

13. Terraform Validation Error

network_security_group_id को सीधे azurerm_subnet resource में configure करने के बाद:

terraform validate

पर error प्राप्त हुआ:

Error: Value for unconfigurable attribute

Can't configure a value for "network_security_group_id":
its value will be decided automatically based on the result of applying this configuration.

इससे स्पष्ट हुआ कि current AzureRM provider version में इस attribute को इस तरीके से manually configure नहीं किया जा सकता।

14. AzureRM Provider Version

Project में AzureRM provider version:

azurerm v5.1.0

था।

Terraform version:

Terraform v1.14.6

था।

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

इसलिए Terraform configuration को provider schema के अनुसार रखना आवश्यक था।

15. सही Terraform Architecture क्यों नहीं बदलना चाहिए

Azure subnet और NSG association के लिए अलग resource:

azurerm_subnet_network_security_group_association

का उपयोग किया गया था।

इस architecture को केवल Checkov result को PASS कराने के लिए बदलना उचित नहीं था।

क्योंकि:

Terraform configuration
        +
AzureRM provider schema
        +
Azure resource relationship

इन तीनों को एक साथ valid रखना आवश्यक है।

यदि केवल security scanner को satisfy करने के लिए Terraform architecture बदला जाता, तो infrastructure code unnecessarily गलत या provider-incompatible हो सकता था।

16. Checkov Skip Approach को क्यों Reject किया गया

Troubleshooting के दौरान यह suggestion आया कि resource के ऊपर:

#checkov:skip=CKV2_AZURE_31:Subnet NSG association is explicitly managed using azurerm_subnet_network_security_group_association

जैसा skip directive लगाया जाए।

लेकिन final engineering decision के लिए इसे primary solution नहीं माना गया।

कारण:

Problem
   ↓
Checkov failure
   ↓
Actual Terraform configuration verify करना चाहिए
   ↓
यदि configuration सही है
   ↓
Scanner limitation / compatibility investigate करनी चाहिए

ना कि तुरंत:

Checkov failure
   ↓
check skip
   ↓
PASS

इसलिए skip को वास्तविक root-cause fix नहीं माना गया।

17. Terraform Configuration को दोबारा Validate किया गया

Terraform formatting:

terraform fmt -recursive

run किया गया।

इसके बाद:

terraform validate

run किया गया।

और corrected configuration के साथ Terraform plan successfully generate हुआ।

18. Terraform Plan का Evidence

Terraform plan में:

Plan: 16 to add, 0 to change, 0 to destroy.

प्राप्त हुआ।

यह महत्वपूर्ण evidence था कि Terraform configuration syntactically और structurally valid थी और resources create करने के लिए Terraform dependency graph successfully तैयार कर रहा था।

19. Checkov और Terraform के Result में अंतर

यहाँ महत्वपूर्ण distinction सामने आया:

Terraform

Terraform configuration को valid मान रहा था और plan successfully generate कर रहा था।

Checkov

Checkov उसी configuration में:

CKV2_AZURE_31

के लिए पाँच subnet instances को fail कर रहा था।

इसका मतलब यह नहीं था कि Terraform configuration automatically insecure है।

Security scanner का result और Terraform provider का configuration validation अलग-अलग चीजें हैं।

20. Checkov JSON Output से Evidence

Detailed Checkov JSON output:

checkov.json

से भी confirm किया गया कि सभी five failures इसी resource पर report हुए:

terraform\modules\subnet\main.tf

और resources थे:

Subnets["web"]
Subnets["application"]
Subnets["data"]
Subnets["security"]
Subnets["management"]

हर resource के लिए:

CKV2_AZURE_31

fail हुआ।

इससे यह confirm हुआ कि समस्या किसी एक particular subnet की configuration तक सीमित नहीं थी।

21. समान Failure Pattern

सभी पाँच subnets पर exact same check fail होना महत्वपूर्ण observation था।

Pattern:

web              → FAILED
application      → FAILED
data             → FAILED
security         → FAILED
management       → FAILED

यदि किसी एक subnet की configuration खराब होती, तो केवल specific resource failure expected होता।

लेकिन यहाँ सभी instances पर समान result आया।

इसलिए module-level resource relationship और Checkov analysis behavior को investigate किया गया।

22. for_each और Module Relationship

Terraform configuration में multiple levels पर for_each और module outputs का उपयोग किया गया:

Root Module
    │
    ├── module.nsg
    │      │
    │      └── output.id
    │
    └── module.subnets
           │
           ├── azurerm_subnet["web"]
           ├── azurerm_subnet["application"]
           ├── azurerm_subnet["data"]
           ├── azurerm_subnet["security"]
           └── azurerm_subnet["management"]
                    │
                    └── NSG Association

Terraform इस relationship को अपने resource graph में manage कर सकता है।

लेकिन Checkov static IaC analysis करता है और उसका graph interpretation Terraform के actual execution graph से अलग हो सकता है।

23. Important Technical Observation

यह investigation केवल Checkov output को देखकर conclusion निकालने के बजाय तीन अलग layers को compare करने पर आधारित थी:

Layer 01
Terraform Source Code

Layer 02
Terraform Provider Schema

Layer 03
Checkov Static Analysis

Source code में NSG association मौजूद थी।

Provider schema ने direct subnet-level network_security_group_id configuration को स्वीकार नहीं किया।

और Checkov फिर भी CKV2_AZURE_31 fail कर रहा था।

24. Root Cause

Investigation के आधार पर मुख्य समस्या Terraform में NSG association की अनुपस्थिति नहीं थी।

Subnet और NSG के बीच association को अलग Terraform resource:

azurerm_subnet_network_security_group_association

के माध्यम से explicitly manage किया गया था।

लेकिन Checkov का:

CKV2_AZURE_31

हमारे module-based Terraform structure में subnet और अलग association resource के relationship को उसी तरीके से recognize नहीं कर रहा था जिस तरह Terraform अपने resource graph में relationship को manage करता है।

विशेष रूप से:

Subnets for_each के माध्यम से बनाए गए।
प्रत्येक subnet एक अलग resource instance था।
NSG अलग module में बनाया गया।
NSG ID module.nsg.id से प्राप्त किया गया।
Subnet और NSG association अलग resource द्वारा manage की गई।
Terraform dependency relationship मौजूद थी।
Terraform plan successfully generate हुआ।
इसके बावजूद Checkov ने प्रत्येक subnet को NSG association के बिना report किया।

इसलिए repeated CKV2_AZURE_31 failure को केवल देखकर यह conclude करना सही नहीं था कि Terraform configuration में NSG वास्तव में missing है।

25. False Positive / Tool Limitation Consideration

इस investigation में Checkov failure को सीधे security vulnerability मानने के बजाय tool interpretation issue की possibility को consider किया गया।

यहाँ "false positive" शब्द का उपयोग सावधानी से किया जाना चाहिए।

अर्थात:

Checkov says:
Subnet does not have NSG

लेकिन Terraform configuration says:
Subnet → explicit NSG association resource मौजूद है

इस mismatch के कारण scanner behavior को investigate करना आवश्यक था।

26. क्या Checkov को केवल PASS कराने के लिए Code बदलना चाहिए?

नहीं।

Infrastructure-as-Code में प्राथमिकता होनी चाहिए:

Correct Terraform
        ↓
Correct Azure Architecture
        ↓
Security Controls
        ↓
Security Scanner Validation

न कि:

Security Scanner PASS
        ↓
Terraform architecture बदल दो

इसलिए Checkov को satisfy करने के लिए provider-incompatible configuration डालना उचित नहीं था।

27. Security Control वास्तव में क्या है?

हमारा intended security control:

Subnet
   │
   ▼
NSG Association
   │
   ▼
Network Security Group
   │
   ▼
Inbound / Outbound Network Rules

है।

NSG module और association resource दोनों Terraform configuration में मौजूद हैं।

इसलिए architecture का उद्देश्य subnet-level network security लागू करना है।

28. Checkov Troubleshooting से प्राप्त मुख्य सीख

इस investigation से निम्न important lessons मिले:

Lesson 01 — Scanner failure हमेशा configuration failure नहीं होता

Security scanner failure को तुरंत infrastructure defect नहीं मानना चाहिए।

पहले Terraform configuration verify करनी चाहिए।

Lesson 02 — Terraform Provider Schema महत्वपूर्ण है

किसी attribute को केवल इसलिए Terraform resource में add नहीं करना चाहिए क्योंकि scanner उसे expect करता है।

Provider documentation और schema verify करना आवश्यक है।

Lesson 03 — Association Resources को समझना जरूरी है

Azure resources में कई relationships अलग Terraform resources द्वारा manage होती हैं।

इस case में:

azurerm_subnet_network_security_group_association

ऐसा ही resource है।

Lesson 04 — for_each Static Analysis को complex बना सकता है

Dynamic resources और modules static analysis tools के लिए resource relationships को समझना अधिक complex बना सकते हैं।

Lesson 05 — Security Scanner को blindly follow नहीं करना चाहिए

Scanner को security validation के लिए इस्तेमाल करना चाहिए, लेकिन उसके output को infrastructure architecture के context में analyze करना आवश्यक है।

29. Final Technical Assessment

Investigation के बाद निम्न स्थिति establish हुई:

Component	Status
Terraform Syntax	✅ Valid
Terraform Format	✅ Valid
Terraform Plan	✅ Successful
NSG Module	✅ Present
NSG Output	✅ Present
Subnet Module	✅ Present
NSG Association Resource	✅ Present
Multiple Subnets	✅ Created using for_each
CKV2_AZURE_31	❌ Failing
Direct NSG ID inside Subnet	❌ Provider-incompatible
Checkov Skip	❌ Not considered actual fix
30. Root Cause Summary

संक्षेप में:

Terraform
   │
   ├── VNet
   │
   ├── Subnets
   │      └── for_each
   │
   ├── NSG
   │
   └── NSG Association
          │
          └── Explicit Terraform Resource

Terraform architecture valid था।

लेकिन Checkov:

CKV2_AZURE_31

के माध्यम से subnet और separately-managed NSG association को expected तरीके से recognize नहीं कर पाया।

इस कारण पाँचों subnet instances पर repeated failure मिला।

31. Engineering Decision

इस analysis के बाद engineering decision यह रहा:

Existing Terraform subnet architecture को preserve किया जाएगा।
azurerm_subnet_network_security_group_association resource रखा जाएगा।
network_security_group_id को सीधे azurerm_subnet resource में force नहीं किया जाएगा।
केवल Checkov PASS कराने के लिए Terraform architecture नहीं बदला जाएगा।
Checkov skip को root-cause solution नहीं माना जाएगा।
Checkov को CI pipeline से remove करने का decision अलग Phase 03 में document किया जाएगा।
CI pipeline में Infrastructure Security Scanning के लिए Trivy को continue किया जाएगा।
32. Conclusion

इस investigation का सबसे महत्वपूर्ण conclusion यह है कि:

Security scanner को PASS कराने के लिए Infrastructure-as-Code की सही architecture को compromise नहीं करना चाहिए।

इस case में Terraform में NSG association को अलग resource के रूप में explicitly manage किया गया था।

Repeated CKV2_AZURE_31 failures के बावजूद Terraform configuration को केवल Checkov expectation के आधार पर बदलना technically उचित नहीं पाया गया।

इसलिए आगे की documentation में Checkov removal और Trivy-based security scanning decision को अलग Phase 03 में record किया जाएगा।


### अब Phase 2 save करने के बाद

PowerShell में:

```powershell
git status

फिर:

git diff -- .\docs\security-scanning\Phase-02-Checkov-Root-Cause-Analysis.md

---