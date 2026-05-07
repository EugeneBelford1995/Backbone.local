#https://learn.microsoft.com/en-us/windows-server/networking/technologies/dhcp/dhcp-deploy-wps
#https://stackoverflow.com/questions/26289293/powershell-add-multiple-dns-servers-to-new-dhcp-scope
Install-WindowsFeature -Name DHCP -IncludeManagementTools
Add-DhcpServerInDC -DnsName "Backbone-DC" -IPAddress "10.0.10.120"
Add-DhcpServerv4Scope -Name "MyScope" -StartRange 10.0.10.150 -EndRange 10.0.10.253 -SubnetMask 255.255.255.0
$DNS1 = "10.0.10.140"
$DNS2 = "10.0.10.141"
$DNS3 = "10.0.10.145"
$DNS4 = "1.1.1.1"
$DNS5 = "8.8.8.8"
$dnsArray = $DNS1,$DNS2,$DNS3,$DNS4,$DNS5
Set-DhcpServerv4OptionValue -ComputerName "Backbone-DC" -ScopeId "10.0.10.0" -DnsServer $dnsArray -Force
Set-DhcpServerv4OptionValue -OptionID 3 -Value "10.0.10.120" -ScopeID "10.0.10.0" -ComputerName "Backbone-DC"
Set-DhcpServerv4Binding -IPAddress 10.0.10.120
Start-Service DhcpServer

Add-DhcpServerv4Reservation -Name "Instructor laptop" -ScopeId "10.0.10.0" -IPAddress "10.0.10.152" -ClientId "18-DB-F2-29-E8-15" -Description "Reservation for Testing vSW on instructor's laptop that runs Backbone-DC"
Add-DhcpServerv4Reservation -Name "Student laptop" -ScopeId "10.0.10.0" -IPAddress "10.0.10.150" -ClientId "D4-81-D7-CE-05-91" -Description "Reservation for Testing vSW on student laptop"