# Getting Started

There are some things that should be done before anything else
when you start up your Mac. Start with [Brew](#brew).

## Bash

MacOS ships with a 2007 (!!!) version of Bash. We should upgrade it.

```
$ brew install bash
```

You'll need to make this new `bash` the default shell. Add this line to `/etc/shells`:
```
/usr/local/bin/bash
```

And then change the default shell as follows:
```
$ chsh -s /usr/local/bin/bash
```

Voila!

## Bash Completion

Start by installing it (the proper [Bash](#bash) version is required for this step):
```
$ brew install bash-completion@2
```

### Resources

[Programmable Completion for Bash on MacOS](https://itnext.io/programmable-completion-for-bash-on-macos-f81a0103080b)

## Brew

The first thing to install on Mac OS is install [Brew](https://brew.sh).
The instructions should be available on the website. Most other things on
Mac will be installed through Brew.

You should probably go through [Bash](#bash) and [Bash Completion](#bash-completion) next.

## Fonts

### Fira Code

This is my preferred font for programming. To install it, follow the instructions
[here](https://github.com/tonsky/FiraCode/wiki/Installing).
Fira Code has all features necessary to support [Powerline](Programming.md#powerline).

### Menlo for Powerline

Menlo for Powerline is an alternative to Fira Code that supports all desired effects when running
[Powerline](Programming.md#powerline) in the terminal. Get it [here](https://github.com/abertsch/Menlo-for-Powerline).

## Karabiner Elements

Install Karabiner-Elements with:

```
$ brew cask install karabiner-elements
```

Add the `karabiner.json` from this file to `~/.config/karabiner`, and you're good to go!
