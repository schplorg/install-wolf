#!/bin/bash

read -p "Extract templates? [y/N] " confirm
[[ "$confirm" != [yY] ]] && exit 0

tar -xf ./templates/lutris-template.tar -C /etc/wolf/lutris-template
tar -xf ./templates/user-template.tar -C /etc/wolf/profile-data/user-template

echo "Done."