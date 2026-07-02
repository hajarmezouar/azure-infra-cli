# ==========================================
# Azure Infrastructure Provisioning
# ==========================================

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\login.ps1"

Write-Host ""
Write-Host "===================================="
Write-Host "Provision Azure Infrastructure"
Write-Host "===================================="

# ==========================================
# Retrieve Shared App Service Plan
# ==========================================

Write-Host ""
Write-Host "Retrieving App Service Plan..."

$AppServicePlanId = az appservice plan show `
    --resource-group $SharedPlanResourceGroup `
    --name $AppServicePlan `
    --query id `
    -o tsv

if (-not $AppServicePlanId) {
    Write-Host "ERROR: Shared App Service Plan not found."
    exit 1
}

# ==========================================
# Storage Account
# ==========================================

Write-Host ""
Write-Host "Checking Storage Account..."

$StorageExists = az storage account show `
    --name $StorageAccountName `
    --resource-group $ResourceGroup `
    --query name `
    -o tsv 2>$null

if ($StorageExists) {

    Write-Host "Storage Account already exists."

}
else {

    Write-Host "Creating Storage Account..."

    az storage account create `
        --name $StorageAccountName `
        --resource-group $ResourceGroup `
        --location $Location `
        --sku $StorageSku `
        --tags $Tags

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Storage Account creation failed."
        exit 1
    }
}

# ==========================================
# Web App
# ==========================================

Write-Host ""
Write-Host "Checking Web App..."

$WebAppExists = az webapp show `
    --resource-group $ResourceGroup `
    --name $WebAppName `
    --query name `
    -o tsv 2>$null

if ($WebAppExists) {

    Write-Host "Web App already exists."

}
else {

    Write-Host "Creating Web App..."

    az webapp create `
        --resource-group $ResourceGroup `
        --plan $AppServicePlanId `
        --name $WebAppName `
        --runtime $Runtime `
        --tags $Tags

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Web App creation failed."
        exit 1
    }
}

# ==========================================
# Function Storage Account
# ==========================================

Write-Host ""
Write-Host "Checking Function Storage Account..."

$FunctionStorageExists = az storage account show `
    --name $FunctionStorageAccountName `
    --resource-group $ResourceGroup `
    --query name `
    -o tsv 2>$null

if ($FunctionStorageExists) {

    Write-Host "Function Storage Account already exists."

}
else {

    Write-Host "Creating Function Storage Account..."

    az storage account create `
        --name $FunctionStorageAccountName `
        --resource-group $ResourceGroup `
        --location $Location `
        --sku $FunctionStorageSku `
        --tags $Tags

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Function Storage creation failed."
        exit 1
    }
}

# ==========================================
# Function App
# ==========================================

Write-Host ""
Write-Host "Checking Function App..."

$FunctionExists = az functionapp show `
    --resource-group $ResourceGroup `
    --name $FunctionAppName `
    --query name `
    -o tsv 2>$null

if ($FunctionExists) {

    Write-Host "Function App already exists."

}
else {

    Write-Host "Creating Function App..."

    az functionapp create `
        --resource-group $ResourceGroup `
        --plan "$AppServicePlanId" `
        --name $FunctionAppName `
        --storage-account $FunctionStorageAccountName `
        --runtime $FunctionRuntime `
        --runtime-version $FunctionRuntimeVersion `
        --functions-version $FunctionsVersion `
        --os-type Linux `
        --tags $Tags

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Function App creation failed."
        exit 1
    }

    Write-Host "Function App created successfully."
}

# ==========================================
# Azure Container Instance
# ==========================================

Write-Host ""
Write-Host "Checking Azure Container Instance..."

$ContainerExists = az container show `
    --resource-group $ResourceGroup `
    --name $ContainerGroupName `
    --query name `
    -o tsv 2>$null

if ($ContainerExists) {

    Write-Host "Container Instance already exists."

}
else {

    Write-Host "Creating Container Instance..."

    az container create `
        --resource-group $ResourceGroup `
        --name $ContainerGroupName `
        --image $ContainerImage `
        --dns-name-label $ContainerDnsName `
        --ports 80 `
        --cpu $ContainerCpu `
        --memory $ContainerMemory `
        --os-type Linux

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Container Instance creation failed."
        exit 1
    }

    Write-Host "Tagging Container Instance..."

    $ContainerId = az container show `
        --resource-group $ResourceGroup `
        --name $ContainerGroupName `
        --query id `
        -o tsv

    az resource tag `
        --ids $ContainerId `
        --tags $Tags

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Container Instance tagging failed."
        exit 1
    }

    Write-Host "Container Instance created successfully."
}

# ==========================================
# Virtual Network
# ==========================================

Write-Host ""
Write-Host "Checking Virtual Network..."

$VNetExists = az network vnet show `
    --resource-group $ResourceGroup `
    --name $VNetName `
    --query name `
    -o tsv 2>$null

if ($VNetExists) {
    Write-Host "Virtual Network already exists."
}
else {
    Write-Host "Creating Virtual Network with frontend subnet..."

    az network vnet create `
        --resource-group $ResourceGroup `
        --location $Location `
        --name $VNetName `
        --address-prefix $VNetAddressPrefix `
        --subnet-name $FrontendSubnetName `
        --subnet-prefixes $FrontendSubnetPrefix `
        --tags $Tags

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Virtual Network creation failed."
        exit 1
    }
}

# ==========================================
# Backend Subnet
# ==========================================

Write-Host ""
Write-Host "Checking Backend Subnet..."

$BackendSubnetExists = az network vnet subnet show `
    --resource-group $ResourceGroup `
    --vnet-name $VNetName `
    --name $BackendSubnetName `
    --query name `
    -o tsv 2>$null

if ($BackendSubnetExists) {
    Write-Host "Backend Subnet already exists."
}
else {
    Write-Host "Creating Backend Subnet..."

    az network vnet subnet create `
        --resource-group $ResourceGroup `
        --vnet-name $VNetName `
        --name $BackendSubnetName `
        --address-prefixes $BackendSubnetPrefix

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Backend Subnet creation failed."
        exit 1
    }
}

# ==========================================
# Network Security Group
# ==========================================

Write-Host ""
Write-Host "Checking Network Security Group..."

$NSGExists = az network nsg show `
    --resource-group $ResourceGroup `
    --name $NSGName `
    --query name `
    -o tsv 2>$null

if ($NSGExists) {
    Write-Host "Network Security Group already exists."
}
else {
    Write-Host "Creating Network Security Group..."

    az network nsg create `
        --resource-group $ResourceGroup `
        --location $Location `
        --name $NSGName `
        --tags $Tags

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Network Security Group creation failed."
        exit 1
    }
}

# ==========================================
# NSG Rule - HTTP
# ==========================================

Write-Host ""
Write-Host "Checking HTTP rule..."

$HttpRuleExists = az network nsg rule show `
    --resource-group $ResourceGroup `
    --nsg-name $NSGName `
    --name $HttpRuleName `
    --query name `
    -o tsv 2>$null

if ($HttpRuleExists) {
    Write-Host "HTTP rule already exists."
}
else {
    Write-Host "Creating HTTP rule..."

    az network nsg rule create `
        --resource-group $ResourceGroup `
        --nsg-name $NSGName `
        --name $HttpRuleName `
        --priority 100 `
        --direction Inbound `
        --access Allow `
        --protocol Tcp `
        --source-address-prefix "*" `
        --source-port-range "*" `
        --destination-address-prefix "*" `
        --destination-port-range 80
}

# ==========================================
# NSG Rule - HTTPS
# ==========================================

Write-Host ""
Write-Host "Checking HTTPS rule..."

$HttpsRuleExists = az network nsg rule show `
    --resource-group $ResourceGroup `
    --nsg-name $NSGName `
    --name $HttpsRuleName `
    --query name `
    -o tsv 2>$null

if ($HttpsRuleExists) {
    Write-Host "HTTPS rule already exists."
}
else {
    Write-Host "Creating HTTPS rule..."

    az network nsg rule create `
        --resource-group $ResourceGroup `
        --nsg-name $NSGName `
        --name $HttpsRuleName `
        --priority 110 `
        --direction Inbound `
        --access Allow `
        --protocol Tcp `
        --source-address-prefix "*" `
        --source-port-range "*" `
        --destination-address-prefix "*" `
        --destination-port-range 443
}

# ==========================================
# NSG Rule - Deny All Inbound
# ==========================================

Write-Host ""
Write-Host "Checking Deny-All-Inbound rule..."

$DenyRuleExists = az network nsg rule show `
    --resource-group $ResourceGroup `
    --nsg-name $NSGName `
    --name $DenyRuleName `
    --query name `
    -o tsv 2>$null

if ($DenyRuleExists) {
    Write-Host "Deny-All-Inbound rule already exists."
}
else {
    Write-Host "Creating Deny-All-Inbound rule..."

    az network nsg rule create `
        --resource-group $ResourceGroup `
        --nsg-name $NSGName `
        --name $DenyRuleName `
        --priority 4000 `
        --direction Inbound `
        --access Deny `
        --protocol "*" `
        --source-address-prefix "*" `
        --source-port-range "*" `
        --destination-address-prefix "*" `
        --destination-port-range "*"
}

# ==========================================
# Associate NSG to Frontend Subnet
# ==========================================

Write-Host ""
Write-Host "Associating NSG with frontend subnet..."

az network vnet subnet update `
    --resource-group $ResourceGroup `
    --vnet-name $VNetName `
    --name $FrontendSubnetName `
    --network-security-group $NSGName

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: NSG association failed."
    exit 1
}

# ==========================================
# Outputs
# ==========================================

Write-Host ""
Write-Host "===================================="
Write-Host "Deployment completed successfully!"
Write-Host "===================================="

$WebAppUrl = az webapp show `
    --resource-group $ResourceGroup `
    --name $WebAppName `
    --query defaultHostName `
    -o tsv

$FunctionUrl = az functionapp show `
    --resource-group $ResourceGroup `
    --name $FunctionAppName `
    --query defaultHostName `
    -o tsv

Write-Host ""
Write-Host "Web App URL:"
Write-Host "https://$WebAppUrl"

Write-Host ""
Write-Host "Function App URL:"
Write-Host "https://$FunctionUrl"

Start-Process "https://$WebAppUrl"