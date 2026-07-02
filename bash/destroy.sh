#!/bin/bash

RESOURCE_GROUP="rg-hajar-mezouar-prf2026"
WEBAPP="webapp-az900-hajar"

echo "Deleting Web App..."

az webapp delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEBAPP"

echo "Done."