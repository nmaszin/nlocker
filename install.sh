#!/usr/bin/env bash

INTERFACE="wlan0"
SSID="NLocker"
PASSWORD="haslo123"
NETWORK="10.0.0.0"
NETWORK_MASK=24

RASPBERRY_IP="10.0.0.1"
FIRST_IP="10.0.0.2"
LAST_IP="10.0.0.5"

DOMAIN="raspberry.local"
SERVER_PORT=80
INSTALLATION_PATH="`pwd`"

if [[ $EUID -ne 0 ]]; then
	echo "Run this script as root"
	exit
fi

# Install packages
apt install -y dnsmasq hostapd python3 python3-pip
python3 -m pip install flask pyopenssl

systemctl unmask hostapd
systemctl enable hostapd
systemctl enable dnsmasq

systemctl stop dnsmasq
systemctl stop hostapd
systemctl stop wpa_supplicant
systemctl stop dhcpcd

# Backup configs
mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.original 2> /dev/null
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.original 2> /dev/null
mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.original 2> /dev/null
mv /etc/dhcpcd.conf /etc/dhcpcd.conf.original 2> /dev/null

# Setup configs
mkdir -p ./tmp
cat configs/hostapd.conf | sed "s/#SSID#/$SSID/" | sed "s/#PASSWORD#/$PASSWORD/" | sed "s/#INTERFACE#/$INTERFACE/" > ./tmp/hostapd.conf
cat configs/dhcpcd.conf | sed "s/#INTERFACE#/$INTERFACE/" | sed "s/#IP#/$RASPBERRY_IP\/$NETWORK_MASK/" > ./tmp/dhcpcd.conf
cat configs/dnsmasq.conf | sed "s/#INTERFACE#/$INTERFACE/" | sed "s/#FIRST_IP#/$FIRST_IP/" | sed "s/#LAST_IP#/$LAST_IP/" | sed "s/#RASPBERRY_IP#/$RASPBERRY_IP/" | sed "s/#DOMAIN#/$DOMAIN/"  > ./tmp/dnsmasq.conf
cat configs/raspberry_wifi_api.service | sed "s@#PATH#@$INSTALLATION_PATH@" > ./tmp/raspberry_wifi_api.service
cat configs/nlocker.service | sed "s@#PATH#@$INSTALLATION_PATH@" > ./tmp/nlocker.service

# Move configs
mv ./tmp/hostapd.conf /etc/hostapd/hostapd.conf
mv ./tmp/dhcpcd.conf /etc/dhcpcd.conf
mv ./tmp/dnsmasq.conf /etc/dnsmasq.conf
mv ./tmp/raspberry_wifi_api.service /etc/systemd/system/raspberry_wifi_api.service
mv ./tmp/nlocker.service /etc/systemd/system/nlocker.service

systemctl enable raspberry_wifi_api
systemctl enable nlocker
systemctl start raspberry_wifi_api
systemctl start dhcpcd
systemctl start wpa_supplicant
systemctl start dnsmasq
systemctl start hostapd

