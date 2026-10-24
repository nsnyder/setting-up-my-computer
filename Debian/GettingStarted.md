# Debian Server: Getting Started

Setup notes for the always-on Debian server (a repurposed 2014 MacBook Pro,
dual booting with macOS). It runs Plex and the other Docker services.
Anything marked **TODO** is a step that was not in the shell history and
should be filled in from memory.

## Repos used

| Repo | Purpose | Location |
| --- | --- | --- |
| `plex-docker` | Plex in Docker Compose | `~/projects/plex-docker` |
| `local-services` | Traefik, WordPress, Pi-hole, dnscrypt-proxy, forward auth, backups | `~/projects/local-services` |
| `claude-one-offs` | Podcast grabber and Plex description sync (own Python venv) | `~/projects/claude-one-offs` |
| `setting-up-my-computer` | This repo (dotfiles and docs) | `~/projects/setting-up-my-computer` |

## Never sleep

The machine must stay up with the lid closed.

```bash
# Create the drop-in directory for logind settings.
sudo mkdir -p /etc/systemd/logind.conf.d

# Ignore the lid switch and idle timeouts.
sudo tee /etc/systemd/logind.conf.d/no-sleep.conf > /dev/null <<'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
IdleAction=ignore
EOF

# Make it impossible for anything to put the machine to sleep.
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Apply everything with a reboot.
sudo reboot
```

## Docker

```bash
# TODO: add Docker's official apt repository first (record the exact steps used).
# Do NOT install the plain "docker" package from apt; it is an unrelated old tool.

# Install the Docker engine and the compose plugin.
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Confirm the service is running.
sudo systemctl status docker

# Let your user run docker without sudo (the group may already exist).
sudo groupadd docker
sudo usermod -aG docker $USER

# Group changes only apply to new sessions. "exec zsh" was not enough here;
# a reboot (or logging out and back in) was needed.
sudo reboot now
```

## NFS share (WD My Cloud)

Media lives on the NAS at `192.168.1.3:/nfs/Media`, mounted at `/media/mycloud`.
Use [`Debian/fstab`](fstab). It lists the install steps and what each option does.

**Append the line to `/etc/fstab`. Never copy `dotfiles/fstab` over it; that file
is for the old Raspberry Pi and would break boot on this machine.**

## Plex (`plex-docker`)

```bash
# Start Plex.
cd ~/projects/plex-docker
docker compose up -d

# Follow the logs while it starts.
docker logs --follow plex
```

Notes:

- `.env` holds `PLEX_CLAIM` plus `PLEX_UID` and `PLEX_GID`. These are currently
  `1000:1000`, matching `id -u` and `id -g` for this user. `.env` is **not committed**.
- `config/` must be owned by the same UID and GID: `sudo chown -R 1000:1000 config/`.
- `PLEX_CLAIM` tokens expire after a few minutes, so claim a fresh one right before the first start.
- Earlier attempts used `500:1000` to match the file owner on the NAS. If Plex ever
  needs to write to the share again, check ownership with `ls -lnd /media/mycloud/*`.

### Migrating Plex from the old server's drive

```bash
# Find the old drive first. The device letter changes between boots
# (it was sdc2 one time and sdb2 another), so never assume it.
lsblk

# Mount it read-only to be safe (replace sdX2 with what lsblk shows).
sudo mkdir -p /mnt/usb
sudo mount -o ro /dev/sdX2 /mnt/usb

# Copy the Plex data, skipping the large and regenerable Cache folder.
mkdir -p ~/Downloads/backupplex
sudo rsync -a --exclude='Cache' --progress /mnt/usb/var/lib/plexmediaserver/ ~/Downloads/backupplex

# Put the Library folder where the container expects it, then fix ownership.
mkdir -p ~/projects/plex-docker/config
mv ~/Downloads/backupplex/Library ~/projects/plex-docker/config/
sudo chown -R 1000:1000 ~/projects/plex-docker/config

# Remove the stray root-level shell history the old install left behind;
# it is unreadable by the backup script.
sudo rm -f ~/projects/plex-docker/config/.bash_history

# Unmount when done. If it says "busy", find the culprit with: sudo lsof /mnt/usb
sudo umount /mnt/usb
```

### Backup

`appdata-backup.sh` (in `plex-docker`) backs up `config/`. It runs from cron;
see [Cron jobs](#cron-jobs). Check for unreadable files before trusting a backup:

```bash
# List anything the current user cannot read, grouped by type, owner, and mode.
find ~/projects/plex-docker/config ! -readable -printf '%y %u:%g %m\n' 2>/dev/null | sort | uniq -c | sort -rn
```

## Traefik routing (`plex.snydern.com`)

Plex is exposed through the Traefik stack in `local-services` via Docker labels.
Troubleshooting checklist, in the order that worked:

```bash
# 1. Confirm the shared network exists and Plex is attached to it.
docker network ls
docker inspect plex --format '{{json .NetworkSettings.Networks}}'

# 2. Restart Traefik so it re-reads the container labels.
docker restart local-services-traefik-1

# 3. Test through Traefik. -k skips certificate verification.
curl -sk https://plex.snydern.com/identity

# 4. If the name does not resolve on the server itself, flush the DNS cache.
#    A temporary /etc/hosts entry was used for this; Pi-hole is expected to
#    provide the local record again later, so no hosts entry is documented.
sudo resolvectl flush-caches
```

## Restoring `local-services`

```bash
# Clone the repo.
cd ~/projects
git clone git@github.com:nsnyder/local-services.git
cd local-services

# Create .env from the template and fill in the secrets (or copy it from the old drive).
# This file must never be committed.
cp .env.example .env

# Start everything.
docker compose up -d
```

Restoring the database volume from the old drive:

```bash
# Stop the database first.
docker compose stop db

# Replace the volume contents. Use -a (not -r) so ownership and permissions are
# preserved; MariaDB/MySQL data files must keep their original owner.
sudo rm -r /var/lib/docker/volumes/local-services_db_data
sudo cp -a /mnt/usb/var/lib/docker/volumes/local-services_db_data /var/lib/docker/volumes/local-services_db_data

# Start the database, then WordPress.
docker compose start db
docker compose start wordpress
```

## Git, SSH, and commit signing

```bash
# Install gpg (it is not present on a fresh Debian).
sudo apt install gpg

# Generate a signing key and note its long key ID.
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long

# Print the public key to paste into GitHub (Settings > SSH and GPG keys).
gpg --armor --export <KEY_ID>
```

`dotfiles/.gitconfig` signs commits with `nathan@snydern.com`. SSH keys and
`~/.ssh/config.core` come from the dotbot install. The private keys are not
in this repo.

## Cron jobs

```bash
# Install cron if it is missing.
sudo apt install cron

# Go to the cron folder (schedules are already filled in).
cd ~/projects/setting-up-my-computer/Debian/cron
chmod +x install-cron.sh

# Preview, then install.
./install-cron.sh --dry-run
./install-cron.sh
```

Job logs land in `~/.local/state/cron/`.

## Python venv for `claude-one-offs`

```bash
# Debian needs the venv package for its current Python.
sudo apt install python3.13-venv

# Create and fill the venv.
cd ~/projects/claude-one-offs
python3 -m venv venv
source venv/bin/activate
pip install -r podcast_grabber/requirements.txt
pip install -r sync_plex_descriptions/requirements.txt

# Config files hold secrets and are not committed. Copy them from the old drive:
#   podcast_grabber/config.json
#   sync_plex_descriptions/plex_config.json
```
