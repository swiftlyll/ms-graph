<#
.DESCRIPTION
    Looks at all devices on intune and returns those that have the specified app installed. Note that you will
    need to know what the app name looks like from Intunes side. For example, Zoom shows up in intune as
    Zoom Workspace (64-bit).
.NOTES
    Author: Kennet Morales
    Github: https://github.com/swiftlyll
#>

<# Auth #>
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

<# Create Report #>
$report = @()
$appName = (Read-Host "Please enter app name as it shows in Intune").Trim() # remove trailing/leading whitespace

# get versions of app installed across all devices
try {
    $appInstalledVersions = Get-MgDeviceManagementDetectedApp -Filter "displayName eq '$appName'"
    if ($null -eq $appInstalledVersions) {
        throw
    }
}
catch {
    Write-Output "App does not exist"
    Write-Output "Please verify app name"
    Exit 1
}

foreach($appVersion in $appInstalledVersions) {
    # get devices with each specific app version installed
    Write-Output "Fetching devices with $appName version $($appVersion.Version) installed"
    $devices = Get-MgDeviceManagementDetectedAppManagedDevice -DetectedAppId $appVersion.Id
    # create report with devices that have app installed plus the installed app version
    $report += foreach ($device in $devices) {
        [PSCustomObject]@{
            "DeviceId" = $device.Id
            "DeviceName" = $device.DeviceName
            "AppVersion" = $appVersion.Version
        }
    }
}

# find devices without app installed
Write-Output "Fetching devices without $appName installed"
$devicesAppNotInstalled = Get-MgDeviceManagementManagedDevice -All | Where-Object -FilterScript {$report.DeviceId -notcontains $_.Id}
$report += foreach($device in $devicesAppNotInstalled) {
    [PSCustomObject]@{
        "DeviceId" = $device.Id
        "DeviceName" = $device.DeviceName
        "AppVersion" = "This device does not have $appName installed."
    }
}

<# Export to CSV#>
try {
    $appName = $appName.Replace(" ","") # clean whitespace for file name
    $filename = "${appName}_$(Get-Date -Format 'yyyy-MM-dd').csv"
    
    Write-Output "Exporting to $($PWD.Path)\$filename"
    $report | Export-Csv -Path ".\$filename"
    Write-Output "Export complete"
}
catch {
    Write-Output "Export to CSV failed"
    Write-Output "Ensure a copy with the same file name is not open"
    Exit 1
}