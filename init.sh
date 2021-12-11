#!/bin/bash

# démarrage de l'installation
# initialisation du serveur: mises à jour - création mot de passe 
toto

function init {
	echo "Installation $STR"
	Name=$(whiptail --title "Utilisateur" --inputbox "Utilisateur ?" 10 60 enjoy 3>&1 1>&2 2>&3)
	PASSWORD=$(whiptail --title "Mot de passe" --passwordbox "Mot de passe $Name.\nCe mot de passe sera aussi utilsé pour root" 10 60 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		echo "Utilisateur :" $Name
		echo "Mot de passe : " $PASSWORD
		adduser $Name
		mkdir /home/$Name/.ssh
		cp /root/.ssh/authorized_keys  /home/$Name/.ssh/ 
		usermod -aG wheel $Name
		echo $PASSWORD | passwd $Name --stdin
		echo $PASSWORD | passwd root --stdin
	fi
	dnf install -y epel-release
	dnf update -y
	dnf install -y wget git pam-devel mlocate perl gcc openssl-devel tree dialog
	# multitail permet de suivre 2 fichiers en même temps
	dnf install -y multitail
	whiptail --title "Initialisation" --msgbox "Initialisation et mise à jour terminée." 10 40
}
