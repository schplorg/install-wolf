#!/usr/bin/env bash
set -euo pipefail

source .env

mkdir -p images
wget -P ./images "$ARCHIVE_URL/public-20230728/wolf/gow---nvidia-driver---latest.tar"
wget -P ./images "$ARCHIVE_URL/public-20230728/wolf/ghcr.io-games-on-whales-lutris-edge.tar"
wget -P ./images "$ARCHIVE_URL/public-20230728/wolf/ghcr.io-games-on-whales-wolf-ui-main.tar"
wget -P ./images "$ARCHIVE_URL/public-20230728/wolf/ghcr.io-games-on-whales-pulseaudio-master.tar"
wget -P ./images "$ARCHIVE_URL/public-20230728/wolf/ghcr.io-games-on-whales-wolf-stable.tar"
mkdir -p templates
wget -P ./templates "$ARCHIVE_URL/public-20230728/wolf/lutris-template-v4.tar"
wget -P ./templates "$ARCHIVE_URL/public-20230728/wolf/user-template-v4.tar"