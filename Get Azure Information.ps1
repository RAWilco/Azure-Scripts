#This script retrieves Azure information and exports it to a text file.

#Install and import only the required Az Modules
Write-Host "Installing and importing required Azure modules..."
Install-Module Az.Accounts -Scope CurrentUser -Force
Install-Module Az.Resources -Scope CurrentUser -Force 
Install-Module Az.Compute -Scope CurrentUser -Force

Import-Module Az.Accounts
Import-Module Az.Resources
Import-Module Az.Compute

#Connect to Azure Account
Connect-AzAccount

#Will then need to select the account in the browser window that opens

# Get current user's desktop path
$desktopPath = [Environment]::GetFolderPath('Desktop')

# Set output file path on Desktop
$outputFile = Join-Path $desktopPath "AzureInfoOutput.txt"

# Clear or create the output file
"" | Out-File -FilePath $outputFile  -Encoding utf8

# Function to append a header and command output
function Append-Section {
    param (
        [string]$Header,
        [scriptblock]$Command
    )

    Add-Content $outputFile "`n===================="
    Add-Content $outputFile "$Header"
    Add-Content $outputFile "===================="

    try {
        & $Command | Out-String | Add-Content $outputFile
    } catch {
        Add-Content $outputFile "Error running command: $_"
    }
}

# 1. Get Context Info
Append-Section -Header "Az Context" -Command { Get-AzContext }

# 2. Get Users + Role Assignments
Add-Content $outputFile "`n===================="
Add-Content $outputFile "User Role Assignments"
Add-Content $outputFile "===================="

$users = Get-AzADUser
$results = @()

foreach ($user in $users) {
    $assignments = Get-AzRoleAssignment -ObjectId $user.Id

    if ($assignments) {
        foreach ($assignment in $assignments) {
            $results += [PSCustomObject]@{
                Name     = $user.DisplayName
                Username = $user.UserPrincipalName
                Role     = $assignment.RoleDefinitionName
                Scope    = $assignment.Scope
            }
        }
    } else {
        $results += [PSCustomObject]@{
            Name     = $user.DisplayName
            Username = $user.UserPrincipalName
            Role     = "None"
            Scope    = "N/A"
        }
    }
}

$results | Format-Table -AutoSize | Out-String | Add-Content $outputFile  -Encoding utf8

# 3. Other Sections
Append-Section -Header "Resource Groups" -Command { Get-AzResourceGroup }
Append-Section -Header "Resources" -Command { Get-AzResource }
Append-Section -Header "Virtual Machines" -Command { Get-AzVM }

# Done
Write-Host "Azure info exported to: $outputFile"

Read-Host -Prompt "Press Enter to exit"
