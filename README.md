# Disable Local Auth for Azure Resources via Script

Azure provides [Microsoft Entra authentication](https://learn.microsoft.com/en-us/entra/identity/authentication/overview-authentication) support for all resources. This gives organizations control to disable local authentication methods and enforce Microsoft Entra authentication. This feature provides you with seamless integration when you require centralized control and management of identities and resource credentials.

If you're creating Azure resources using Terraform, Bicep, or ARM, you can set the property `disableLocalAuth` to `true` to disable local authentication. You can disable local authentication using an Azure policy, such as [Cognitive Services accounts should have local authentication methods disabled](https://ms.portal.azure.com/#view/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2F71ef260a-8f18-47b7-abcb-62d0673d94dc). You can set it at the subscription level or resource group level to enforce the policy for a group of services. As an alternative, you can create a Bash or PowerShell script to disable the local authentication for all the resources of a certain type in a subscription. Disabling local authentication doesn't take effect immediately. Allow a few minutes for the service to block future authentication requests. This repository contains Bash scripts to quickly disable the local authentication for Azure resources in the current subscription. At this time, scripts are available for the following resource types:

- Azure Storage Accounts
- Azure Service Bus Namespaces
- Azure OpenAI Service Accounts
- Azure Event Grid Topics
- Azure SQL Servers
- Azure Cosmos DB Accounts
- Azure App Configuration Stores

As an example, here is the Bash script to disable local account authentication for Azure Cosmos DB Accounts:

```bash
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

  if ( "$disableLocalAuth" = "true" ); then
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
    if ( "$disableLocalAuth" = "true" ); then
      echo "Successfully disabled local authentication for cosmos db instance [$name]"
    else
      echo "Successfully enabled local authentication for cosmos db instance [$name]"
    fi
  else
    if ( "$disableLocalAuth" = "true" ); then
      echo "Failed to disable local authentication for cosmos db instance [$name]"
    else
      echo "Failed to enable local authentication for cosmos db instance [$name]"
    fi
    exit -1
  fi
done
```
