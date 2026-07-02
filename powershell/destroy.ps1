# ==========================================
# Azure Infrastructure Cleanup
# ==========================================
#
# Purpose:
# Delete all resources created by provision.ps1
#
# Important:
# - Resources are deleted in dependency-safe order
# - Resource Group is NEVER deleted
# - Main RG is preserved
#
# Used by:
# - Manual local cleanup
# - GitHub weekly cleanup workflow
#
# ==========================================

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\login.ps1"

Write-Host ""
Write-Host "===================================="
Write-Host "Deleting Azure Infrastructure"
Write-Host "===================================="

# ==========================================
# Remove NSG association from frontend subnet
# ==========================================

Write-Host ""
Write-Host "Checking frontend subnet..."

$FrontendSubnetExists = az network vnet subnet show `
    --resource-group $ResourceGroup `
    --vnet-name $VNetName `
    --name $FrontendSubnetName `
    --query name `
    -o tsv 2>$null

if ($FrontendSubnetExists) {
    Write-Host "Removing NSG association from frontend subnet..."

    az network vnet subnet update `
        --resource-group $ResourceGroup `
        --vnet-name $VNetName `
        --name $FrontendSubnetName `
        --network-security-group "" 2>$null
}
else {
    Write-Host "Frontend subnet already deleted."
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
    Write-Host "Deleting Network Security Group..."

    az network nsg delete `
        --resource-group $ResourceGroup `
        --name $NSGName
}
else {
    Write-Host "Network Security Group already deleted."
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
    Write-Host "Deleting Virtual Network..."

    az network vnet delete `
        --resource-group $ResourceGroup `
        --name $VNetName
}
else {
    Write-Host "Virtual Network already deleted."
}

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
Write-Host "Resource Group preserved."
Write-Host "===================================="