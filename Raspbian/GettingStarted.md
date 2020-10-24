# Getting Started

Here's everything you need to know to get the Raspberry Pi
(Specifically, the Raspberry Pi 4) up and running.

## Version

Version: **Raspbian 10 (buster)**
(Version obtained by `cat /etc/os-release`)

## Autologin

To turn off auto-login, run:
`sudo raspi-config`

Then, navigate to option 3 (Boot Options), and under the "Desktop / CLI"
option, choose to boot up to the CLI (or desktop), without auto-login.

## Lastcast

_Note: This has been working pretty inconsistently, but Plex has scrobbling, so this is less vital than it was previously._

Follow the installation instructions [here](https://github.com/erik/lastcast).
**You may need to restart the Raspberry Pi after installation to add `lastcast`
to your PATH**. My Last.fm API credentials are stored on my external drive at
`/Nathan/Important Documents/lastcast-details.txt`.

Copy `lastcast.service` from this folder to `/etc/systemd/system/lastcast.service`
Then run this command:
`chmod +x lastcast.service`
Copy your (modified) `.lastcast.toml` to `/home/pi/.lastcast.toml`
Upgrade PyChromecast (this may give a warning, but it should still work):
```
$ pip3 install --upgrade PyChromecast==4.2
```

Enable the service with:
```
$ sudo systemctl enable lastcast --now
```

For good measure, feel free to reboot the Pi: `sudo reboot now`

## Network Shares

My media is on my WD MyCloud Mirror device, which has an NFS network share enabled.

Run:
```
$ sudo cp dotfiles/fstab /etc/fstab
```

For the Plex mounts, you should create empty folders in the expected locations for the relevant lines in fstab.

## Plex

Follow [this guide](https://pimylifeup.com/raspberry-pi-plex-server/), with a few modifications.

Instead of this:
```
curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
```
Do this:
```
sudo apt-key adv --fetch-keys https://downloads.plex.tv/plex-keys/PlexSign.key
```

When prompted about `/etc/apt/sources.list.d/plexmediaserver.list`, keep the existing file.

### Tautulli

Tautulli provides analytics for the Plex server. Follow the instructions
[here](https://github.com/Tautulli/Tautulli-Wiki/wiki/Installation) to get it up and running.

## Python

There are multiple versions of Python installed on Raspbian by default.
`python` likely refers to Python 2.7, while `python3` likely refers to Python
3.7, or potentially later.

## Samba

Start with these commands:
```
sudo apt-get install samba samba-common-bin
sudo mkdir /media/mycloud
sudo nano /etc/fstab
```

Add the following line to `/etc/fstab`:
```
//192.168.1.3/media /media/mycloud cifs credentials=/root/mycloud-credentials,uid=plex,x-systemd.automount,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm 0 0
```
Note `x-systemd.automount`. That will make the line to be mounted when it is first accessed.

Once installed, the Samba configuration file will be at:
```
/etc/samba/smb.conf
```

Securely store the login credentials. The credential file will be in the following format:
```
username=<username>
password=<password>
```

Set it up here:
```
sudo nano /root/mycloud-credentials
chmod 700 /root/mycloud-credentials
```

### References
[AskUbuntu related to mounting on boot](https://askubuntu.com/questions/399643/cifs-mount-through-fstab-not-mounting-at-boot)
[ServerFault related to credential storage](https://serverfault.com/questions/222074/fstab-and-cifs-mounting-possible-to-store-authentication-information-outside-of)

## SSH

To use your existing SSH key to login to your Raspberry Pi, run:
```
$ ssh-copy-id pi@{ip_address}
```

# Sudo

If you don't want the `pi` user to be able to run `sudo` commands without
a password (which you shouldn't), remove the file that enables that like so:

```
sudo rm 010_pi-nopasswd
```
