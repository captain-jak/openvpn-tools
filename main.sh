#!/bin/bash
# Bienvenue sur digital ocean
# ce script nécessite les bibliotheques dialog et whiptail (newt)
# dnf install -y dialog newt

# ssh - ServerAliveInterval 120 -i ~/.ssh/digital-ocean root@178.128.226.69
# upload fichiers de configuration sur le serveur:
# scp -i ~/.ssh/digital-ocean /home/enjoy/projets/openvpn-tools/openvpn-tools.zip root@openvpn.selfmicro.com:/root/
# puis sur le serveur:
#~ dnf install -y unzip dialog newt
#~ mkdir /root/openvpn-tools
#~ mv /root/openvpn-tools.zip /root/openvpn-tools
#~ cd /root/openvpn-tools/
#~ unzip openvpn-tools.zip
#~ chmod +x *.sh
#~ # démarrage de l'installation
#~ ./main.sh

echo -e "\e[1;31m Bonjour, je démarre \e[0m"

# Paramétres d'installation:
ADRESSE="https://swupdate.openvpn.org/community/releases/"
LAVER="openvpn-2.5.1"
EXT=".tar.xz"
EASYRSA="easy-rsa.git"
DEBUG=6

. /root/openvpn-tools/init.sh
. /root/openvpn-tools/openvpn-install.sh
. /root/openvpn-tools/parefeu.sh
. /root/openvpn-tools/certif.sh
. /root/openvpn-tools/lamp-base.sh
. /root/openvpn-tools/supprime.sh

echo -e "\e[1;31m Encore moi ... \e[0m"

if [[ "${EUID}" == 0 ]]; then
        :
else
	echo " "
        echo -e "\e[1;31m Ce script nécessite les droits administrateurs \e[0m"
	echo " "
        sudo "/tmp/install.sh"
	exit $?
fi

# Définition d'un fichier temporaire
# Il sert à conserver les sorties de dialog qui sont normalement
# redirigées vers la sortie d'erreur (2). trap sert à être propre.
touch /tmp/dialogtmp && FICHTMP=/tmp/dialogtmp
trap "rm -f $FICHTMP" 0 1 2 3 5 15

# Menu principal de choix des boîtes du script
function lemenu {
	# boîte de cases à cocher proprement dite
	dialog --backtitle "Installation Openvpn" --title "Installation Openvpn" \
	--ok-label "Valider" --cancel-label "Quitter" \
	--checklist "
	Cochez les boîtes." 25 60 8 \
	"init" "Initialisation - mise à jour" off \
	"lamp" "Apache - PHP - MariaDB" off \
	"parefeu" "Pare-feu: install - désinstall" off \
	"openvpn" "openvpn - easyrsa - admin openvpn" off \
	"certificat" "Gestion des clés" off \
	"version" "Statut et version du serveur Openvpn" off \
	"uninstall" "Désinstallation" off \
	"reboot" "Redémarrage de la machine" off 2> $FICHTMP
	# traitement de la réponse
	# 0 est le code retour du bouton Valider
	# ici seul le bouton Valider permet de continuer
	# tout autre action (Quitter, Esc, Ctrl-C) arrête le script.

	if [ $? = 0 ]
	then
		for i in `cat $FICHTMP`
		do
			case $i in
				"init") init ;;
				"openvpn") compil;;
				"parefeu") parefeu ;;
				"certificat") certif ;;
				"version") laversion ;;
				"lamp") lamp-base ;;
				"uninstall") suprime ;;
				"reboot") reboote ;;
			esac
		done
	else exit 0
	fi 
}

# Fin des définitions des fonctions
# Boucle d'appel du menu principal à l'infini
while :
	do lemenu
done
# supprime les process dialog qui n'ont pas été fermés
pkill dialog

# find a word in a directory and sundirectories, ignoring the case
# grep -irw openvpn *


