#!/usr/bin/bash

mv /etc/dhcpcd.conf /etc/dhcpcd.conf.ap
mv /etc/dhcpcd.conf.original /etc/dhcpcd.conf
systemctl enable nlocker
reboot

