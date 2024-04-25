#!/bin/bash

# Variables
disableLocalAuth="true"
apiVersion="2023-01-01-preview"

# Get all event hub ids
echo "Getting all event hub ids..."
ids=$(az eventhubs namespace list --query '[].id' --output tsv)

# Loop through each event hub namespace
for id in $ids; do
  
  # Get the name of the event hub namespace
  name=$(echo $id | awk -F '/' '{print $9}')

  if [ "$disableLocalAuth" = "true" ]; then
    echo "Disabling local authentication for event hub namespace [$name]..."
  else
    echo "Enabling local authentication for event hub namespace [$name]..."
  fi

  # Disable or enable local authentication
  az rest --method patch \
    --url "https://management.azure.com${id}?api-version=$apiVersion" \
    --headers "Content-Type=application/json" \
    --body "{\"properties\": {\"disableLocalAuth\": $disableLocalAuth}}" 1> /dev/null
  
  if [ $? -eq 0 ]; then
    if [ "$disableLocalAuth" = "true" ]; then
      echo "Successfully disabled local authentication for event hub namespace [$name]"
    else
      echo "Successfully enabled local authentication for event hub namespace [$name]"
    fi
  else
    if [ "$disableLocalAuth" = "true" ]; then
      echo "Failed to disable local authentication for event hub namespace [$name]"
    else
      echo "Failed to enable local authentication for event hub namespace [$name]"
    fi
    exit -1
  fi
done