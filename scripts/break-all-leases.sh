# Set variables for your storage account and container
ACCOUNT_NAME=stoalzeswes001tntx
CONTAINER_NAME=es-tfstate

# Login if not already logged in
az login --tenant TENANT_ID

# Optional: Set the account to be used if you have multiple accounts
az account set --subscription SUBSCRIPTION_NAME

# List all blobs in the specified container and break the lease for each blob
az storage blob list --account-name "$ACCOUNT_NAME" --container-name "$CONTAINER_NAME" --query "[].name" -o tsv |
  while read -r blobname; do
    az storage blob lease break --account-name "$ACCOUNT_NAME" --container-name "$CONTAINER_NAME" --blob-name "$blobname"
    echo "Lease broken for blob: $blobname"
  done
