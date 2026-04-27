#!/bin/bash

template1=/etc/wolf/lutris-template
targets1=(
  /etc/wolf/lutris1
  /etc/wolf/lutris2
  /etc/wolf/lutris3
  /etc/wolf/lutris4
)

for d in "${targets1[@]}"; do
  [ -e "$d" ] && btrfs subvolume delete "$d"
  if [ -e "$d" ]; then
    rm -rf "$d"
  fi
  btrfs subvolume snapshot $template1 "$d"
done

template2=/etc/wolf/profile-data/user-template
targets2=(
  /etc/wolf/profile-data/user1
  /etc/wolf/profile-data/user3
  /etc/wolf/profile-data/user4
)
for d in "${targets2[@]}"; do
  [ -e "$d" ] && btrfs subvolume delete "$d"
  if [ -e "$d" ]; then
    rm -rf "$d"
  fi
  btrfs subvolume snapshot $template2 "$d"
done
