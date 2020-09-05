#!/usr/bin/env bash

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

# The following snippet was taken from:
#   https://stackoverflow.com/questions/40549332/how-to-check-if-ssh-agent-is-already-running-in-bash
# Ensure agent is running.
ssh-add -l &>/dev/null
if [ "$?" = 2 ]; then
    # Could not open a connection to your authentication agent.

    # Load stored agent connection info.
    test -r ~/.ssh-agent && \
        eval "$(<~/.ssh-agent)" >/dev/null

    ssh-add -l &>/dev/null
    if [ "$?" = 2 ]; then
        # Start agent and store agent connection info.
        (umask 066; ssh-agent > ~/.ssh-agent)
        eval "$(<~/.ssh-agent)" >/dev/null
    fi
fi

# Load identities.
ssh-add -l &>/dev/null
if [ "$?" = 1 ]; then
    # The agent has no identities. Check if we want to add one.
    confirm "Would you like to add an SSH identity now? You can always add one later with ssh-store. [Y/n]" && ssh-add -t 4h
fi


