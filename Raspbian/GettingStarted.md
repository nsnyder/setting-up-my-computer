# Getting Started

Here's everything you need to know to get the Raspberry Pi
(Specifically, the Raspberry Pi 4) up and running.

> **Status: de-prioritized.** The Pi is still in the setup, but Plex and the
> other Docker services now run on the Debian server (see
> [`Debian/GettingStarted.md`](../Debian/GettingStarted.md)). The Plex, Node-RED,
> Tautulli, and Telegram sections below are kept as they were.
> **TODO:** confirm which of those services still run on the Pi, and delete the rest.

## Version

Last documented version: **Raspbian 10 (buster)**
(Version obtained by `cat /etc/os-release`)

**TODO:** re-check the current version. Buster is end-of-life, so a rebuild
should use a current Raspberry Pi OS.

```bash
# Show the OS version currently installed.
cat /etc/os-release
```

## Dotfiles

```bash
# Tell the installer to use the Raspberry Pi config, then run it from the repo root.
export DOTBOT_INSTALL=install.conf.linux.json
./install
```

## Autologin

To turn off auto-login, run:

```bash
# Open the Raspberry Pi configuration tool.
sudo raspi-config
```

Then, navigate to option 3 (Boot Options), and under the "Desktop / CLI"
option, choose to boot up to the CLI (or desktop), without auto-login.

## Network Shares

My media is on my WD MyCloud Mirror device, which has an NFS network share enabled.

**Do not overwrite `/etc/fstab` with `dotfiles/fstab`.** That file is the old
Pi's `/etc/fstab` from a different disk layout (it references `/dev/mmcblk0p6`
and `p7`), so copying it over a different install can stop the Pi from booting.
Append only the NFS line instead.

```bash
# Install the NFS client.
sudo apt install nfs-common

# Create the mount point.
sudo mkdir -p /media/mycloud

# Append the NFS line from Debian/fstab (everything below its comments) to the end of /etc/fstab.
sudo nano /etc/fstab

# Reload systemd so it sees the new automount, then trigger the mount.
sudo systemctl daemon-reload
ls /media/mycloud
```

The line to add is the same one used on the Debian server:

```
192.168.1.3:/nfs/Media /media/mycloud nfs _netdev,x-systemd.automount,x-systemd.mount-timeout=30,sec=sys,local_lock=posix,rw,nofail,proto=tcp 0 0
```

The options are explained in [`Debian/fstab`](../Debian/fstab).

### Plex metadata over NFS (only if Plex moves back to the Pi)

The old Pi setup also mounted the larger Plex metadata folders from the NAS.
Those lines are still in `dotfiles/fstab` (the `PlexMetadata/Media`, `Metadata`,
and `Cache` mounts). They are not needed while Plex runs in Docker on the Debian server.
For each of those lines, create the empty target folder first.

## Node-Red

Install/update Node-Red (and associated dependencies like npm and node) with the instructions
[here](https://nodered.org/docs/getting-started/raspberrypi).

Certificates for Node-Red come from certbot; see
[`dotfiles/certbot/README.md`](../dotfiles/certbot/README.md).

## Plex

Plex now runs on the Debian server. If you ever install it on the Pi again,
follow [this guide](https://pimylifeup.com/raspberry-pi-plex-server/), with a few modifications.

The guide uses `apt-key`, which is deprecated and is removed from newer Debian-based
releases. The older fix used here was:

```bash
# Old method: add the Plex signing key with apt-key (works on buster).
sudo apt-key adv --fetch-keys https://downloads.plex.tv/plex-keys/PlexSign.key
```

On a current release, use a dedicated keyring instead:

```bash
# Download the Plex signing key and store it in its own keyring.
curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key | sudo gpg --dearmor -o /usr/share/keyrings/plex.gpg

# Point the Plex apt source at that keyring.
echo "deb [signed-by=/usr/share/keyrings/plex.gpg] https://downloads.plex.tv/repo/deb public main" | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
```

When prompted about `/etc/apt/sources.list.d/plexmediaserver.list`, keep the existing file.

### Tautulli

Tautulli provides analytics for the Plex server. Follow the instructions
[here](https://github.com/Tautulli/Tautulli-Wiki/wiki/Installation) to get it up and running.

## Python

There are multiple versions of Python installed on Raspbian by default.
`python` likely refers to Python 2.7, while `python3` likely refers to Python
3.7, or potentially later.

## SSH

To use your existing SSH key to login to your Raspberry Pi, run:

```bash
# Copy your public key to the Pi so password login is not needed.
ssh-copy-id pi@{ip_address}
```

## Sudo

If you don't want the `pi` user to be able to run `sudo` commands without
a password (which you shouldn't), remove the file that enables that like so:

```bash
# Delete the sudoers drop-in that grants passwordless sudo to the pi user.
sudo rm /etc/sudoers.d/010_pi-nopasswd
```

## Telegram

There's kinda a lot to unpack here, but note that information about the existing webhook can be seen here:
https://api.telegram.org/bot<TOKEN>/getWebhookInfo

You can get info about the state of your certificate with the @CanOfWormsBot

The appropriate URL to set your webhook is:
https://api.telegram.org/bot<TOKEN>/setWebhook?url=https://telegram.snydern.com/bot<TOKEN>

And use this for an explainer of the setup: https://core.telegram.org/bots/webhooks#testing-your-bot-with-updates

Also, make sure that port 8443 is forwarded to the Node-Red server (also port 8443) to ensure that things keep working.

Never commit the bot token. Keep it out of this repo and out of shell history.

## `thefuck`

Currently, `thefuck` is broken. To install it, run the following:

```bash
# pipx installs Python tools in isolated environments.
sudo apt install pipx

# Install thefuck itself.
pipx install thefuck

# Add the two modules thefuck needs but no longer ships with.
pipx inject thefuck setuptools
pipx inject thefuck imp2importlib
```