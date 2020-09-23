#!/usr/bin/env bash

# Clone or pull locast2plex.
if [[ ! -e $2/locast2plex/git/config.ini ]]; then
  cp $1/config.ini $2/locast2plex/git/config.ini
  chown pi:pi $2/locast2plex/git/config.ini

  if read -p "Locast email: " email; then
    sed -i~ -e "s/{{LOCAST_EMAIL}}/${email}/g" $2/locast2plex/git/config.ini
  fi
  if read -s -p "Locast password: " password; then
    printf "\n"
    sed -i~ -e "s/{{LOCAST_PASSWORD}}/${password}/g" $2/locast2plex/git/config.ini
  fi
fi

cp $1/locast2plex.service /etc/systemd/system/locast2plex.service
chmod +x /etc/systemd/system/locast2plex.service
systemctl enable locast2plex --now

# Install docker. (Disabled because the project doesn't support the RPi4 on Docker yet.)
# apt install docker docker-compose
# docker-compose -f $2/locast2plex/git/docker-compose.yml up
