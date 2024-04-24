#!/bin/bash

# Variables
disableLocalAuth="true"
apiVersion="2024-02-15-preview"

# Get all cosmos db instances
echo "Getting all cosmos db instances..."
ids=$(az cosmosdb list --query '[].id' --output tsv)

# Loop through each cosmos db instance
for id in $ids; do
  
  # Get the name of the cosmos db instance
  name=$(echo $id | awk -F '/' '{print $9}')

  if [ "$disableLocalAuth" = "true" ]; then
    echo "Disabling local authentication for cosmos db instance [$name]..."
  else
    echo "Enabling local authentication for cosmos db instance [$name]..."
  fi

  # Disable or enable local authentication
  az rest --method patch \
    --url "https://management.azure.com${id}?api-version=$apiVersion" \
    --headers "Content-Type=application/json" \
    --body "{\"properties\": {\"disableLocalAuth\": $disableLocalAuth}}" 1> /dev/null
  
  if [ $? -eq 0 ]; then
    if [ "$disableLocalAuth" = "true" ]; then
      echo "Successfully disabled local authentication for cosmos db instance [$name]"
    else
      echo "Successfully enabled local authentication for cosmos db instance [$name]"
    fi
  else
    if [ "$disableLocalAuth" = "true" ]; then
      echo "Failed to disable local authentication for cosmos db instance [$name]"
    else
      echo "Failed to enable local authentication for cosmos db instance [$name]"
    fi
    exit -1
  fi
done