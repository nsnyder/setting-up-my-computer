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

Follow the installation instructions [here](https://github.com/erik/lastcast).
**You may need to restart the Raspberry Pi after installation to add `lastcast`
to your PATH**. My Last.fm API credentials are stored on my external drive at
`/Nathan/Important Documents/lastcast-details.txt`.

Copy `lastcast.service` from this folder to `/etc/systemd/system/lastcast.service`
Then run this command:
`chmod +x lastcast.service`
Copy your (modified) `.lastcast.toml` to `/home/pi/.lastcast.toml`
Upgrade PyChromecast (this may give a warning, but it should still work):
`pip3 install --upgrade PyChromecast==4.2`
Enable the service with:
`sudo systemctl enable lastcast --now`

For good measure, feel free to reboot the Pi: `sudo reboot now`

## Python

There are multiple versions of Python installed on Raspbian by default.
`python` likely refers to Python 2.7, while `python3` likely refers to Python
3.7, or potentially later.

## SSH

To use your existing SSH key to login to your Raspberry Pi, run:
`ssh-copy-id pi@{ip_address}`

# Sudo

If you don't want the `pi` user to be able to run `sudo` commands without
a password (which you shouldn't), remove the file that enables that like so:

`sudo rm 010_pi-nopasswd `
