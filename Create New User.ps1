Connect-AzAccount

#Will then need to select the account in the browser window that opens

$SecurePassword = ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force

New-AzADUser `
  -DisplayName "John Doe" `
  -UserPrincipalName "johndoe@wilcoxsonrichardgmail.onmicrosoft.com" `
  -MailNickname "johndoe" `
  -AccountEnabled $true `
  -Password $SecurePassword