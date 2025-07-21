# Install and import only required modules
Write-Host "Installing required Azure modules..."
Install-Module Az.Accounts -Scope CurrentUser -Force
Install-Module Az.Resources -Scope CurrentUser -Force
Install-Module Az.Compute -Scope CurrentUser -Force

Import-Module Az.Accounts
Import-Module Az.Resources
Import-Module Az.Compute

# Connect to Azure
Connect-AzAccount

# Prompt for display name and password
$displayName = Read-Host -Prompt "Enter Display Name (e.g. Jane Doe)"
$Password = Read-Host -Prompt "Enter Password for new user. `n(Min 8 characters. Must have at least 3 of lowercase, uppercase, number, symbol)" -AsSecureString

# Generate MailNickname and UserPrincipalName
$mailNickname = $displayName -replace '\s', ''             # Remove spaces for MailNickname
$domain = "wilcoxsonrichardgmail.onmicrosoft.com"
$userPrincipalName = "$mailNickname@$domain"

# Create the new user
New-AzADUser `
  -DisplayName $displayName `
  -UserPrincipalName $userPrincipalName `
  -MailNickname $mailNickname `
  -AccountEnabled $true `
  -Password $Password

Write-Host "New user '$displayName' created successfully."
Read-Host -Prompt "Press Enter to exit"
