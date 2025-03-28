<#
.NOTES
    Author:     Kennet Morales
    Date:       2025-03-28
    GitHub:     https://github.com/swiftlyll    
#>

# Install-Module -Name ExchangeOnlineManagement

# $userPrincipleName = Read-Host "Enter email address"
# Connect-ExchangeOnline -UserPrincipalName $userPrincipleName

# add options, type of filter, based on option chosen, create the distro
New-DynamicDistributionGroup -Name "Distro Name" -RecipientFilter "(Office -eq 'Office') -and (RecipientTypeDetails -eq 'UserMailbox')" -PrimarySmtpAddress "example@contoso.com"