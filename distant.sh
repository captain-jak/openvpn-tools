#!/bin/bash

# 1ere installation:
# yum install git
#git clone https://github.com/captain-jak/openvpn-tools.git

# Mise à jour du serveur openvpn:
echo "Mise à jour openvpn.selfmicro.com"
cd ~/openvpn-tools
git pull
