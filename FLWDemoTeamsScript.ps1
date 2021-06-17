#Set domain name, e.g. contoso.onmicrosoft.com"
$initialDomain = “<your_domain_name>”

#Login as Global Administrator
Connect-AzureAD
Connect-MicrosoftTeams

#Get our FLW group
$Flw1 = Get-AzureADGroup -SearchString "Frontline Workers 1"

#Get our group members
$Flw1Members = Get-AzureADGroupMember -All:$true -ObjectId $Flw1.ObjectId

#Create a FLW Team
$FlwTeam1 = New-Team -DisplayName "Frontline Force" -Description "Team for all things FLW" -Visibility Public

#Loop through our group members and add them to the team
$Flw1Members | ForEach-Object {

    if ($_.DisplayName -eq "SeattleUser1") {

        Add-TeamUser -GroupId $FlwTeam1.GroupId -User $_.UserPrincipalName -Role Owner
    }
    else {

        Add-TeamUser -GroupId $FlwTeam1.GroupId -User $_.UserPrincipalName -Role Member
    }
}

#Add some channels to the Team
New-TeamChannel -GroupId $FlwTeam1.GroupId -DisplayName "Corporate Communications" -Description "Company-wide Communications" -MembershipType Standard
New-TeamChannel -GroupId $FlwTeam1.GroupId -DisplayName "Front of Store" -Description "Front of Store Management" -MembershipType Standard
New-TeamChannel -GroupId $FlwTeam1.GroupId -DisplayName "Back of Store" -Description "Back of Store Management" -MembershipType Standard

#Assign the Frontline worker policy package
Grant-CsGroupPolicyPackageAssignment -GroupId $FlwTeam1.GroupId -PackageName "Frontline_Worker"

