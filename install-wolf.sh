#!/bin/bash
systemctl --user enable --now podman.socket
ls /run/user/$(id -u)/podman/podman.sock

podman compose up -d