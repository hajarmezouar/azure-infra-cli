# ==========================================
# Azure Infrastructure Cleanup
# ==========================================

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\login.ps1"


Write-Host ""
Write-Host "Deleting Web App..."

az webapp delete `
    --resource-group $ResourceGroup `
    --name $WebAppName

Write-Host ""
Write-Host "Deleting Storage Account..."

az storage account delete `
    --name $StorageAccountName `
    --resource-group $ResourceGroup `
    --yes


if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Storage Account deletion failed."
    exit 1
}

Write-Host ""
Write-Host "Storage Account deleted successfully."

Write-Host ""
Write-Host "Cleanup completed."