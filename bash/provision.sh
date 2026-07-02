#!/bin/bash

RESOURCE_GROUP="rg-hajar-mezouar-prf2026"
PLAN="plan-npr-prf2026"
WEBAPP="webapp-az900-hajar"
RUNTIME="PHP:8.2"

echo "Deploying Azure Web App..."

az webapp create \
  --resource-group "$RESOURCE_GROUP" \
  --plan "$PLAN" \
  --name "$WEBAPP" \
  --runtime "$RUNTIME"

URL=$(az webapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEBAPP" \
  --query defaultHostName \
  -o tsv)

echo ""
echo "Application URL:"
echo "https://$URL"