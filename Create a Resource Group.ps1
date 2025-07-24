#Install and import only required modules
Write-Host "Installing and importing required Azure modules..."
Install-Module Az.Accounts -Scope CurrentUser -Force
Install-Module Az.Resources -Scope CurrentUser -Force
Install-Module Az.Network -Scope CurrentUser -Force
Install-Module Az.Compute -Scope CurrentUser -Force

Import-Module Az.Accounts
Import-Module Az.Resources
Import-Module Az.Network
Import-Module Az.Compute

#Login
Connect-AzAccount

$resourceGroup = Read-Host "Name the resource group for the VM (e.g. myResourceGroup)"
$Location = Read-Host "Enter the Azure region for the Resource Group (e.g. eastus, westus, etc.)"

# Create resource group
New-AzResourceGroup -Name $resourceGroup -Location $Location

Read-Host "Resource Group "$resourceGroup" created. Verify on Azure portal. Then press Enter to remove the resource group."

# Delete everything
Remove-AzResourceGroup -Name $resourceGroup -Force

Read-Host "Resource group and all resources have been removed."
