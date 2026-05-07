Stop-VM -Name "Backbone-DC"
Set-VMProcessor -VMName "Backbone-DC" -ExposeVirtualizationExtensions $true
Start-VM -Name "Backbone-DC"

#backbone.local Ent Admin:
[string]$userName = "backbone\Break.Glass"
[string]$userPassword = 'SuperSecureDomainPassword1234!@#$'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$BackboneDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "Backbone-DC" {bcdedit /set hypervisorlaunchtype auto} -Credential $BackboneDomainAdminCredObject
Invoke-Command -VMName "Backbone-DC" {Restart-Computer -Force} -Credential $BackboneDomainAdminCredObject