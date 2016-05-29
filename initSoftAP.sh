#!/bin/bash

# https://nims11.wordpress.com/2012/04/27/hostapd-the-linux-way-to-create-virtual-wifi-access-point/

if [ "$1" == "-f" ]; then 
  rm -rf /tmp/hostapd.lock
fi

if [ -f /tmp/hostapd.lock ]; then 
  echo "/tmp/hostapd.lock exists, remove it before running this" 
  exit 1
fi

nmcli radio wifi off
sleep 2
rfkill unblock wlan
sleep 2
#Initial wifi interface configuration
ifconfig wlp1s0 up 10.0.0.1 netmask 255.255.255.0
sleep 2
###########Start DHCP, comment out / add relevant section##########
#Thanks to Panji
#Doesn't try to run dhcpd when already running
if [ "$(ps -e | grep dhcpd)" == "" ]; then
dhcpd wlp1s0 &
fi
###########
#Enable NAT
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface enp0s20u1u1 -j MASQUERADE
iptables --append FORWARD --in-interface wlp1s0 -j ACCEPT
 
#Thanks to lorenzo
#Uncomment the line below if facing problems while sharing PPPoE, see lorenzo's comment for more details
#iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

sleep 1
 
sysctl -w net.ipv4.ip_forward=1
#start hostapd
hostapd hostapd.conf 1>/dev/null 2>&1 &
#killall dhcpd

touch /tmp/hostapd.lock
