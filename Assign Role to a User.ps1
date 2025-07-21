# Ensure required modules are installed
Write-Host "Installing and importing required Azure modules..."
Install-Module Az.Accounts -Scope CurrentUser -Force
Install-Module Az.Resources -Scope CurrentUser -Force

Import-Module Az.Accounts
Import-Module Az.Resources

# Login to Azure
Connect-AzAccount

# Get all users and their assigned roles
Write-Host "Fetching all users and their role assignments..."

$subscriptionId = (Get-AzContext).Subscription.Id
$users = Get-AzADUser
$results = @()

foreach ($user in $users) {
    $assignments = Get-AzRoleAssignment -ObjectId $user.Id -Scope "/subscriptions/$subscriptionId"

    if ($assignments) {
        foreach ($assignment in $assignments) {
            $results += [PSCustomObject]@{
                Name     = $user.DisplayName
                Username = $user.UserPrincipalName
                Role     = $assignment.RoleDefinitionName
                Scope    = $assignment.Scope
                ObjectId = $user.Id
            }
        }
    } else {
        $results += [PSCustomObject]@{
            Name     = $user.DisplayName
            Username = $user.UserPrincipalName
            Role     = "None"
            Scope    = "N/A"
            ObjectId = $user.Id
        }
    }
}

# Display the table of users and roles
$results | Sort-Object Name | Format-Table Name, Username, Role, Scope -AutoSize

# Prompt user to select a user
$selectedUser = Read-Host "Enter the full Display Name of the user whose role you want to change"

$userObject = $results | Where-Object { $_.Name -eq $selectedUser }

if (-not $userObject) {
    Write-Host "User not found. Please check the Display Name and try again." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Prompt for new role name
$newRole = Read-Host "Enter the name of the role to assign (e.g. Contributor, Reader, Owner), or type 'None' to remove all roles"

if ($newRole -eq "None") {
    $userAssignments = Get-AzRoleAssignment -ObjectId $userObject.ObjectId -Scope "/subscriptions/$subscriptionId"
    
    if ($userAssignments) {
        foreach ($assignment in $userAssignments) {
            Remove-AzRoleAssignment -ObjectId $userObject.ObjectId -RoleDefinitionName $assignment.RoleDefinitionName -Scope $assignment.Scope -Confirm:$false
        }
        Write-Host "All roles removed from $selectedUser successfully." -ForegroundColor Yellow
    } else {
        Write-Host "$selectedUser has no assigned roles." -ForegroundColor Yellow
    }

    Read-Host "Press Enter to exit"
    exit
}

# Otherwise, assign a new role
$roleDef = Get-AzRoleDefinition | Where-Object { $_.Name -eq $newRole }

if (-not $roleDef) {
    Write-Host "Role not found. Please check the role name and try again." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

New-AzRoleAssignment -ObjectId $userObject.ObjectId -RoleDefinitionName $newRole -Scope "/subscriptions/$subscriptionId"

Write-Host "Role '$newRole' assigned to $selectedUser successfully." -ForegroundColor Green
Read-Host "Press Enter to exit"
