$rgName="vwanaks-rg"
$location="uksouth"
$APP_ID=$(az keyvault secret show --name "clientid" --vault-name "maksh-key-vault" --query value)
$APP_SECRET=$(az keyvault secret show --name "clientsecret" --vault-name "maksh-key-vault" --query value)
$TENANT_ID=$(az keyvault secret show --name "tenantid" --vault-name "maksh-key-vault" --query value)

# Login
az login --service-principal --username $APP_ID --password $APP_SECRET --tenant $TENANT_ID

# Create Resource Group
az group create -n $rgName  -l $location

# Enable Key Vault for ARM Deployment access (Only 1 time)
az keyvault update --enabled-for-template-deployment true -n maksh-key-vault

# Validate ARM
az deployment group validate -g $rgName `
    --template-file azuredeploy.json `
    --parameters azuredeploy.parameters.json

# Validate exisiting ARM 1
az deployment group validate -g $rgName `
    --template-file azuredeploy2.json `
    --parameters azuredeploy2.parameters.json

# Validate exisiting ARM 2
az deployment group validate -g $rgName `
    --template-file .\ad.json 

# Validate exisiting ARM 3
az deployment group validate -g $rgName `
    --template-file arm-aks.json `
    --parameters .\arm-aks-parameters2.json