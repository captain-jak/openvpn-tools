#!/bin/bash

# On pousse les nouveaux fichiers sur le serveur:
git commit -a -m "Change"
git push

# Mise à jour du serveur:
DISPLAY=1 SSH_ASKPASS="/home/enjoy/.ssh/x" ssh-add ~/.ssh/digital-ocean < /dev/null
ssh -i ~/.ssh/digital-ocean root@openvpn.selfmicro.com 'bash -s' < /home/enjoy/openvpn-tools/distant.sh

