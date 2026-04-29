## install-wolf

### initial setup
```
create an .env file and fill the values detailed in .env.example
make sure you can reach the moonlight ports of the server, see moonlight docs
for nvidia, run install-docker-nvidia.sh
for nvidia, run start-docker-nvidia-wolf.sh
for amd, run start-podman-amd-wolf.sh
run (docker or podman) logs -f wolf
connect with moonlight to the server ip
observe the log and open the link, potentially adjust the host in the url to your server
pair moonlight, open the wolf UI and wait until it loads, if you see a user screen its working
run stop-wolf.sh
```

### if you want games to see each other in a regular LAN environment
#### server in real LAN
```
if you're running a server in your LAN:
adjust the env variables so your server physical network adapter is configured as LAN_ADAPTER and MACVLAN_ADAPTER e.g. eth0
```

#### cloud server
```
adjust the env variables so your server physical network adapter is configured as LAN_ADAPTER e.g. eth0 and then set  DUMMY_ADAPTER MACVLAN_ADAPTER to e.g. dummyeth-0
run create-dummy-lan.sh

in both cases:
run create-macvlan.sh
run apply-custom-lan.sh
```

### if using the regular 10.88.0.x docker network is fine (direct join will work):
```
run apply-custom-exposed-host.sh
```

### setting up profiles

#### if you have no templates
```
make sure one of the apply-custom- scripts ran and there are extra user1 etc profiles at the end of /etc/wolf/cfg/config.toml
run one of the start- scripts
connect via moonlight, open wolf UI, choose one of the users e.g. user1 and install some games, files can be dropped into the host folders e.g. /etc/wolf/lutris1/Games
once done, run stop-wolf.sh
copy /etc/wolf/lutris1 to /etc/wolf/lutris-template
copy /etc/wolf/profile-data/user1 to /etc/wolf/profile-data/user-template
run overlay-profiles.sh
rerun your start- script again
see now all profiles have the same data as the template
```

#### if you have existing templates
```
extract lutris and user templates e.g. using untar-templates.sh read the script before
ensure /etc/wolf/lutris-template exists
ensure /etc/wolf/profile-data/user-template exists
run overlay-profiles.sh
rerun your start- script again
see now all profiles have the same data as the template
```

### general usage

#### uninstall
run stop-wolf.sh
run rm-overlays.sh
if macvlan was used (docker or podman) network rm wolf_macvlan
if dummy adapter was created run rm dummy-eth.sh
rm -rf /etc/wolf
(docker or podman) system prune