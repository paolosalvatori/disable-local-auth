#!/bin/bash

# Variables
disableLocalAuth="true"
allowSharedKeyAccess="false"
apiVersion="2023-04-01"

# When restrictAccessToYourIP is set to true, the script will restrict access to your IP address.
# Otherwise, it will disable public access to the storage account.
restrictAccessToYourIP="true"

# Get all storage accounts
echo "Getting all storage accounts..."
ids=$(az storage account list --query '[].id' --output tsv)

if [ "$restrictAccessToYourIP" = "true" ]; then
  echo "Finding your public IP address..."
  ip=$(curl -s ifconfig.me)
  echo "Your public IP address is [$ip]"
fi

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
    --body "{\"properties\": {\"allowSharedKeyAccess\": $allowSharedKeyAccess}}" 1>/dev/null

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

  if [ "$restrictAccessToYourIP" = "true" ]; then
    echo "Restricting access to your IP address [$ip] for storage account [$name]..."
    az rest --method patch \
      --url "https://management.azure.com${id}?api-version=$apiVersion" \
      --headers "Content-Type=application/json" \
      --body "{\"properties\": {\"publicNetworkAccess\": \"Enabled\", \"networkAcls\": {\"bypass\": \"Logging, Metrics, AzureServices\", \"ipRules\": [{\"value\": \"${ip}\",\"action\": \"Allow\"}], \"defaultAction\": \"Deny\"}}}" 1>/dev/null

    if [ $? -eq 0 ]; then
      echo "Successfully restricted access to your IP address [$ip] for storage account [$name]"
    else
      echo "Failed to restrict access to your IP address [$ip] for storage account [$name]"
      exit -1
    fi
  else
    echo "Disabling public access for storage account [$name]..."
    az rest --method patch \
      --url "https://management.azure.com${id}?api-version=$apiVersion" \
      --headers "Content-Type=application/json" \
      --body "{\"properties\": {\"publicNetworkAccess\": \"Disabled\", \"networkAcls\": {\"bypass\": \"AzureServices\", \"defaultAction\": \"Deny\"}}}" 1>/dev/null
    
    if [ $? -eq 0 ]; then
      echo "Successfully disabled public access for storage account [$name]"
    else
      echo "Failed to disable public access for storage account [$name]"
      exit -1
    fi
  fi

done
