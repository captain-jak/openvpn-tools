#!/bin/bash


# On pousse les nouveaux fichiers sur github
git commit -a -m "Changement par script sur Lenovo3"
git push

# Mise à jour sur le serveur alibaba:
DISPLAY=1 SSH_ASKPASS="/home/enjoy/.ssh/x" ssh-add ~/.ssh/alibaba-openvpn < /dev/null
ssh -i ~/.ssh/alibaba-openvpn root@openvpn.selfmicro.com 'bash -s' < /home/enjoy/openvpn-tools/distant.sh
