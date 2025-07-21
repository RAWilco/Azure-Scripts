#Install and import only required modules
Write-Host "Installing required Azure modules..."
Install-Module Az.Accounts -Scope CurrentUser -Force
Install-Module Az.Resources -Scope CurrentUser -Force

Import-Module Az.Accounts
Import-Module Az.Resources

Connect-AzAccount

#Will then need to select the account in the browser window that opens

# Establish variables
$userprincipalname = "johndoe@wilcoxsonrichardgmail.onmicrosoft.com"
$roleName = "Reader"
$scope = "/subscriptions/ed7d7c7c-bacd-4d4a-a222-877bbd30fc24"

# Get the user and set in a variable
Write-Host "Retrieving user: $userprincipalname"
$user = Get-AzADUser -UserPrincipalName $userprincipalname

# Confirm user was found
if ($user -eq $null) {
    Write-Host "User not found: $userprincipalname" -ForegroundColor Red
    exit
}

# Assign the role
New-AzRoleAssignment -ObjectId $user.Id -RoleDefinitionName $roleName -Scope $scope

Write-Host "Role '$roleName' assigned to $userprincipalname at scope $scope." -ForegroundColor Green

  Write-Host "New user created successfully."
  
  Read-Host -Prompt "Press Enter to exit"
