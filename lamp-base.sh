#!/bin/bash

function lamp-base {
	echo "Installation interface administration"
	dnf install -y epel-release
	# Install Apache-MariaDB-php
	while true; do
		read -p "Voulez vous installer Apache-MariaDB-php?(O/n)" yn
		case $yn in
			[Oo]* ) lamp; break;;
			[Nn]* ) break;;
			* ) echo "Répondez Oui ou Non";;
		esac
	done
	reboote
}

function lamp {
	dnf install -y httpd httpd-tools mariadb-server mariadb certbot python3-certbot-apache mod_ssl
	dnf install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm
	dnf -y module reset php
	dnf -y module enable php:remi-7.4
	dnf install -y php php-{mysql,gd,pdo,xml,mbstring,zip,mysqlnd,opcache,json,mcrypt,gettext,curl,intl} 
	# autoriser les services sur le pare-feu
	systemctl enable httpd
	systemctl enable mariadb
	firewall-cmd --permanent --zone=public --add-service=http
	firewall-cmd --permanent --zone=public --add-service=https
	firewall-cmd --reload
	# démarrer Apache et MariaDB
	systemctl start httpd
	systemctl status httpd
	systemctl start mariadb
	systemctl status mariadb
	systemctl enable mariadb
	mysql_secure_installation
	# Create Apache VirtualHost
	mkdir /var/www/openvpn-admin
	echo "<?php phpinfo(); ?>" > /var/www//openvpn-admin/info.php
	echo "
	<VirtualHost *:80>
	ServerAdmin openvpn@selfmicro.com
	DocumentRoot /var/www/openvpn-admin
	ServerName openvpn.selfmicro.com
	ServerAlias www.openvpn.selfmicro.com
	Redirect / https://openvpn.selfmicro.com
	ErrorLog logs/openvpn.selfmicro.com-error.log
	CustomLog logs/openvpn.selfmicro.com-access.log combined
	</VirtualHost>
	<VirtualHost *:443>
	ServerAdmin openvpn@selfmicro.com
	DocumentRoot /var/www/openvpn-admin
	ServerName openvpn.selfmicro.com
	ServerAlias www.openvpn.selfmicro.com
	ErrorLog logs/openvpn.selfmicro.com-error.log
	CustomLog logs/openvpn.selfmicro.com-access.log combined
	</VirtualHost>" > /etc/httpd/conf.d/openvpn.selfmicro.com.conf
	certbot --apache -d openvpn.selfmicro.com -d openvpn.selfmicro.fr
	# Test Setup
	systemctl restart httpd.service
	echo "Pour tester, sur votre navigateur:http://openvpn.selfmicro.com/info.php"
	whiptail --msgbox "Pour tester, sur votre navigateur:\n\nhttp://openvpn.selfmicro.com/info.php" 0 0
	# Intallation webmin
	cd /tmp
	echo "
[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1
	" > /etc/yum.repos.d/webmin.repo
	wget http://www.webmin.com/jcameron-key.asc
	rpm --import jcameron-key.asc
	yum -y install webmin
	systemctl restart firewalld
	systemctl start webmin
	$linstall="Apache-MariaDB-php-webmin"
	updatedb
}

function reboote {
	if (whiptail --title "Confirmation" --yesno "Confirmez vous le redémarrage?" 8 78); then
		echo "Le serveur redémarre."
			reboot -f
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
		systemctl restart openvpn-server@service
		whiptail --title "Openvpn" --msgbox "Versions:\n$VERSION\nEasy-RSA $VERSION2" 10 35
	else
		whiptail --title "Openvpn" --msgbox "Openvpn n'est pas installé." 10 40
	fi
}
