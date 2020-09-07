NUM="01"
AKS_NAME="fido-aks$NUM-poc"
DEPLOYMENT_NAME="fido-deploy$NUM-poc"
LOCATION="eastus"
RESOURCE_GROUP_NAME="fido-rg$NUM-poc"
SUBNET_NAME="aks"
VNET_NAME="fido-vnet$NUM-poc"

# Create resource group
az group create \
    --name $RESOURCE_GROUP_NAME  \
    --location $LOCATION

# Create vnet
az network vnet create \
    --name $VNET_NAME \
    --address-prefix 10.100.0.0/16 \
    --location $LOCATION \
    --resource-group $RESOURCE_GROUP_NAME \
    --subnet-name $SUBNET_NAME \
    --subnet-prefix 10.100.0.0/24

# Enable the key vault for template deployment
az keyvault update \
    --enabled-for-template-deployment true \
    --name "hub-keyvault-0616140807"

# Deploy the ARM template
az deployment group create \
    --name $DEPLOYMENT_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --template-file arm-aks.json \
    --parameters \
        location=$LOCATION \
        managedClusterName=$AKS_NAME \
        existingVirtualNetworkResourceGroup=$RESOURCE_GROUP_NAME \
        existingVirtualNetworkName=$VNET_NAME \
        existingSubnetName=$SUBNET_NAME \
        agentPoolImageVersion="AKSUbuntu-1604-2020.06.25" \
        mgmtAgentPoolImageVersion="AKSUbuntu-1604-2020.06.25" \
    --parameters arm-aks-parameters.json



