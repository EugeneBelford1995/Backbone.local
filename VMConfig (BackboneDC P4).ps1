#The int name = "Wi-Fi"
$NIC = "Ethernet 2" # ; Set-DNSClientServerAddress -InterfaceAlias $NIC -ServerAddresses ("192.168.0.103", "192.168.0.104", "192.168.0.102", "192.168.0.101", "1.1.1.1", "8.8.8.8")

#Disable IPv6
Disable-NetAdapterBinding -InterfaceAlias $NIC -ComponentID ms_tcpip6
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes

Install-WindowsFeature -Name Routing -IncludeManagementTools
Install-WindowsFeature -Name DirectAccess-VPN -IncludeManagementTools
Install-WindowsFeature -Name RemoteAccess -IncludeManagementTools
Import-Module RemoteAccess
Install-RemoteAccess -VpnType RoutingOnly
# Add a default route
#$IPtoUse = (Get-NetIPConfiguration -InterfaceAlias "Ethernet 2").IPv4Address.IPAddress
#New-NetRoute -DestinationPrefix 0.0.0.0/0 -NextHop "$IPtoUse" -InterfaceIndex 1

#https://codeandkeep.com/PowerShell-Windows-Routing/