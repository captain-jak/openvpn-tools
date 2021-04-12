#!/bin/bash


# On pousse les nouveaux fichiers sur github
git config --global pull.rebase false
git commit -a -m "Changement par script sur Lenovo3"
git push

# Mise à jour sur le serveur alibaba:
#DISPLAY=1 SSH_ASKPASS="/home/enjoy/.ssh/x" ssh-add ~/.ssh/selfmicro-alibaba.pem < /dev/null
ssh -i ~/.ssh/selfmicro-alibaba.pem root@openvpn.selfmicro.com 'bash -s' < /home/enjoy/openvpn-tools/distant.sh
echo "\e[1;31mMise à jour sur serveur Alibaba faite\e[0m"

# Mise à jour sur le serveur contabo:
ssh -i ~/.ssh/git-contabo root@selfmicro.com 'bash -s' < /home/enjoy/openvpn-tools/distant.sh
echo "Mise à jour sur serveur Contabo faite"
