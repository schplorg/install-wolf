# install-wolf

Game streaming server using [Wolf](https://github.com/games-on-whales/wolf) + Moonlight, with isolated per-user Lutris profiles via overlayfs.

## Quick start

```
sudo bash setup.sh
```

This prompts you for GPU type, network adapter, network mode, and number of profiles, writes `.env`, and runs the required install steps automatically.

Then:

```
sudo bash start-wolf.sh
docker logs -f wolf
```

Connect with Moonlight to the server IP, open the pairing link from the log, pair, open the Wolf UI. Once working:

```
sudo bash stop-wolf.sh
```

## Network modes

**Exposed (default)** — game containers share the host network. Simple. Direct join (by IP) works between players. No LAN broadcast discovery.

**Macvlan** — each game container gets its own IP on the LAN (e.g. `192.168.42.130`+). Games can discover each other via LAN broadcast. Requires `create-macvlan.sh` (and `create-dummy-eth.sh` on cloud servers without a real LAN).

`setup.sh` handles this automatically based on your answers.

## Setting up profiles

### First time (no templates)

1. Run `start-wolf.sh`, connect via Moonlight, pick `user1` in Wolf UI, install games.
   Files can be dropped into `/etc/wolf/lutris1/Games` on the host.
2. `stop-wolf.sh`
3. Copy the populated profile to templates:
   ```
   cp -a /etc/wolf/lutris1 /etc/wolf/lutris-template
   cp -a /etc/wolf/profile-data/user1 /etc/wolf/profile-data/user-template
   ```
4. `sudo bash overlay-profiles.sh`
5. `sudo bash start-wolf.sh` — all profiles now share the template via overlayfs.

### With existing templates

```
sudo bash untar-templates.sh      # extracts lutris-template and user-template
sudo bash overlay-profiles.sh
sudo bash start-wolf.sh
```

### Changing the number of profiles

Edit `NUM_PROFILES` in `.env`, re-run `generate-profiles.sh` and `overlay-profiles.sh`, then restart wolf.

## Uninstall

```
sudo bash stop-wolf.sh
sudo bash rm-overlays.sh
sudo bash rm-dummy-eth.sh          # if dummy adapter was created
(docker|podman) network rm wolf_macvlan
rm -rf /etc/wolf
(docker|podman) system prune
```

## Scripts reference

| Script | Purpose |
|---|---|
| `setup.sh` | Interactive first-time setup, writes `.env` |
| `start-wolf.sh` | Start wolf (nvidia/amd, docker/podman) |
| `stop-wolf.sh` | Stop all wolf containers |
| `install-docker-nvidia.sh` | Install Docker + NVIDIA driver + toolkit |
| `generate-profiles.sh` | Write user profile blocks to wolf config.toml |
| `overlay-profiles.sh` | Mount overlayfs for each user profile |
| `rm-overlays.sh` | Unmount and remove overlays |
| `create-macvlan.sh` | Create macvlan docker/podman network |
| `create-dummy-eth.sh` | Create dummy LAN adapter (cloud only) |
| `rm-dummy-eth.sh` | Remove dummy adapter and iptables rules |
| `untar-templates.sh` | Extract template tarballs to `/etc/wolf` |

## .env variables

See `.env.example` for all variables with descriptions. `setup.sh` generates this file interactively.
