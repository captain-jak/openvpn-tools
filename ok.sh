#!/bin/bash

# On pousse les nouveaux fichiers sur le serveur:
git commit -a -m "Change"
git push

# Mise à jour du serveur:
ssh -i ~/.ssh/github root@openvpn.selfmicro.com 'bash -s' < /home/enjoy/openvpn-tools/distant.sh
