$rgName="vwanaks-rg"
$location="uksouth"
$deploymentName="vwanaks-deployment"
$APP_ID=$(az keyvault secret show --name "clientid" --vault-name "<???>" --query value)
$APP_SECRET=$(az keyvault secret show --name "clientsecret" --vault-name "<???>" --query value)
$TENANT_ID=$(az keyvault secret show --name "tenantid" --vault-name "<???>" --query value)

# Login
az login --service-principal --username $APP_ID --password $APP_SECRET --tenant $TENANT_ID

# Create Resource Group
az group create -n $rgName  -l $location

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