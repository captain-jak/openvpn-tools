#!/bin/bash

# titi

function parefeu {
		echo "Installation $STR"
		dnf install firewalld -y
		systemctl start firewalld
		systemctl status firewalld
		firewall-cmd --permanent --list-all
		firewall-cmd --permanent --add-service=http
		firewall-cmd --permanent --add-service=https
		firewall-cmd --permanent --add-service=openvpn
		# webmin
		firewall-cmd --permanent --zone=public --add-port=10000/tcp
		#openvpn
		firewall-cmd --permanent --zone=public --add-port=1194/udp
		firewall-cmd --reload
		# réglages du pare-feu
		echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.conf
		sysctl -p
		#firewall-cmd --permanent --zone=trusted --add-service=openvpn
		firewall-cmd --permanent --zone=trusted --add-interface=tun0
		firewall-cmd --permanent --add-masquerade
		SERVERIP=$(ip route get 1.1.1.1 | awk 'NR==1 {print $(NF-2)}')
		firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s  10.5.0.0/24 -o $SERVERIP -j MASQUERADE
		# firewalld AllowZoneDrifting set to no
		sed -i 's/AllowZoneDrifting=yes/AllowZoneDrifting=no/' /etc/firewalld/firewalld.conf
		firewall-cmd --reload
		systemctl restart firewalld
		firewall-cmd --permanent --list-all
		whiptail --title "Pare-feu" --msgbox "Le pare-feu a été installé:\n" 10 40
}
