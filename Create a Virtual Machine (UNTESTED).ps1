#Install and import only required modules
Write-Host "Installing required Azure modules..."
Install-Module Az.Accounts -Scope CurrentUser -Force
Install-Module Az.Resources -Scope CurrentUser -Force
Install-Module Az.Network -Scope CurrentUser -Force
Install-Module Az.Compute -Scope CurrentUser -Force

Import-Module Az.Accounts
Import-Module Az.Resources
Import-Module Az.Network
Import-Module Az.Compute

Connect-AzAccount

#Will then need to select the account in the browser window that opens

#Establish variables
$resourceGroup = "TestResourceGroup"
$location = "UK South"
$vmName = "TestVM"
$vmSize = "Standard_DS1_v2"
$adminUser = "TestAdmin"
$adminPassword = ConvertTo-SecureString "MyP@ssword123!" -AsPlainText -Force

# Create the Resource Group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create subnet and virtual network
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name "TestSubnet" -AddressPrefix "10.0.0.0/24"
$vnet = New-AzVirtualNetwork -Name "TestVnet" -ResourceGroupName $resourceGroup -Location $location `
    -AddressPrefix "10.0.0.0/16" -Subnet $subnetConfig

# Create public IP
$pip = New-AzPublicIpAddress -Name "TestPublicIP" -ResourceGroupName $resourceGroup -Location $location `
    -AllocationMethod Dynamic

# Create NIC
$nic = New-AzNetworkInterface -Name "TestNIC" -ResourceGroupName $resourceGroup -Location $location `
    -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

# Define VM config
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize | `
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential (New-Object PSCredential ($adminUser, $adminPassword)) -ProvisionVMAgent -EnableAutoUpdate | `
    Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" | `
    Add-AzVMNetworkInterface -Id $nic.Id

# Create the VM
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig

  Write-Host "New VM created successfully."
  
  Read-Host -Prompt "Press Enter to exit"
