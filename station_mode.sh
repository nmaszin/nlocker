#!/usr/bin/bash

cp /etc/dhcpcd.conf.original /etc/dhcpcd.conf
reboot

# systemctl stop dnsmasq
# systemctl stop hostapd
# wpa_cli -i wlan0 reconfigure
# systemctl restart dhcpcd

