<#
.NOTES
    Author:     Kennet Morales
    Date:       2025-03-28
    GitHub:     https://github.com/swiftlyll    
#>

<# AUTH #>
$tenantId = $env:TENANT_ID
$clientId = $env:CLIENT_ID
$clientSecret = $env:GRAPH_API_KEY
$secureClientSecret= ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
$token = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $clientId, $secureClientSecret

$auth = @{
    TenantId = $tenantId
    ClientSecretCredential = $token
    NoWelcome = $true
    ErrorAction = "Stop"
}

Connect-MgGraph @auth

<# QUERY #>
$FTE = Get-DynamicDistributionGroup "Dynamic Distro Name"
$membersOf = Get-Recipient -RecipientPreviewFilter $FTE.RecipientFilter -OrganizationalUnit $FTE.RecipientContainer

$dynamicMembers = @()

foreach ($user in $membersOf){
    $userId = $user.Name 
    $displayName = $null

    try {
        $displayName = (Get-MgUser -UserId $userId -ErrorAction Stop).DisplayName
    }
    catch {
        Write-Output "Unable to retrieve details for user $userId using userId"
        Write-Output "Attempting to use MailNickname field"
    }

    # needed so that if the first query is successful it doesn't get overwritten with null after failiing the second query.
    # this makes it so that the second query only runs if the first one is a failure.
    if($null -eq $displayName){
        try {
            $displayName = (Get-MgUser -Filter "MailNickname eq '$userId'" -ErrorAction Stop).DisplayName
        }
        catch {
            Write-Output "Another error occurred."
        }
    }

    $dynamicMembers += $displayName 
}

$dynamicMembers