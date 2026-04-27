#!/bin/bash
rm -rf /etc/wolf/lutris2
rm -rf /etc/wolf/lutris3
rm -rf /etc/wolf/lutris4

rm -rf /etc/wolf/profile-data/user2
rm -rf /etc/wolf/profile-data/user3
rm -rf /etc/wolf/profile-data/user4

rsync -arvP /etc/wolf/lutris1/ /etc/wolf/lutris2/
rsync -arvP /etc/wolf/lutris1/ /etc/wolf/lutris3/
rsync -arvP /etc/wolf/lutris1/ /etc/wolf/lutris4/

rsync -arvP /etc/wolf/profile-data/user1/ /etc/wolf/profile-data/user2/
rsync -arvP /etc/wolf/profile-data/user1/ /etc/wolf/profile-data/user3/
rsync -arvP /etc/wolf/profile-data/user1/ /etc/wolf/profile-data/user4/