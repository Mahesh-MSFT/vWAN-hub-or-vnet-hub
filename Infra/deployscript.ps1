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
Get-AzADSpCredential -ServicePrincipalName http://maksh-super-sp

$APP_SECRET_PT = $APP_SECRET | ConvertFrom-SecureString -AsPlainText

$pscredential = Get-Credential -UserName $sp.ApplicationId

$psCredential = New-Object System.Management.Automation.PSCredential($APP_ID, )
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $TENANT_ID
Get-AzP2sVpnGatewayVpnProfile -Name vwanHubVnetGateway `
    -ResourceGroupName $rgName `
    -AuthenticationMethod EAPTLS


ProfileUrl : https://nfvprodsuppby.blob.core.windows.net/vpnprofileimmutable/8cf00031-37ec-4949-b74a-48f9021bf4c0/vpnprofile/2f132439-1051-44c6-9128-b704c1c48cf7/vpnclientconfiguration.zip?sv=2017-04-17&sr=b&sig=HmBSprVrs
             6hDY3x1HX958nimOjavnEjL2rlSuKIIW8Q%3D&st=2019-10-25T19%3A20%3A04Z&se=2019-10-25T20%3A20%3A04Z&sp=r&fileExtension=.zip
az extension add --name virtual-wan
az network p2s-vpn-gateway list -g $rgName
az network vpn-site list -g $rgName
az network p2s-vpn-gateway show -n vwanHubVnetGateway -g $rgName
az network  p2s-vpn-gateway --help