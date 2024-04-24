#!/bin/bash

# Variables
disableLocalAuth="true"
apiVersion="2023-03-01"

# Get all app configuration stores
echo "Getting all app configuration stores..."
ids=$(az appconfig list --query '[].id' --output tsv)

# Loop through each app configuration store
for id in $ids; do
  
  # Get the name of the app configuration store
  name=$(echo $id | awk -F '/' '{print $9}')

  if [ "$disableLocalAuth" = "true" ]; then
    echo "Disabling local authentication for app configuration store [$name]..."
  else
    echo "Enabling local authentication for app configuration store [$name]..."
  fi

  # Disable or enable local authentication
  az rest --method patch \
    --url "https://management.azure.com${id}?api-version=$apiVersion" \
    --headers "Content-Type=application/json" \
    --body "{\"properties\": {\"disableLocalAuth\": $disableLocalAuth}}" 1> /dev/null
  
  if [ $? -eq 0 ]; then
    if [ "$disableLocalAuth" = "true" ]; then
      echo "Successfully disabled local authentication for app configuration store [$name]"
    else
      echo "Successfully enabled local authentication for app configuration store [$name]"
    fi
  else
    if [ "$disableLocalAuth" = "true" ]; then
      echo "Failed to disable local authentication for app configuration store [$name]"
    else
      echo "Failed to enable local authentication for app configuration store [$name]"
    fi
    exit -1
  fi
done