#!/bin/bash

# Variables
disableLocalAuth="true"
apiVersion="2023-05-01-preview"

# Get all sql server instances
echo "Getting all sql server instances..."
ids=$(az sql server list --query '[].id' --output tsv)

# Loop through each sql server instance
for id in $ids; do
  
  # Get the name of the sql server instance
  name=$(echo $id | awk -F '/' '{print $9}')

  if [ "$disableLocalAuth" = "true" ]; then
    echo "Disabling local authentication for sql server instance [$name]..."
  else
    echo "Enabling local authentication for sql server instance [$name]..."
  fi

  # Disable or enable local authentication
  az rest --method patch \
    --url "https://management.azure.com${id}?api-version=$apiVersion" \
    --headers "Content-Type=application/json" \
    --body "{\"properties\": {\"disableLocalAuth\": $disableLocalAuth}}" 1> /dev/null
  
  if [ $? -eq 0 ]; then
    if [ "$disableLocalAuth" = "true" ]; then
      echo "Successfully disabled local authentication for sql server instance [$name]"
    else
      echo "Successfully enabled local authentication for sql server instance [$name]"
    fi
  else
    if [ "$disableLocalAuth" = "true" ]; then
      echo "Failed to disable local authentication for sql server instance [$name]"
    else
      echo "Failed to enable local authentication for sql server instance [$name]"
    fi
    exit -1
  fi
done