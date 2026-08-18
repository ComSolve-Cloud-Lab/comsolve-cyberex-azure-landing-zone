---

# 📗 `docs/phase-02-github-repository-secrets.md`



```markdown
# 🐙 Phase 02 — GitHub Repository & Secrets

<p align="center">

![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Security](https://img.shields.io/badge/Secrets-Secure-success?style=for-the-badge)

</p > 🎯 **Objective:** Establish a secure connection between GitHub and Azure for future Terraform and GitHub Actions automation.

---

# 🧭 Phase Overview

```text
                 🐙 GITHUB
                    │
                    ▼
              📦 Repository
                    │
                    ▼
           🔐 GitHub Secrets
                    │
        ┌───────────┼───────────┐
        │           │           │
        ▼           ▼           ▼
    Client ID    Tenant ID   Subscription ID
        │
        ▼
    Client Secret
        │
        └───────────┬───────────┘
                    ▼
             Microsoft Entra ID
                    │
                    ▼
            👤 Service Principal
                    │
               Contributor
                    │
                    ▼
              ☁️ Azure
