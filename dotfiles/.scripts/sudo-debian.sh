#!/usr/bin/env bash

# Install the apt packages the Debian server setup relies on.
# Run as root (the dotbot config calls it through sudo).

# Exit on errors, unset variables, and failures inside pipelines.
set -euo pipefail

# Refuse to run without root, since apt needs it.
if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this with sudo." >&2
  exit 1
fi

# Refresh the package index.
apt update

# Install everything in one go so apt can resolve dependencies once.
#   zsh, tmux, git, curl   shell, session manager, and what the dotfiles clone/fetch with
#   gpg                    commit signing (missing on a fresh Debian)
#   cron                   scheduled jobs (see Debian/cron)
#   nfs-common             NFS client for the NAS mount in Debian/fstab
#   rsync                  Plex migration and backups
#   python3, venv, pipx    autojump (the "j" command), venvs, and thefuck
apt install -y zsh tmux git curl gpg cron nfs-common rsync python3 python3-venv pipx

# Nothing else is changed: network, DNS, and sleep settings are documented in
# Debian/GettingStarted.md and are deliberately not touched here.
