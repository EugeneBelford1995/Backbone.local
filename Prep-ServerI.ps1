#From Backbone-DC:
#Enter-PSSession ServerI
#Create a share drive on ServerI to host VM configs, ISOs, answer files, etc
New-Item -ItemType Directory "C:\VM_Stuff_Share"
New-Item -ItemType Directory "C:\VM_Stuff_Share\ISOs"
New-Item -ItemType Directory "C:\VM_Stuff_Share\Lab"
New-SmbShare -Path "C:\VM_Stuff_Share" -Name "VM_Stuff" -FullAccess "backbone\Domain Admins"
Grant-SmbShareAccess -Name "VM_Stuff" -AccountName "backbone\Domain Admins" -AccessRight Full

#Create a folder to put our VMs in
New-Item -ItemType Directory C:\Hyper-V_VMs

#Copy/paste the Windows Server 2022 ISO to ISOs and drop the PS1s into Lab.