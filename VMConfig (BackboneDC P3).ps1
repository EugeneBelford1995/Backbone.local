$ADRoot = (Get-ADDomain).DistinguishedName
$FQDN = (Get-ADDomain).DNSRoot

#Store a password for users
[string]$DSRMPassword = 'SuperSafeBackbonePassword1234!@#$'
# Convert to SecureString
[securestring]$UserPassword = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force
$User = "Break.Glass"
New-ADUser -SamAccountName $User -Name $User -UserPrincipalName "$User@$FQDN" -AccountPassword $UserPassword -Enabled $true -Description "Backup Ent Admin" -PasswordNeverExpires $true

Add-ADGroupMember -Identity "Enterprise Admins" -Members "$User"
Add-ADGroupMember -Identity "Domain Admins" -Members "$User"
Add-ADGroupMember -Identity "Schema Admins" -Members "$User"
Add-ADGroupMember -Identity "Administrators" -Members "$User"

New-ADOrganizationalUnit -Name "Member Servers" -Path "$ADRoot"
New-ADComputer -Name "ServerI" -SAMAccountName "ServerI" -DisplayName "ServerI" -Path "ou=member servers,$ADRoot"

Add-WindowsFeature -Name "RSAT-Hyper-V-Tools" -IncludeAllSubFeature

#Store a password for users
[string]$DSRMPassword = 'HerHighness12!@'
# Convert to SecureString
[securestring]$UserPassword2 = ConvertTo-SecureString $DSRMPassword -AsPlainText -Force

$User2 = "Mishky"

New-ADUser -SamAccountName $User2 -Name $User2 -UserPrincipalName "$User2@$FQDN" -AccountPassword $UserPassword2 -Enabled $true -Description "The One, The Only, The Tiny Human" -PasswordNeverExpires $true
Add-ADGroupMember -Identity "Enterprise Admins" -Members "$User2"
Add-ADGroupMember -Identity "Domain Admins" -Members "$User2"
Add-ADGroupMember -Identity "Schema Admins" -Members "$User2"
Add-ADGroupMember -Identity "Administrators" -Members "$User2"