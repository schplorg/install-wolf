#!/bin/bash

template1=/etc/wolf/lutris1
targets1=(
  /etc/wolf/lutris2
  /etc/wolf/lutris3
  /etc/wolf/lutris4
)

for d in "${targets1[@]}"; do
  [ -e "$d" ] && btrfs subvolume delete "$d"
  btrfs subvolume snapshot $template1 "$d"
done

template2=/etc/wolf/profile-data/user1
targets2=(
  /etc/wolf/profile-data/user2
  /etc/wolf/profile-data/user3
  /etc/wolf/profile-data/user4
)
for d in "${targets2[@]}"; do
  [ -e "$d" ] && btrfs subvolume delete "$d"
  btrfs subvolume snapshot $template2 "$d"
done
