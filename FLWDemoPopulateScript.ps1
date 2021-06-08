#Set domain name, e.g. contoso.onmicrosoft.com"
$initialDomain = “<your_domain_name>”
 
#Login as Global Administrator (comment out if already logged in)
#Connect-AzureAD

## Setup Administrative Units ######################################################
#Create Seattle AU
New-AzureADAdministrativeUnit -Description “Seattle Store” -DisplayName “Seattle”
#Create Portland AU
New-AzureADAdministrativeUnit -Description “Portland Store” -DisplayName “Portland”
#Create Denver AU
New-AzureADAdministrativeUnit -Description “Denver Store” -DisplayName “Denver”
#Create Chicago AU
New-AzureADAdministrativeUnit -Description “Chicago Store” -DisplayName “Chicago”
#Create Orlando AU
New-AzureADAdministrativeUnit -Description “Orlando Store” -DisplayName “Orlando”



#Get all users
$Users = Get-AzureADUser -All:$true

#Add Seattle AU member
$SeattleAU = Get-AzureADAdministrativeUnit -Filter “displayname eq 'Seattle'”

$Users | Where-Object {$_.displayname -like "*SeattleUser*"} | ForEach-Object {

    Add-AzureADAdministrativeUnitMember -ObjectId $SeattleAU.ObjectId -RefObjectId $_.ObjectId
}



#Add Portland AU member
$PortlandAU = Get-AzureADAdministrativeUnit -Filter “displayname eq 'Portland'”

$Users | Where-Object {$_.displayname -like "*PortlandUser*"} | ForEach-Object {

    Add-AzureADAdministrativeUnitMember -ObjectId $PortlandAU.ObjectId -RefObjectId $_.ObjectId
}



#Add Denver AU member
$DenverAU = Get-AzureADAdministrativeUnit -Filter “displayname eq 'Denver'”

$Users| Where-Object {$_.displayname -like "*DenverUser*"} | ForEach-Object {

    Add-AzureADAdministrativeUnitMember -ObjectId $DenverAU.ObjectId -RefObjectId $_.ObjectId
}



#Add Chicago AU member
$ChicagoAU = Get-AzureADAdministrativeUnit -Filter “displayname eq 'Chicago'”

$Users | Where-Object {$_.displayname -like "*ChicagoUser*"} | ForEach-Object {

    Add-AzureADAdministrativeUnitMember -ObjectId $ChicagoAU.ObjectId -RefObjectId $_.ObjectId
}



#Add Orlando AU member
$OrlandoAU = Get-AzureADAdministrativeUnit -Filter “displayname eq 'Orlando'”

$Users | Where-Object {$_.displayname -like "*OrlandoUser*"} | ForEach-Object {

    Add-AzureADAdministrativeUnitMember -ObjectId $OrlandoAU.ObjectId -RefObjectId $_.ObjectId
}



###################################################################################

## Delegate Admin Permissions Scoped to Administrative Units ######################
#Get list of available roles
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


#Add Seattle-scoped Authentication Admin role member
for($i = 1; $i -le 2; $i++) {
    $seattleAuthAdmin = Get-AzureADUser -Filter "UserPrincipalName eq 'SeattleManager$i@$InitialDomain'"
    $authAdminMemberInfo = New-Object -TypeName Microsoft.Open.AzureAD.Model.RoleMemberInfo -Property @{ ObjectId =  $seattleAuthAdmin.ObjectId }
    Add-AzureADScopedRoleMembership -RoleObjectId $authAdmin.ObjectId -ObjectId $SeattleAU.ObjectId -RoleMemberInfo $authAdminMemberInfo
}

#Add Portland-scoped Helpdesk Admin role member
for($i = 1; $i -le 2; $i++) {
    $portlandHelpdeskAdmin = Get-AzureADUser -Filter "UserPrincipalName eq 'PortlandManager$i@$InitialDomain'"
    $helpdeskAdminMemberInfo = New-Object -TypeName Microsoft.Open.AzureAD.Model.RoleMemberInfo -Property @{ ObjectId =  $portlandHelpdeskAdmin.ObjectId }
    Add-AzureADScopedRoleMembership -RoleObjectId $helpdeskAdmin.ObjectId -ObjectId $PortlandAU.ObjectId -RoleMemberInfo $helpdeskAdminMemberInfo
}

#Add Denver-scoped Authentication + Helpdesk Admin role member
for($i = 1; $i -le 2; $i++) {
    $denverAuthAdmin = Get-AzureADUser -Filter "UserPrincipalName eq 'DenverManager$i@$InitialDomain'"
    $authAdminMemberInfo1 = New-Object -TypeName Microsoft.Open.AzureAD.Model.RoleMemberInfo -Property @{ ObjectId =  $denverAuthAdmin.ObjectId }
    Add-AzureADScopedRoleMembership -RoleObjectId $authAdmin.ObjectId -ObjectId $DenverAU.ObjectId -RoleMemberInfo $authAdminMemberInfo1

    $denverHelpdeskAdmin = Get-AzureADUser -Filter "UserPrincipalName eq 'DenverManager$i@$InitialDomain'"
    $helpdeskAdminMemberInfo1 = New-Object -TypeName Microsoft.Open.AzureAD.Model.RoleMemberInfo -Property @{ ObjectId =  $denverHelpdeskAdmin.ObjectId }
    Add-AzureADScopedRoleMembership -RoleObjectId $helpdeskAdmin.ObjectId -ObjectId $DenverAU.ObjectId -RoleMemberInfo $helpdeskAdminMemberInfo1
}

#Add Chicago-scoped User Admin role member
for($i = 1; $i -le 2; $i++) {
    $chicagoUserAdmin = Get-AzureADUser -Filter "UserPrincipalName eq 'ChicagoManager$i@$InitialDomain'"
    $userAdminMemberInfo = New-Object -TypeName Microsoft.Open.AzureAD.Model.RoleMemberInfo -Property @{ ObjectId =  $chicagoUserAdmin.ObjectId }
    Add-AzureADScopedRoleMembership -RoleObjectId $userAdmin.ObjectId -ObjectId $ChicagoAU.ObjectId -RoleMemberInfo $userAdminMemberInfo
}

#Add Orlando User Admin role member, not scoped
for($i = 1; $i -le 2; $i++) {
    $orlandoUserAdmin = Get-AzureADUser -Filter "UserPrincipalName eq 'OrlandoManager$i@$InitialDomain'"
    Add-AzureADDirectoryRoleMember -ObjectId $userAdmin.ObjectId -RefObjectId $orlandoUserAdmin.ObjectId
    Add-AzureADDirectoryRoleMember -ObjectId $deviceAdmin.ObjectId -RefObjectId $orlandoUserAdmin.ObjectId
}

