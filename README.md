#!/bin/bash

echo "# openvpn-tools de La borne saint léger" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/captain-jak/openvpn-tools.git
git push -u origin main
