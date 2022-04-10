#!/usr/bin/bash

systemctl disable nlocker

rm /etc/wpa_supplicant/wpa_supplicant.conf

mv /etc/dhcpcd.conf /etc/dhcpcd.conf.original
mv /etc/dhcpcd.conf.ap /etc/dhcpcd.conf
reboot

