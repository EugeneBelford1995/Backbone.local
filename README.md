# Backbone.local
Setup &amp; Config the infrastructure that hosts the cyber range 

Sets up & configs a VM as a GW, DNS, DHCP, and DC for the the domain backbone.local. This VM is meant to be run on a laptop with 2 NICs that has Hyper-V enabled. This essentially makes the laptop's VM a RTR for the training environment.

The DC is used to run the domain backbone.local that in turn contains the server running Hyper-V. Putting it on a domain makes remote management seamless and easy. One only has to plug a USB DVD drive or thumb drive into the server, install the OS, and then use sconfig.exe to set the IP, GW, DNS, and then join the domain. Once this is done the server can be remotely managed going foward.

