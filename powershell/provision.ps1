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
        --tags $Tags

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Container Instance creation failed."
        exit 1
    }
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