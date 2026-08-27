# 📈 Phase 19 — Monitoring / Observability

<p align="center">

![Monitoring](https://img.shields.io/badge/Monitoring-Observability-success?style=for-the-badge)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Microsoft Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Azure Monitor](https://img.shields.io/badge/Azure%20Monitor-Monitoring-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Logs](https://img.shields.io/badge/Logs-Visibility-orange?style=for-the-badge)

</p>

> 🎯 **Objective:** Azure Infrastructure और CI/CD environment के लिए **Monitoring, Logging और Observability foundation** तैयार करना, ताकि infrastructure health, security events, resource activity और pipeline failures को समय पर identify और troubleshoot किया जा सके।

---

# 📌 Phase Overview

Phase 19 में हमारा focus है:

- 📊 Azure resources की monitoring
- 📝 Logs और activity की visibility
- 🚨 Important events की detection
- 🔍 Troubleshooting के लिए useful telemetry
- ⚙️ Terraform-managed infrastructure की observability
- 🔄 CI/CD pipeline failures की visibility
- 🛡️ Security-related events की monitoring

---

# 🏗️ Monitoring Architecture

हमारा overall monitoring flow:

```text
Azure Infrastructure
        │
        ├── Virtual Network
        ├── Subnets
        ├── NSG
        ├── NIC
        └── Future Azure Resources
        │
        ▼
   Azure Monitor
        │
        ├── Metrics
        ├── Activity Logs
        ├── Resource Logs
        └── Alerts
        │
        ▼
   Operations / Engineer
```

---

📊 19.1 — Monitoring vs Observability

दोनों terms similar हैं लेकिन exactly same नहीं हैं।

Monitoring

Monitoring का मतलब है:

System healthy है या नहीं?

Example:

CPU High
Memory High
Resource Unavailable
Pipeline Failed
Observability

Observability का मतलब है:

System में problem क्यों हुई?

इसके लिए हम देखते हैं:

Metrics
Logs
Events
Traces
Configuration

Simple example:

Monitoring:
"Pipeline Failed"

Observability:
"Pipeline क्यों Failed?"
        ↓
Terraform Validate
        ↓
Error Log
        ↓
Incorrect Configuration
☁️ 19.2 — Azure Monitor

Azure environment के लिए primary monitoring platform:

Azure Monitor

इसका उपयोग Azure resources से telemetry collect और analyze करने के लिए किया जा सकता है।

Typical telemetry:

Azure Resources
      │
      ▼
Azure Monitor
      │
      ├── Metrics
      ├── Logs
      ├── Activity Logs
      └── Alerts
📝 19.3 — Azure Activity Log

Azure Activity Log administrative और control-plane activities की visibility देता है।

Example:

Resource Created
Resource Deleted
Configuration Changed
Role Assignment Changed
Network Configuration Changed

Example scenario:

NSG Configuration
      │
      ▼
Configuration Changed
      │
      ▼
Activity Log
      │
      ▼
Investigation

यह security और operational troubleshooting दोनों के लिए useful है।

📈 19.4 — Metrics

Azure resources के लिए metrics infrastructure health समझने में मदद करते हैं।

Examples:

CPU Utilization
Network Traffic
Request Count
Availability
Resource Health

Future compute resources जैसे VM/App Gateway आदि आने के बाद metrics ज्यादा useful होंगे।

Example:

Application
    │
    ▼
High Traffic
    │
    ▼
Network Metrics
    │
    ▼
Performance Investigation
🚨 19.5 — Alerts

Monitoring का अगला important component है:

Alert

Example:

High CPU
    ↓
Threshold Crossed
    ↓
Alert Triggered
    ↓
Engineer Notification

Security-oriented examples:

Unexpected Resource Change
Unexpected Network Configuration
Critical Activity
Resource Failure

Alerts का purpose सिर्फ data collect करना नहीं है, बल्कि actionable event detect करना है।

🔐 19.6 — Security Monitoring

हमारे project में security पहले से CI pipeline में मौजूद है:

Terraform Code
      │
      ▼
Trivy
      │
      ▼
Security Validation

Phase 19 में इसका operational side add होता है:

Azure Infrastructure
      │
      ▼
Azure Monitoring
      │
      ├── Activity Logs
      ├── Resource Logs
      ├── Metrics
      └── Alerts

इससे security lifecycle:

Prevent
  ↓
Detect
  ↓
Investigate
  ↓
Respond

की तरफ जाता है।

🔍 19.7 — Troubleshooting Flow

Future में infrastructure issue आने पर हमारा troubleshooting flow:

Issue Detected
      │
      ▼
Azure Resource Health
      │
      ▼
Metrics
      │
      ▼
Activity Logs
      │
      ▼
Resource Logs
      │
      ▼
Root Cause
      │
      ▼
Remediation

Example:

Network Connectivity Problem
          │
          ▼
Check NSG
          │
          ▼
Check Activity Log
          │
          ▼
Check Network Configuration
          │
          ▼
Identify Change
          │
          ▼
Remediate
🔄 19.8 — CI/CD Observability

GitHub Actions pipeline में भी logs available हैं।

Current pipeline:

GitHub Push / Pull Request
          │
          ▼
GitHub Actions
          │
          ├── Azure Login
          ├── Terraform Format
          ├── Terraform Init
          ├── Terraform Validate
          ├── Trivy Scan
          └── Terraform Plan

हर stage का execution result:

PASS
FAIL
WARNING

के रूप में identify किया जा सकता है।

Example:

Trivy Scan
    │
    ├── 0 Findings → PASS
    │
    └── HIGH/CRITICAL → FAIL

इससे pipeline troubleshooting आसान होती है।

🛡️ 19.9 — Security + Monitoring Together

अब हमारा security architecture दो layers में divide हो रहा है:

                Security
                   │
        ┌──────────┴──────────┐
        │                     │
      CI/CD                 Runtime
        │                     │
        ▼                     ▼
     Trivy              Azure Monitor
        │                     │
        ▼                     ▼
Prevent Issues          Detect Issues
CI/CD Security

Infrastructure deploy होने से पहले security checks।

Runtime Monitoring

Infrastructure deploy होने के बाद operational visibility।

📋 19.10 — Current Project Position

अब तक हमने:

GitHub
   ↓
Terraform
   ↓
Azure
   ↓
GitHub Actions
   ↓
Terraform Validation
   ↓
Trivy Security Scan
   ↓
Terraform Plan

successfully establish किया है।

Phase 19 में हम इसमें monitoring layer जोड़ रहे हैं:

                     Azure
                       │
                ┌──────┴──────┐
                │             │
             Resources     Activity
                │             │
                └──────┬──────┘
                       ▼
                 Azure Monitor
                       │
              ┌────────┼────────┐
              ▼        ▼        ▼
           Metrics    Logs    Alerts


# 🎯 19.11 — Production Monitoring Goal


Final target architecture:

```text

Developer
    │
    ▼
GitHub
    │
    ▼
Pull Request
    │
    ▼
GitHub Actions
    │
    ├── Terraform Validate
    ├── Trivy Security Scan
    └── Terraform Plan
    │
    ▼
Approval
    │
    ▼
Terraform Apply
    │
    ▼
Azure Infrastructure
    │
    ▼
Azure Monitor
    │
    ├── Metrics
    ├── Logs
    ├── Activity Logs
    └── Alerts
    │
    ▼
Operations / Security Team
```
---
### 📊 Phase 19 Status

| Component | Status |
| :--- | :--- |
| **GitHub Actions Logs** | ![Status](https://img.shields.io/badge/Status-Available-brightgreen?style=flat-square) |
| **Terraform Pipeline Visibility** | ![Status](https://img.shields.io/badge/Status-Available-brightgreen?style=flat-square) |
| **Trivy Security Results** | ![Status](https://img.shields.io/badge/Status-Available-brightgreen?style=flat-square) |
| **Azure Activity Log** | ![Status](https://img.shields.io/badge/Status-Available-brightgreen?style=flat-square) |
| **Azure Monitor Foundation** | ![Status](https://img.shields.io/badge/Status-To_Configure-yellow?style=flat-square) |
| **Resource Metrics** | ![Status](https://img.shields.io/badge/Status-As_Resources_Are_Added-blue?style=flat-square) |
| **Centralized Logs** | ![Status](https://img.shields.io/badge/Status-Planned-orange?style=flat-square) |
| **Alert Rules** | ![Status](https://img.shields.io/badge/Status-Planned-orange?style=flat-square) |
| **Security Alerts** | ![Status](https://img.shields.io/badge/Status-Planned-orange?style=flat-square) |
| **Production Observability** | ![Status](https://img.shields.io/badge/Status-Next_Implementation-purple?style=flat-square) |

---

🧭 Phase 19 — Next Implementation Steps

अब practical implementation में हम क्रम से:

Step 01
Azure Monitor समझना
        ↓
Step 02
Log Analytics Workspace
        ↓
Step 03
Azure Monitor Configuration
        ↓
Step 04
Activity Log Monitoring
        ↓
Step 05
Resource Logs
        ↓
Step 06
Metric Alerts
        ↓
Step 07
Security Alerts
        ↓
Step 08
Terraform से Monitoring Resources Manage करना

करेंगे।

# 🏁 Phase 19 Outcome

Phase 19 में हमने अपने project के लिए Monitoring और Observability architecture define किया है। अब infrastructure security केवल deployment-time scanning तक limited नहीं है, बल्कि deployment के बाद logs, metrics, activity और alerts के माध्यम से continuous visibility की तरफ जा रही है।


```text

Current Security Lifecycle
        Terraform Code
              │
              ▼
       GitHub Actions
              │
              ▼
      Trivy Security Scan
              │
              ▼
       Terraform Plan
              │
              ▼
        Azure Deploy
              │
              ▼
       Azure Monitor
              │
       ┌──────┼──────┐
       ▼      ▼      ▼
     Logs  Metrics  Alerts
       │      │      │
       └──────┼──────┘
              ▼
       Detection & Response
```

# 🚀 Next Phase → Phase 20 — GitHub Organization + Repository Governance