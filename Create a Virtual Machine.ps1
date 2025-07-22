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

New-AzResourceGroup -Name 'myResourceGroup2' -Location 'eastus'

New-AzVm `
    -ResourceGroupName 'myResourceGroup2' `
    -Name 'myVM' `
    -Location 'eastus' `
    -Image 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest' `
    -VirtualNetworkName 'myVnet' `
    -SubnetName 'mySubnet' `
    -SecurityGroupName 'myNetworkSecurityGroup' `
    -PublicIpAddressName 'myPublicIpAddress' `
    -OpenPorts 80,3389

    Read-Host VM creation complete. Verify on Azure portal. Then press enter to remove the resource group and all resources created.

    Remove-AzResourceGroup -Name 'myResourceGroup2'

    Read-Host "Resource group and all resources have been removed."