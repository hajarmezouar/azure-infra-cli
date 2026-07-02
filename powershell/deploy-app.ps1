# ==========================================
# Deploy Sample PHP App to Azure Web App
# ==========================================

. "$PSScriptRoot\config.ps1"
. "$PSScriptRoot\login.ps1"

Write-Host ""
Write-Host "===================================="
Write-Host "Deploying PHP App"
Write-Host "===================================="

$AppPath = Join-Path $PSScriptRoot "..\app"
$ZipPath = Join-Path $PSScriptRoot "..\app.zip"

if (-not (Test-Path $AppPath)) {
    Write-Host "ERROR: app folder not found."
    exit 1
}

Write-Host "Creating app.zip..."

Compress-Archive `
    -Path "$AppPath\*" `
    -DestinationPath $ZipPath `
    -Force

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create ZIP package."
    exit 1
}

Write-Host "Deploying app.zip to Azure Web App..."

az webapp deploy `
    --resource-group $ResourceGroup `
    --name $WebAppName `
    --src-path $ZipPath `
    --type zip

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Web App deployment failed."
    exit 1
}

Write-Host ""
Write-Host "App deployed successfully!"

$WebAppUrl = az webapp show `
    --resource-group $ResourceGroup `
    --name $WebAppName `
    --query defaultHostName `
    -o tsv

Write-Host "URL:"
Write-Host "https://$WebAppUrl"