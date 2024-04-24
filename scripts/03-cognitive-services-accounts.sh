#!/bin/bash

# Variables
disableLocalAuth="true"
apiVersion="2023-05-01"

# Get all cognitive services accounts
echo "Getting all cognitive services accounts..."
ids=$(az cognitiveservices account list --query "[].id" --output tsv)

# Loop through each cognitive services account
for id in $ids; do
  
  # Get the name of the cognitive services account
  name=$(echo $id | awk -F '/' '{print $9}')

  # Disable or enable local authentication
  if ( "$disableLocalAuth" = "true" ); then
    echo "Disabling local authentication for cognitive services account [$name]..."
  else
    echo "Enabling local authentication for cognitive services account [$name]..."
  fi
  
  az rest --method patch \
    --url "https://management.azure.com${id}?api-version=$apiVersion" \
    --headers "Content-Type=application/json" \
    --body "{\"properties\": {\"disableLocalAuth\": $disableLocalAuth}}" 1> /dev/null
  
  if [ $? -eq 0 ]; then
    if ( "$disableLocalAuth" = "true" ); then
      echo "Successfully disabled local authentication for cognitive services account [$name]"
    else
      echo "Successfully enabled local authentication for cognitive services account [$name]"
    fi
  else
    if ( "$disableLocalAuth" = "true" ); then
      echo "Failed to disable local authentication for cognitive services account [$name]"
    else
      echo "Failed to enable local authentication for cognitive services account [$name]"
    fi
    exit -1
  fi
done
