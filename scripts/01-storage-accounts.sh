#!/bin/bash

# Variables
disableLocalAuth="true"
allowSharedKeyAccess="false"  
apiVersion="2023-04-01"

# Get all storage accounts
echo "Getting all storage accounts..."
ids=$(az storage account list --query '[].id' --output tsv)

# Loop through each storage account
for id in $ids; do
  
  # Get the name of the storage account
  name=$(echo $id | awk -F '/' '{print $9}')

  # Disable or enable shared key access
  if [ "$allowSharedKeyAccess" = "false" ]; then
    echo "Disabling shared key access for storage account [$name]..."
  else
    echo "Enabling shared key access for storage account [$name]..."
  fi

  az rest --method patch \
    --url "https://management.azure.com${id}?api-version=$apiVersion" \
    --headers "Content-Type=application/json" \
    --body "{\"properties\": {\"allowSharedKeyAccess\": $allowSharedKeyAccess}}" 1> /dev/null

  if [ $? -eq 0 ]; then
    if [ "$allowSharedKeyAccess" = "true" ]; then
      echo "Successfully enabled shared key access for storage account [$name]"
    else
      echo "Successfully disabled shared key access for storage account [$name]"
    fi
  else
    if [ "$allowSharedKeyAccess" = "true" ]; then
      echo "Failed to enable shared key access for storage account [$name]"
    else
      echo "Failed to disable shared key access for storage account [$name]"
    fi
    exit -1
  fi

done
