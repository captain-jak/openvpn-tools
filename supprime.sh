#!/bin/bash

function suprime {
		echo "Désnstallation: openvpn - administration openvpn - firewalld - easy-rsa"
		whiptail --title "Désinstallation" --msgbox "Désinstallation (sauf LAMP):\n- openvpn\n- easy-rsa\n- administration openvpn\n" 10 40
#########################################################################
# menu de désinstallation
########################################################################
# desinstallation LAMP
# dnf remove -y php php-{mysql,gd,pdo,xml,mbstring,zip,mysqlnd,opcache,json,mcrypt,gettext,curl,intl} 
# dnf remove -y httpd httpd-tools mariadb-server mariadb certbot python3-certbot-apache mod_ssl

#~ # certificats
#~ rm -rf /etc/letsencrypt/archive/openvpn.selfmicro*
#~ rm -rf /etc/letsencrypt/live/openvpn.selfmicro*
#~ rm -rf /etc/letsencrypt/renewal/openvpn.selfmicro*
#~ rm -rf /var/lib/letsencrypt/backups/*
#~ # apache
#~ rm -rf rm -rf /var/log/httpd/openvpn.selfmicro*
#~ rm -rf /etc/httpd/conf.d/openvpn.selfmicro*
#~ # divers
rm -rf /usr/local/share/man/man8/openvpn*
rm -rf /tmp/root
rm -rf /tmp/jcameron-*

########################################################################

		systemctl stop firewalld
		systemctl stop openvpn-server@server
		dnf remove lz4-devel lzo-devel openvpn -y
		dnf remove nodejs unzip git wget sed npm
		rm -rf /etc/openvpn
		rm -rf /etc/systemd/system/multi-user.target.wants/openvpn-server*
		rm -rf /tmp/easy-rsa
		rm -rf /tmp/openvpn*
		rm -rf /tmp/openvpn*
		cd /tmp/OpenVPN-Admin
		./desinstall.sh
		cd /tmp
		rm -rf OpenVPN-Admin
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
		updatedb
}

function uninstall {
	
}
