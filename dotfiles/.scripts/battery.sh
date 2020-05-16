#!/usr/bin/env bash

# For inspiration, consider: https://github.com/simonsmith/dotfiles/blob/master/bin/battery
# IMO, it's way overcomplicated, but there's some good stuff that could be used in there.
pmset -g batt | grep -Eo "\\d+%"
