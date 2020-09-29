$rgName="vwanaks-rg"
$location="uksouth"
$deploymentName="vwanaks-deployment"
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

# Validate Hub VNET ARM template
az deployment group validate -g $rgName `
    --template-file .\Infra\az-vnet-hub.json `
    --parameters .\Infra\az-vnet-hub-param.json

# Deploy Hub VNET ARM template
az deployment group create `
    -n $deploymentName `
    -g $rgName `
    --template-file .\Infra\az-vnet-hub.json `
    --parameters .\Infra\az-vnet-hub-param.json

# After the Azure Resources are created, generate & download the VPN client
# Get-AzureRmVpnClientPackage -ResourceGroupName $RG -VirtualNetworkGatewayName $GWName -ProcessorArchitecture Amd64
az network vnet-gateway vpn-client generate -n hubvnetGateway `
    --processor-architecture Amd64 `
    -g $rgName
    
az network vnet-gateway vpn-client show-url -g $rgName -n hubvnetGateway

# After the vWAN Azure Resources are created, generate & download the VPN client
Connect-AzAccount
Get-AzP2sVpnGatewayVpnProfile -Name vwanHubVnetGateway `
    -ResourceGroupName $rgName `
    -AuthenticationMethod EAPTLS