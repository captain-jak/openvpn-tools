#!/bin/bash

function certif {
	# boîte de cases à cocher proprement dite
	dialog --backtitle "Certificats" --title "Gestion des certificats" \
	--ok-label "Valider" --cancel-label "Quitter" \
	--checklist "
	Cochez les boîtes." 20 60 8 \
	"server-key" "Créer les cles du serveur" off \
	"client-key" "Créer les clés du client" off \
	"save-key" "Sauver les clés" off \
	"restore-key" "Restaurer les clés" off 2> $FICHTMP
	# traitement de la réponse
	# 0 est le code retour du bouton Valider
	# ici seul le bouton Valider permet de continuer
	# tout autre action (Quitter, Esc, Ctrl-C) arrête le script.

	if [ $? = 0 ]
	then
		for i in `cat $FICHTMP`
		do
			case $i in
				"client-key") clientkey ;;
				"server-key") serverkey ;;
				"save-key") savekey ;;
				"restore-key") restorekey ;;
			esac
		done
	else exit 0
	fi 
}

function serverkey {
	# suppression certificats et configurations anterieurs
		if (whiptail --title "Confirmation" --yesno "Etes vous certains de créer une nouvelle clé serveur.\nLes clés des clients déjà créées ne fonctionneront plus avec cette nouvelle clé serveur" 10 55); then
			echo "Création d'une nouvelle clé serveur."
	echo "Build OpenVPN Server Keys:"
	echo "
set_var EASYRSA \"\${0%/*}\"
set_var EASYRSA_PKI             \"\$PWD/pki\"
#set_var EASYRSA_TEMP_DIR        \"\$EASYRSA_PKI\"
set_var EASYRSA_DN      \"cn_only\"
set_var EASYRSA_DN      \"cn_only\"
set_var EASYRSA_KEY_SIZE       2048
set_var EASYRSA_ALGO            rsa
set_var EASYRSA_CA_EXPIRE       3650
set_var EASYRSA_CERT_EXPIRE     825
#set_var EASYRSA_CRL_DAYS       180
#set_var EASYRSA_CERT_RENEW     31
set_var EASYRSA_NS_SUPPORT      \"no\"
set_var EASYRSA_NS_COMMENT      \"SELFMICRO-LABS CERTIFICATE AUTHORITY\"
set_var EASYRSA_EXT_DIR \"\$EASYRSA/x509-types\"
set_var EASYRSA_SSL_CONF        \"\$EASYRSA/openssl-easyrsa.cnf\"
set_var EASYRSA_DIGEST          \"sha256\"
	" > /etc/openvpn/easy-rsa/vars
	chmod +x /etc/openvpn/easy-rsa/vars
	cd /etc/openvpn/easy-rsa
	rm -rf ../server/*.crt
	rm -rf ../server/*.key
	rm -rf ../client/ca.crt
	./easyrsa init-pki
	./easyrsa build-ca
	./easyrsa gen-req server nopass
	./easyrsa sign-req server server
	openssl verify -CAfile pki/ca.crt pki/issued/server.crt
	./easyrsa gen-dh
	# copie des certificats dans le bon repertoire
	cp -f pki/dh.pem /etc/openvpn/server/
	cp -f /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/server/
	#  ????
	cp -f /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/client/
	cp -f pki/issued/* /etc/openvpn/server/
	cp -n pki/private/* /etc/openvpn/server/
	# For extra security beyond that provided
	# by SSL/TLS, create an "HMAC firewall"
	# to help block DoS attacks and UDP port flooding.
	# Ne pas oublier pour être effectif, a ajouter dans server.conf
	openvpn --genkey --secret ta.key
	mv ta.key /etc/openvpn/
	whiptail --title "Clés serveur" --msgbox "Les clés serveur ont été créés." 10 40
			fi	
}

function clientkey {
	###################################
	# 			A FAIRE
	# 		verifier que les cles serveurs ont été créés
	###################################
	Name=$(whiptail --title "Utilisateur" --inputbox "Utilisateur ?" 10 40 enjoy 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
	Jours=$(whiptail --title "Expiration" --inputbox "Combien de jours de validité ?" 10 40 3>&1 1>&2 2>&3)
		if [ $exitstatus = 0 ]; then
			echo "Build client Keys: $Name"
			# suppression des anciens clients
			cd /etc/openvpn
			rm -rf client/$Name*
			rm -rf lesclients/$Name*
			cd ..       
			cd /etc/openvpn/easy-rsa
			./easyrsa gen-req $Name nopass
			./easyrsa sign-req client $Name
			openssl verify -CAfile pki/ca.crt pki/issued/$Name.crt
			wait 3
			# copie des certificats dans le bon repertoire
			cd /etc/openvpn/easy-rsa
			cp pki/ca.crt /etc/openvpn/client/
			cp pki/issued/$Name* /etc/openvpn/client/
			cp pki/private/$Name* /etc/openvpn/client
			wait 3
			SERVERIP=$(ip route get 1.1.1.1 | awk 'NR==1 {print $(NF-2)}')
			echo "
set_var EASYRSA \"\${0%/*}\"
set_var EASYRSA_PKI             \"\$PWD/pki\"
#set_var EASYRSA_TEMP_DIR        \"\$EASYRSA_PKI\"
set_var EASYRSA_DN      \"cn_only\"
set_var EASYRSA_DN      \"cn_only\"
set_var EASYRSA_KEY_SIZE       2048
set_var EASYRSA_ALGO            rsa
set_var EASYRSA_CA_EXPIRE       3650
set_var EASYRSA_CERT_EXPIRE     $Jours
#set_var EASYRSA_CRL_DAYS       180
#set_var EASYRSA_CERT_RENEW     31
set_var EASYRSA_NS_SUPPORT      \"no\"
set_var EASYRSA_NS_COMMENT      \"SELFMICRO-LABS CERTIFICATE AUTHORITY\"
set_var EASYRSA_EXT_DIR 	\"\$EASYRSA/x509-types\"
set_var EASYRSA_SSL_CONF        \"\$EASYRSA/openssl-easyrsa.cnf\"
set_var EASYRSA_DIGEST          \"sha256\"
" > /etc/openvpn/easy-rsa/vars
			echo "
client
dev tun
proto udp

remote $SERVERIP 1194

ca ca.crt
cert $Name.crt
key $Name.key

cipher AES-256-CBC
auth SHA512
auth-nocache
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256

resolv-retry infinite
compress lz4
nobind
persist-key
persist-tun
mute-replay-warnings
verb 3
" > /etc/openvpn/client/$Name.ovpn
			cd /etc/openvpn
			tar -czvf $Name.tar.gz client/* 
			mv $Name.tar.gz /etc/openvpn/lesclients/
			whiptail --title "Clés client" --msgbox "Les clés du client $Name ont été créés.\n
Sur la machine cliente, pour récupérer les clés, lancer la commande suivante:\n
\"scp -i ~/.ssh/digital-ocean root@$SERVERIP:/etc/openvpn/lesclients/$Name.tar.gz .\"	" 15 100
			fi
		fi
}

function savekey {
	whiptail --title "Clés serveur" --msgbox "Attention cette opération écrasera la précédente sauvegarde!" 10 40
	echo "Save keys:"
	mkdir /root/save-keys
	mkdir /root/save-keys/server
	mkdir /root/save-keys/clients
	cp -f /etc/openvpn/server/* /root/save-keys/server/
	cp -f  /etc/openvpn/lesclients/* /root/save-keys/clients/
	whiptail --title "Clés serveur" --msgbox "Les clés ont été sauvées dans le répertoire /root/save-keys/" 10 40
}

function restorekey {
	echo "Restore keys:"
	cp -f /root/save-keys/server/*  /etc/openvpn/server/
	cp -f  /etc/openvpn/clients/* /etc/openvpn/lesclients/*
	tar -xzvf   /etc/openvpn/lesclients/*
	whiptail --title "Clés serveur" --msgbox "Les clés ont été restaurés" 10 40
}
