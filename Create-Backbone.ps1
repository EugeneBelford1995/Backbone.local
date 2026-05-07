Function Create-VM
{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $VMName,
         [Parameter(Mandatory=$false, Position=1)]
         [string] $IP
    )

#Creates the VM from a provided ISO & answer file, names it provided VMName
Set-Location "C:\VM_Stuff_Share\Backbone"
$isoFilePath = "..\ISOs\Windows Server 2022 (20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us).iso"
$answerFilePath = ".\2022_autounattend.xml"

New-Item -ItemType Directory -Path C:\Hyper-V_VMs\$VMName

$convertParams = @{
    SourcePath        = $isoFilePath
    SizeBytes         = 100GB
    Edition           = 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)'
    VHDFormat         = 'VHDX'
    VHDPath           = "C:\Hyper-V_VMs\$VMName\$VMName.vhdx"
    DiskLayout        = 'UEFI'
    UnattendPath      = $answerFilePath
}

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
. '.\Convert-WindowsImage.ps1'

Convert-WindowsImage @convertParams

New-VM -Name $VMName -Path "C:\Hyper-V_VMs\$VMName" -MemoryStartupBytes 6GB -Generation 2
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes 6GB -StartupBytes 6GB -MaximumBytes 8GB
Connect-VMNetworkAdapter -VMName $VMName -Name "Network Adapter" -SwitchName "Testing"
$vm = Get-Vm -Name $VMName
$vm | Add-VMHardDiskDrive -Path "C:\Hyper-V_VMs\$VMName\$VMName.vhdx"
$bootOrder = ($vm | Get-VMFirmware).Bootorder
#$bootOrder = ($vm | Get-VMBios).StartupOrder
if ($bootOrder[0].BootType -ne 'Drive') {
    $vm | Set-VMFirmware -FirstBootDevice $vm.HardDrives[0]
    #Set-VMBios $vm -StartupOrder @("IDE", "CD", "Floppy", "LegacyNetworkAdapter")
}
Start-VM -Name $VMName
}#Close the Create-VM function

#Create-SW
#Write-Host "Creating VMSwitch, please standby ..."
#Start-Sleep -Seconds 30

Create-VM -VMName "Backbone-DC"      #Create the backbone domain's DC
Write-Host "Please wait, the VMs are booting up."
Start-Sleep -Seconds 180

#Create the parent domain
Function Create-BackboneDomain
{
#VM's initial local admin:
[string]$userName = "Changme\Administrator"
[string]$userPassword = 'SuperSecureLocalPassword123!@#'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$InitialCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#VM's local admin after re-naming the computer:
[string]$userName = "Backbone-DC\Administrator"
[string]$userPassword = 'SuperSecureLocalPassword123!@#'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$LabDCLocalCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#VM's Domain Admin:
[string]$userName = "backbone\Administrator"
[string]$userPassword = 'SuperSecureLocalPassword123!@#'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$ParentDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "Backbone-DC" -FilePath '.\VMConfig (BackboneDC P1).ps1' -Credential $InitialCredObject   #Configs IPv4, disables IPv6, renames the VM
Start-Sleep -Seconds 120
Invoke-Command -VMName "Backbone-DC" -FilePath '.\VMConfig (BackboneDC P2).ps1' -Credential $LabDCLocalCredObject   #Makes the VM a DC in a new forest; lab.local
Start-Sleep -Seconds 300 
Invoke-Command -VMName "Backbone-DC" -FilePath '.\VMConfig (BackboneDC P3).ps1' -Credential $ParentDomainAdminCredObject   #Creates a Backup Enterprise Administrator account name Break.Glass

#Last step; set the Administrator password

#backbone.local Ent Admin:
[string]$userName = "backbone\Break.Glass"
[string]$userPassword = 'SuperSafeBackbonePassword1234!@#$'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$BackboneDomainAdminCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Invoke-Command -VMName "Backbone-DC" {Set-ADAccountPassword -Identity "Administrator" -Reset -NewPassword (ConvertTo-SecureString -AsPlainText 'SuperSafeBackbonePassword1234!@#$' -Force)} -Credential $BackboneDomainAdminCredObject

#Enable & setup RRAS IOT route ServerI & VM traffic to the Inernet
Add-VMNetworkAdapter -VMName "Backbone-DC" -SwitchName "Default Switch"
Invoke-Command -VMName "Backbone-DC" -FilePath '.\VMConfig (BackboneDC P4).ps1' -Credential $BackboneDomainAdminCredObject

Invoke-Command -VMName "Backbone-DC" -FilePath '.\Config-DHCPServer.ps1' -Credential $BackboneDomainAdminCredObject   #Enable DHCP for ServerI & VMs

} #Close the Create-ParentDomain function

Create-BackboneDomain