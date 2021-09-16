# https://docs.microsoft.com/en-us/azure/firewall/firewall-faq

# Connect
Connect-AzAccount

# Stop an existing firewall
$azfw = Get-AzFirewall -Name "aks-rbac-firewall" -ResourceGroupName "aks-rbac-rg"
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw