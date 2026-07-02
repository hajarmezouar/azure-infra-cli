# ==========================================
# Azure Infrastructure Cleanup
# ==========================================

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\login.ps1"

Write-Host ""
Write-Host "===================================="
Write-Host "Deleting Azure Infrastructure"
Write-Host "===================================="

# ==========================================
# Container Instance
# ==========================================

Write-Host ""
Write-Host "Checking Container Instance..."

$ContainerExists = az container show `
    --resource-group $ResourceGroup `
    --name $ContainerGroupName `
    --query name `
    -o tsv 2>$null

if ($ContainerExists) {

    Write-Host "Deleting Container Instance..."

    az container delete `
        --resource-group $ResourceGroup `
        --name $ContainerGroupName `
        --yes

}
else {

    Write-Host "Container Instance already deleted."

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

    Write-Host "Deleting Function App..."

    az functionapp delete `
        --resource-group $ResourceGroup `
        --name $FunctionAppName

}
else {

    Write-Host "Function App already deleted."

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

    Write-Host "Deleting Function Storage Account..."

    az storage account delete `
        --name $FunctionStorageAccountName `
        --resource-group $ResourceGroup `
        --yes

}
else {

    Write-Host "Function Storage Account already deleted."

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

    Write-Host "Deleting Web App..."

    az webapp delete `
        --resource-group $ResourceGroup `
        --name $WebAppName `
        --keep-empty-plan

}
else {

    Write-Host "Web App already deleted."

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

    Write-Host "Deleting Storage Account..."

    az storage account delete `
        --name $StorageAccountName `
        --resource-group $ResourceGroup `
        --yes

}
else {

    Write-Host "Storage Account already deleted."

}

Write-Host ""
Write-Host "===================================="
Write-Host "Cleanup completed successfully!"
Write-Host "===================================="