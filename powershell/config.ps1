# ==========================================
# Azure Infrastructure Configuration
# ==========================================

# Resource Group
$ResourceGroup = "hmezouarRG"

# Azure Region
$Location = "francecentral"

# Shared App Service Plan
$SharedPlanResourceGroup = "rg-shared-prf2026"
$AppServicePlan = "plan-npr-prf2026"

# Tags
$Tags = "managed_by=cli"

# ===========================
# Storage Account
# ===========================

$StorageAccountName = "sthajarprf2026"
$StorageSku = "Standard_LRS"

# ===========================
# Web App
# ===========================

$WebAppName = "webapp-az900-hajar"
$Runtime = "PHP:8.2"

# ===========================
# Function App
# ===========================

$FunctionStorageAccountName = "stfunchajar2026"
$FunctionStorageSku = "Standard_LRS"

$FunctionAppName = "func-hajar"

$FunctionRuntime = "python"
$FunctionRuntimeVersion = "3.11"
$FunctionsVersion = "4"

# ==========================================
# Networking
# ==========================================

$VNetName = "vnet-hajar-cli"
$VNetAddressPrefix = "10.0.0.0/16"

$FrontendSubnetName = "subnet-frontend"
$FrontendSubnetPrefix = "10.0.1.0/24"

$BackendSubnetName = "subnet-backend"
$BackendSubnetPrefix = "10.0.2.0/24"

$NSGName = "nsg-hajar-cli"

$HttpRuleName = "Allow-HTTP"
$HttpsRuleName = "Allow-HTTPS"
$DenyRuleName = "Deny-All-Inbound"

# ===========================
# Azure Container Instance
# ===========================

$ContainerGroupName = "aci-hajar"

$ContainerImage = "mcr.microsoft.com/azuredocs/aci-helloworld"

$ContainerDnsName = "aci-hajar"

$ContainerCpu = 1

$ContainerMemory = 1.5