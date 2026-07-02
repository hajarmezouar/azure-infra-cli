# Azure Infra CLI

Infrastructure-as-Code project for provisioning Azure resources using **Azure CLI**, **PowerShell**, **Bash**, and **GitHub Actions**.

This repository automates the creation, validation, deployment, and cleanup of Azure infrastructure for training and DevOps practice.

---

## Features

### Compute Resources
- Azure Storage Account
- Azure App Service (Web App)
- Azure Function App
- Azure Container Instance (ACI)

### Network Resources
- Virtual Network (VNet)
- Frontend subnet
- Backend subnet
- Network Security Group (NSG)
- HTTP / HTTPS filtering rules

### Automation
- PowerShell provisioning scripts
- Bash provisioning scripts
- CI validation with GitHub Actions
- Manual infrastructure deployment workflow
- Weekly cleanup workflow
- Dependabot for workflow updates

---

## Architecture

```text
Internet
   │
   ▼
Network Security Group
 ├─ Allow HTTP  (80)
 ├─ Allow HTTPS (443)
 └─ Deny everything else

        │
        ▼
VNet 10.0.0.0/16
├── subnet-frontend (10.0.1.0/24)
│   ├── App Service
│   ├── Function App
│   └── Container Instance
│
└── subnet-backend (10.0.2.0/24)
    └── Future database / internal services
```

---

## Repository Structure

```text
azure-infra-cli/
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── infra.yml
│   │   ├── deploy.yml
│   │   └── weekly-cleanup.yml
│   └── dependabot.yml
│
├── app/
│   └── index.php
│
├── bash/
│   ├── provision.sh
│   └── destroy.sh
│
├── powershell/
│   ├── config.ps1
│   ├── login.ps1
│   ├── provision.ps1
│   └── destroy.ps1
│
└── README.md
```

---

## Prerequisites

Install:

- PowerShell 7+
- Azure CLI
- Git
- Azure subscription access

Login:

```bash
az login
```

Verify:

```bash
az account show
```

---

## Configuration

Main variables are stored in:

```text
powershell/config.ps1
```

Examples:

```powershell
$ResourceGroup = "hmezouarRG"
$Location = "francecentral"
$StorageAccountName = "sthajarcli"
$WebAppName = "webapp-az900-hajar"
```

---

## Provision Infrastructure

PowerShell:

```powershell
.\powershell\provision.ps1
```

Bash:

```bash
./bash/provision.sh
```

Resources created:

- Storage Account
- Web App
- Function App
- Container Instance
- VNet
- Frontend subnet
- Backend subnet
- NSG with security rules

---

## Destroy Infrastructure

PowerShell:

```powershell
.\powershell\destroy.ps1
```

Bash:

```bash
./bash/destroy.sh
```

Important:
- Deletes resources only
- Keeps the Resource Group intact

---

## Deploy Sample Application

Sample PHP application:

```php
<?php
echo "<h1>Hello from Hajar Azure Infra CLI</h1>";
?>
```

Create zip:

```powershell
Compress-Archive -Path .\app\* -DestinationPath .\app.zip -Force
```

Deploy:

```powershell
az webapp deploy `
  --resource-group hmezouarRG `
  --name webapp-az900-hajar `
  --src-path .\app.zip `
  --type zip
```

---

## GitHub Actions

### CI Workflow
Validates:
- PowerShell syntax
- Bash syntax
- Azure login

### Infra Workflow
Manual workflow to:
- provision infrastructure
- destroy infrastructure

### Deploy Workflow
Deploy application to Azure Web App.

### Weekly Cleanup
Runs every Friday to clean infrastructure.

---

## Azure Authentication (OIDC)

Authentication is done using **OpenID Connect**.

Required GitHub Secrets:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

No passwords or certificates are used.

---

## Learning Objectives

This project demonstrates:

- Azure CLI automation
- Infrastructure as Code principles
- CI/CD with GitHub Actions
- OIDC authentication
- Cloud networking fundamentals
- Resource lifecycle management

---

## Author

Hajar Mezouar  
DevOps Cloud Training — Simplon