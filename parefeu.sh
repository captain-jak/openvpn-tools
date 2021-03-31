#!/bin/bash

# Menu du pare-feu
function parefeu {
	# boîte de cases à cocher proprement dite
	dialog --backtitle "Pare feu" --title "Pare feu" \
	--ok-label "Valider" --cancel-label "Quitter" \
	--checklist "
	Cochez les boîtes." 25 60 8 \
	"install" "Installation - mise à jour" off \
	"desinstall" "Désinstallation" off 2> $FICHTMP
	# traitement de la réponse
	# 0 est le code retour du bouton Valider
	# ici seul le bouton Valider permet de continuer
	# tout autre action (Quitter, Esc, Ctrl-C) arrête le script.

	if [ $? = 0 ]
	then
		for i in `cat $FICHTMP`
		do
			case $i in
				"install") parefeu-install ;;
				"desinstall") parefeu-desinstall;;
			esac
		done
	else exit 0
	fi 
}

function parefeu-install {
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

function parefeu-desinstall {
	# supprimer les régles
	for srv in $(firewall-cmd --list-services);do firewall-cmd --remove-service=$srv; done
	# règles minimum
	firewall-cmd --add-service={ssh,dhcpv6-client}
	firewall-cmd --runtime-to-permanent
	systemctl stop firewalld
	dnf remove firewalld -y
	whiptail --title "Pare-feu" --msgbox "Le pare-feu a été désinstallé:\n" 10 40
}
