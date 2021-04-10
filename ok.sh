#!/bin/bash


# On pousse les nouveaux fichiers sur github
git config --global pull.rebase false
git commit -a -m "Changement par script sur Lenovo3"
git push

# Mise à jour sur le serveur alibaba:
#DISPLAY=1 SSH_ASKPASS="/home/enjoy/.ssh/x" ssh-add ~/.ssh/selfmicro-alibaba.pem < /dev/null
ssh -i ~/.ssh/selfmicro-alibaba.pem root@openvpn.selfmicro.com 'bash -s' < /home/enjoy/openvpn-tools/distant.sh

# Mise à jour sur le serveur digital-ocean:
ssh -i ~/.ssh/digital-ocean root@openvpn2.selfmicro.com 'bash -s' < /home/enjoy/openvpn-tools/distant.sh
