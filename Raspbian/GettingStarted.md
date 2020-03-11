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

## SSH

To use your existing SSH key to login to your Raspberry Pi, run:
`ssh-copy-id pi@{ip_address}`

# Sudo

If you don't want the `pi` user to be able to run `sudo` commands without
a password (which you shouldn't), remove the file that enables that like so:

`sudo rm 010_pi-nopasswd `

