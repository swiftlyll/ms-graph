<#
.DESCRIPTION
.NOTES
    Date: 2025-01-20
    GitHub: https://github.com/swiftlyll
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

<# FUNCTIONS #>

<# SCRIPT #>
$userEmail = Read-Host -Prompt "Enter user email address"
$userId = (Get-MgUser -Filter "UserPrincipalName eq '$userEmail'").Id
$userLicences = Get-MgUserLicenseDetail -UserId $userId | fl

$userLicences