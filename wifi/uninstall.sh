#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
	echo "Run this script as root"
	exit
fi

rm -r ./tmp/

systemctl stop raspberry_wifi_api
systemctl stop nlocker
systemctl disable raspberry_wifi_api
systemctl disable nlocker
systemctl stop dhcpcd
systemctl stop wpa_supplicant
systemctl stop dnsmasq
systemctl stop hostapd

# Remove configs
# rm /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
rm /etc/dnsmasq.conf
rm /etc/hostapd/hostapd.conf
rm /etc/dhcpcd.conf
rm /etc/systemd/system/raspberry_wifi_api.service
rm /etc/systemd/system/nlocker.service


# Restore backup configs
mv /etc/wpa_supplicant/wpa_supplicant.conf.original /etc/wpa_supplicant/wpa_supplicant.conf 2> /dev/null
mv /etc/dnsmasq.conf.original /etc/dnsmasq.conf 2> /dev/null
mv /etc/hostapd/hostapd.conf.original /etc/hostapd/hostapd.conf 2> /dev/null
mv /etc/dhcpcd.conf.original /etc/dhcpcd.conf 2> /dev/null

# Unnstall packages
apt purge -y dnsmasq hostapd

