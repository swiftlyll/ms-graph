<#
.DESCRIPTION
    Gets list of Windows 10 devices from Intune based on the OS build version.
    Windows 11 OS build versions start with 10.0.22000.XXXX onward, anything less will be Windows 10 (assuming no XP or Windows 7 device lol)
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

<# START #>
$devices = Get-MgDeviceManagementManagedDevice -Top 999 -All
$devicesWindows10 = @() # init empty array

# get win10 devices
foreach ($device in $devices) {
    # target os build versions less than 10.0.22000.XXXX since that is what w11 os builds start with
    if ([version]$device.OSVersion -lt [version]"10.0.22000.0000") {
        # add device info to empty array
        $devicesWindows10 += 
            [PSCustomObject]@{
                "Name" = $device.DeviceName 
                "ManagementName" = $device.ManagedDeviceName
                "Model" = $device.Model 
                "SerialNumber" = $device.SerialNumber 
                "LastSync" = "$($device.LastSyncDateTime) UTC"
                "PrimaryUser" = $device.UserDisplayName 
                "Email" = $device.UserPrincipalName 
            }
    }
}

# export to csv
try {
    $filename = "Windows_10_Devices_$(Get-Date -Format 'yyyy-MM-dd').csv"
    
    Write-Output "Exporting to $($PWD.Path)\$filename"
    $devicesWindows10 | Export-Csv -Path ".\$filename"
    Write-Output "Export complete"
}
catch {
    Write-Output "Export to CSV failed"
    Write-Output "Ensure a copy with the same file name is not open"
    Exit 1
}