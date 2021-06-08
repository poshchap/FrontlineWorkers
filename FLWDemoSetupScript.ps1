#Set user password
$password = “<your_password>”

#Set domain name, e.g. contoso.onmicrosoft.com"
$initialDomain = “<your_domain_name>”

#Login as Global Administrator
#Connect-AzureAD

#Create users we'll add as AU members later
$passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile -ArgumentList $Password,$false

for($i = 1; $i -le 20; $i++) {
    New-AzureADUser -UserPrincipalName "Seattle$i@$initialDomain" -DisplayName "SeattleUser$i" -PasswordProfile $passwordProfile -UsageLocation "US" -AccountEnabled $true -MailNickName "SeattleUser$i"
    New-AzureADUser -UserPrincipalName "Portland$i@$initialDomain" -DisplayName "PortlandUser$i" -PasswordProfile $passwordProfile -UsageLocation "US" -AccountEnabled $true -MailNickName "PortlandUser$i"
    New-AzureADUser -UserPrincipalName "Denver$i@$initialDomain" -DisplayName "DenverUser$i" -PasswordProfile $passwordProfile -UsageLocation "US" -AccountEnabled $true -MailNickName "DenverUser$i"
    New-AzureADUser -UserPrincipalName "Chicago$i@$initialDomain" -DisplayName "ChicagoUser$i" -PasswordProfile $passwordProfile -UsageLocation "US" -AccountEnabled $true -MailNickName "ChicagoUser$i"
    New-AzureADUser -UserPrincipalName "Orlando$i@$initialDomain" -DisplayName "OrlandoUser$i" -PasswordProfile $passwordProfile -UsageLocation "US" -AccountEnabled $true -MailNickName "OrlandoUser$i"
}

#Create admins we'll assign later to manage the users in the AUs
for($i = 1; $i -le 2; $i++) {
    New-AzureADUser -UserPrincipalName "SeattleManager$i@$initialDomain" -DisplayName "SeattleManager$i" -PasswordProfile $passwordProfile -UsageLocation "US" -AccountEnabled $true -MailNickName "SeattleManager$i"
    New-AzureADUser -UserPrincipalName "PortlandManager$i@$initialDomain" -DisplayName "PortlandManager$i" -PasswordProfile $passwordProfile -UsageLocation "US" -AccountEnabled $true -MailNickName "PortlandManager$i"
    New-AzureADUser -UserPrincipalName "DenverManager$i@$initialDomain" -DisplayName "DenverManager$i" -PasswordProfile $passwordProfile -UsageLocation "US" -AccountEnabled $true -MailNickName "DenverManager$i"
    New-AzureADUser -UserPrincipalName "ChicagoManager$i@$initialDomain" -DisplayName "ChicagoManager$i" -PasswordProfile $passwordProfile -UsageLocation "US" -AccountEnabled $true -MailNickName "ChicacoManager$i"
    New-AzureADUser -UserPrincipalName "OrlandoManager$i@$initialDomain" -DisplayName "OrlandoManager$i" -PasswordProfile $passwordProfile -UsageLocation "US" -AccountEnabled $true -MailNickName "Orlandoanager$i"
}


#Get list of available roles and enable if needed
$admins = Get-AzureADDirectoryRole

switch ($admins) {
        ($_ | ? {$_.DisplayName -eq "Authentication Administrator"}) {
            $authAdmin = $_
        }

        ($_ | ? {$_.DisplayName -eq "Helpdesk Administrator"}) {
            $helpdeskAdmin = $_
        }

        ($_ | ? {$_.DisplayName -eq "User Administrator"}) {
            $userAdmin = $_
        }

        ($_ | ? {$_.DisplayName -eq "Cloud Device Administrator"}) {
            $deviceAdmin = $_
        }

}


# Enable the Helpdesk Administrator Role using the templateId GUID for the role
if (!$helpdeskAdmin) { 

    Enable-AzureADDirectoryRole -RoleTemplateId "729827e3-9c14-49f7-bb1b-9608f156bbb8"

}

# Enable the Authentication Administrator Role using the templateId GUID for the role
if (!$authAdmin) { 

    Enable-AzureADDirectoryRole -RoleTemplateId "c4e39bd9-1100-46d3-8c65-fb160da0071f"

}

# Enable the User Administrator Role using the templateId GUID for the role
if (!$userAdmin) { 

    Enable-AzureADDirectoryRole -RoleTemplateId "fe930be7-5e62-47db-91af-98c3a49a38b1"

}

# Enable the Cloud Device Administrator Role using the templateId GUID for the role
if (!$deviceAdmin) { 
    
    Enable-AzureADDirectoryRole -RoleTemplateId "7698a772-787b-4ac8-901f-60d6b08affd2"

}


#Get all users
$Users = Get-AzureADUser -All:$true

#Create a group for users (Frontline Users 1)
$Group1 = New-AzureADGroup -DisplayName "Frontline Workers 1" -MailEnabled:$false -MailNickName "FrontlineWorkers1" -SecurityEnabled:$true

$Users | Where-Object {$_.displayname -like "*user1"} | ForEach-Object {

    Add-AzureADGroupMember -ObjectID $Group1.ObjectId -RefObjectId $_.ObjectId

}

#Create a group for users (Frontline Users 2)
$Group2 = New-AzureADGroup -DisplayName "Frontline Workers 2" -MailEnabled:$false -MailNickName "FrontlineWorkers2" -SecurityEnabled:$true

$Users | Where-Object {$_.displayname -like "*user2"} | ForEach-Object {

    Add-AzureADGroupMember -ObjectID $Group2.ObjectId -RefObjectId $_.ObjectId

}

#Create a group for admins (Frontline Managers)
$Group2 = New-AzureADGroup -DisplayName "Frontline Managers" -MailEnabled:$false -MailNickName "FrontlineManagers" -SecurityEnabled:$true

$Users | Where-Object {$_.displayname -like "*manager*"} | ForEach-Object {

    Add-AzureADGroupMember -ObjectID $Group2.ObjectId -RefObjectId $_.ObjectId

}

#Create a dynamic device group for enrolled shared devices
New-AzureADMSGroup -DisplayName "Enrolled Shared Devices" -Description "Dynamic group for devices put into shatred device mode via Intune enrollment" `
                   -MailEnabled $False -MailNickName "group" -SecurityEnabled $True -GroupTypes "DynamicMembership" `
                   -MembershipRule "(device.enrollmentProfileName -eq ""SharedDevices"")" -MembershipRuleProcessingState "On"