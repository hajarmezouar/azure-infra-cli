# ==========================================
# Azure Login
# ==========================================

Write-Host ""
Write-Host "===================================="
Write-Host "Azure Login"
Write-Host "===================================="

az account show 2>$null

if ($LASTEXITCODE -ne 0) {
    az login
}

az account set `
    --subscription "5e683e0f-b00c-48d6-9769-5aaf598de8f1"

Write-Host ""
Write-Host "Current Azure Subscription"

az account show --output table