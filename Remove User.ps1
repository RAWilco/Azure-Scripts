#Install and import only required modules
Write-Host "Installing required Azure modules..."
Install-Module Az.Accounts -Scope CurrentUser -Force
Install-Module Az.Resources -Scope CurrentUser -Force
Install-Module Az.Compute -Scope CurrentUser -Force

Import-Module Az.Accounts
Import-Module Az.Resources
Import-Module Az.Compute

Connect-AzAccount

#Will then need to select the account in the browser window that opens

Remove-AzADUser -DisplayName "Jane Doe"

  Write-Host "User removed."
  
  Read-Host -Prompt "Press Enter to exit"
