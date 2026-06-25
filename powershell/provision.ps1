# ==========================================
# Azure Infrastructure Provisioning
# ==========================================

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\login.ps1"

Write-Host ""
Write-Host "===================================="
Write-Host "Creating Storage Account"
Write-Host "===================================="

az storage account create `
    --name $StorageAccountName `
    --resource-group $ResourceGroup `
    --location $Location `
    --sku $StorageSku

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Storage Account creation failed."
    exit 1
}

Write-Host ""
Write-Host "Storage Account created successfully."

Write-Host ""
Write-Host "===================================="
Write-Host "Retrieving App Service Plan"
Write-Host "===================================="

$AppServicePlanId = az appservice plan show `
    --resource-group $SharedPlanResourceGroup `
    --name $AppServicePlan `
    --query id `
    -o tsv

if (-not $AppServicePlanId) {
    Write-Host "ERROR: App Service Plan not found."
    exit 1
}

Write-Host ""
Write-Host "===================================="
Write-Host "Creating Web App"
Write-Host "===================================="

az webapp create `
    --resource-group $ResourceGroup `
    --plan $AppServicePlanId `
    --name $WebAppName `
    --runtime $Runtime

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Web App deployment failed."
    exit 1
}

$HostName = az webapp show `
    --resource-group $ResourceGroup `
    --name $WebAppName `
    --query defaultHostName `
    -o tsv

Write-Host ""
Write-Host "Application URL:"
Write-Host "https://$HostName"

Start-Process "https://$HostName"