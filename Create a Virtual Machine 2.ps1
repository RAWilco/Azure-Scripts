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
$VMName = Read-Host "Enter a name for the VM (e.g. myVM)"
$Location = Read-Host "Enter the Azure region for the VM (e.g. eastus, westus, etc.)"

# Prompt for VM login credentials
Write-Host "Enter the username and password for the VM"
$cred = Get-Credential

# Create resource group
New-AzResourceGroup -Name $resourceGroup -Location $Location

# Create VNet, Subnet and NetworkSecurityGroup
$vnetName = Read-Host "Enter a name for the VNet (e.g. myVNet)"
$subnetName = Read-Host "Enter a name for the Subnet (e.g. mySubnet)"
$nsgName = Read-Host "Enter a name for the Network Security Group (e.g. myNSG)"

# Define VNet and Subnet addresses
$vnetAddress = "10.1.0.0/16"
$subnetAddress = "10.1.0.0/24"

# Create Network Security Group with rules
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name "Allow_RDP" `
    -Protocol "Tcp" -Direction "Inbound" -Priority 100 -SourceAddressPrefix "*" `
    -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 3389 -Access "Allow"

$nsgRuleHTTP = New-AzNetworkSecurityRuleConfig -Name "Allow_HTTP" `
    -Protocol "Tcp" -Direction "Inbound" -Priority 101 -SourceAddressPrefix "*" `
    -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 80 -Access "Allow"

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup `
    -Location $Location -Name $nsgName -SecurityRules $nsgRuleRDP, $nsgRuleHTTP

# Create VNet and Subnet
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddress
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup `
    -Location $Location -AddressPrefix $vnetAddress -Subnet $subnetConfig

# Link NSG to subnet
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName
$subnet.NetworkSecurityGroup = $nsg
Set-AzVirtualNetwork -VirtualNetwork $vnet

# Verify created VNet and Subnet
Get-AzVirtualNetwork -Name $vnetName 

# Verify created Network Security Group
Get-AzNetworkSecurityGroup -Name $nsgName

# Create Network Interface
#$publicIp = New-AzPublicIpAddress -Name "myPublicIpAddress" -ResourceGroupName $resourceGroup `
#    -Location $Location -AllocationMethod Dynamic

#$nic = New-AzNetworkInterface -Name "myNic" -ResourceGroupName $resourceGroup `
  #  -Location $Location -SubnetId $subnet.Id -PublicIpAddressId $publicIp.Id

# Create VM
New-AzVm `
    -ResourceGroupName $resourceGroup `
    -Name $VMName `
    -Location $Location `
    -Credential $cred `
    -Image 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest' `
    -PublicIpAddressName 'myPublicIpAddress' `
    -OpenPorts 80,3389

Read-Host "VM creation complete. Verify on Azure portal. Then press Enter to remove the resource group and all resources created."

# Delete everything
Remove-AzResourceGroup -Name $resourceGroup -Force

Read-Host "Resource group and all resources have been removed."
