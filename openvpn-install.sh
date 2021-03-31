#!/bin/bash

function openvpn-git {
		# Installation openvpn avec la dernière version connue ...
		echo "Compilation $LAVER"
		cd /tmp
		wget $ADRESSE$LAVER$EXT
		tar -xvf  $LAVER$EXT
		cd "/tmp/$LAVER"
		./configure
		make
		make install
		mkdir /etc/openvpn
		mkdir /etc/openvpn/client/
		mkdir /etc/openvpn/server/
		cp /root/openvpn-tools/server-2.5.conf /etc/openvpn/server/server.conf
		ln -sf /usr/local/sbin/openvpn /usr/sbin/
		echo "[Unit]
Description=OpenVPN service for %I
After=syslog.target network-online.target
Wants=network-online.target
Documentation=man:openvpn(8)
Documentation=https://community.openvpn.net/openvpn/wiki/Openvpn24ManPage
Documentation=https://community.openvpn.net/openvpn/wiki/HOWTO

[Service]
Type=notify
PrivateTmp=true
WorkingDirectory=/etc/openvpn/server
ExecStart=/usr/local/sbin/openvpn --status %t/openvpn-server/status-%i.log --status-version 2 --suppress-timestamps --cipher AES-256-GCM --data-ciphers AES-256-GCM:AES-128-GCM:AES-256-CBC:AES-128-CBC:BF-CBC --config %i.conf
CapabilityBoundingSet=CAP_IPC_LOCK CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW CAP_SETGID CAP_SETUID CAP_SYS_CHROOT CAP_DAC_OVERRIDE CAP_AUDIT_WRITE
LimitNPROC=10
DeviceAllow=/dev/null rw
DeviceAllow=/dev/net/tun rw
ProtectSystem=true
ProtectHome=true
KillMode=process
RestartSec=5s
Restart=on-failure

[Install]
WantedBy=multi-user.target"  > /usr/lib/systemd/system/openvpn-server@.service
}

function openvpn-dnf {
	# Installation openvpn avec la dernière version déjà compilée
	echo "Installation version compilée d'Openvpn"
	# suppression si autre version installée
	# sup-openvpn
	dnf install -y openvpn
	cp /root/openvpn-tools/server-2.4.conf /etc/openvpn/server/server.conf
	mv /usr/lib/systemd/system/openvpn-server@.service /usr/lib/systemd/system/openvpn-server@server.service
}

function compil {
	#~ echo "Installation $STR"
		#~ OPTION=$(whiptail --title "Openvpn" --menu "Choisissez la version a installé" 10 40 2 \
	#~ "1" "Compilation $LAVER" \
	#~ "2" "Installation openvpn 2.4"  3>&1 1>&2 2>&3)
	dialog --backtitle "Installation Openvpn" --title "Installation $LAVER" \
	--ok-label "Installer" --cancel-label "Passer" \
	--radiolist "
	Cochez les boîtes." 10 40 2 \
	"1" "Compilation $LAVER" ON \
	"2" "Installation openvpn 2.4" OFF 2> $FICHTMP
	# traitement de la réponse
	# 0 est le code retour du bouton Valider
	# ici seul le bouton Valider permet de continuer
	# tout autre action (Quitter, Esc, Ctrl-C) arrête le script.

	if [ $? = 0 ]
	then
		dnf -y install lz4-devel lzo-devel
		for i in `cat $FICHTMP`
		do
			case $i in
				"1") openvpn-git ;;
				"2") openvpn-dnf ;;
			esac
		done
		update-crypto-policies --set LEGACY
		# démarrer le service à chaque reboot de la machine
		systemctl enable openvpn-server@server
		# apres avoir modifié le fichier @service, il faut recharger le daemon
		systemctl daemon-reload
		cd /tmp
		# installation easy-rsa
		git clone https://github.com/OpenVPN/$EASYRSA
		mkdir  /etc/openvpn/easy-rsa/
		cp  -R /tmp/easy-rsa/easyrsa3/* /etc/openvpn/easy-rsa/
		mkdir /etc/openvpn/lesclients/
		cp /tmp/easy-rsa/ChangeLog /etc/openvpn/easy-rsa/
		if ! command systemctl start openvpn-server@server &> /dev/null
		then
			# Les clés du serveur doivent d'abord être créés:
			whiptail --title "Installation" --msgbox "Avant de démarrer openvpn, installer d'abord les clés du serveur." 10 40
			if (whiptail --title "Confirmation" --yesno "Installer les clés du serveur?" 8 78); then
				echo "Installation des clés."
				certif
			fi
		fi
		# installation easy-tls
		#~ git clone https://github.com/TinCanTech/easy-tls.git
		#~ cp /tmp/easy-tls/easytls /etc/openvpn/easy-rsa/
		#~ cp /tmp/easy-tls/easytls-cryptv2-verify.sh /etc/openvpn/easy-rsa/
		#~ cp /tmp/easy-tls/easytls-cryptv2-client-connect.sh /etc/openvpn/easy-rsa/
		#~ chmod +x /tmp/easy-tls/easytls-cryptv2*
		#~ cd  /etc/openvpn/easy-rsa/
		#~ ./easytls-cryptv2-verify.sh
		#~ ./easytls-cryptv2-client-connect.sh
		updatedb
		laversion
	fi
	if ! command -v openvpn --version &> /dev/null
	then
		# openvpn doit d'abord être installé:
		whiptail --title "Installation" --msgbox "Installer d'abord openvpn." 10 40
	else
		if (whiptail --title "Confirmation" --yesno "Installer l'interface d'administration d'openvpn?" 8 78); then
			echo "Installation chocobozz."
			chocobozzz
			rm -rf /etc/openvpn/server/*
			mv /etc/openvpn/ca.crt /etc/openvpn/server/
			mv /etc/openvpn/ta.key /etc/openvpn/server/
			mv /etc/openvpn/dh.pem /etc/openvpn/server/
			mv /etc/openvpn/server.* /etc/openvpn/server/
			cp /root/openvpn-tools/server-chocobozzz.conf /etc/openvpn/server/server.conf
		fi	
	fi
}

function laversion {
	#  echo "Version serveur Openvpn."
	VERSION=$(openvpn --version | grep -w -m 1 'OpenVPN.*.SSL')
	VERSION=${VERSION:0:14}
	echo "La version est:$VERSION"
	VERSION2=$(cat /etc/openvpn/easy-rsa/ChangeLog | grep -w -m 3 '(TBD)')
	VERSION2=${VERSION2:0:5}
	echo "La version est:$VERSION et Easy-RSA $VERSION2"
	if [ "$VERSION"  != '' ]; then	
			systemctl restart openvpn-server@server
		whiptail --title "Openvpn" --msgbox "Versions:\n$VERSION\nEasy-RSA $VERSION2" 10 35
	else
		whiptail --title "Openvpn" --msgbox "Openvpn n'est pas installé." 10 40
	fi
}

function chocobozzz {
	systemctl stop httpd.service
	dnf -y install nodejs unzip git wget sed npm
	npm install -g bower
	cd /tmp
	git clone https://github.com/Chocobozzz/OpenVPN-Admin.git
	cd OpenVPN-Admin
	chmod +x desinstall.sh
	chmod +x install.sh
	chmod +x update.sh
	./install.sh /var/www/ apache apache
	
	#~ Setup the web server (Apache, NGinx...) to serve the web application.
	#~ Create the admin of the web application by visiting http://your-installation/index.php?installation
	
	# Mise à jour
	#~ $ git pull origin master
	#~ # ./update.sh /var/www

	# Desinstallion
	#~ It will remove all installed components (OpenVPN keys and configurations, the web application, iptables rules...).
	#~ # ./desinstall.sh /var/www
	
	# Ownership
	chown apache:apache -R /var/www/openvpn-admin
	cd /var/www/openvpn-admin
	# File permissions, recursive
	find . -type f -exec chmod 0644 {} \;
	# Dir permissions, recursive
	find . -type d -exec chmod 0755 {} \;
	#SELinux serve files off Apache, resursive
	chcon -t httpd_sys_content_t /var/www/openvpn-admin -R
	# Allow write only to specific dirs
	chcon -t httpd_sys_rw_content_t /var/www/openvpn-admin/client-conf -R
	systemctl restart httpd.service
	linstall='Chocobozzz'
	# http://openvpn.selfmicro.com/index.php?installation
	whiptail --title "Admin openvpn" --msgbox "Pour finir l'installation de linterface d'administration:\n http://openvpn.selfmicro.com/index.php?installation" 10 50

}

function sup-openvpn{
	systemctl stop openvpn-server@server
	rm -rf /etc/openvpn
	rm -rf /etc/systemd/system/multi-user.target.wants/openvpn-server*
	rm -rf /tmp/easy-rsa
	rm -rf /tmp/openvpn*
	rm -rf /tmp/openvpn*
	rm -rf /usr/local/include/openvpn*
	rm -rf /usr/local/lib/openvpn
	rm -rf /usr/local/sbin/openvpn
	rm -rf /usr/sbin/openvpn
	rm -rf /usr/local/share/doc/openvpn
	rm -rf /usr/lib/systemd/system/openvpn*
	rm -rf /var/log/openvpn*
	rm -rf /var/www/openvpn-admin
	m -rf /etc/openvpn/server/openvpn-status.log
	rm -rf /tmpOpenVPN*
	dnf install openvpn -y
}


