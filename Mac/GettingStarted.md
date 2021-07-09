# Getting Started

There are some things that should be done before anything else
when you start up your Mac. Start with [Brew](#brew). Then run:
```sh
./install # This will use dotbot to install dotfiles as specified in install.conf.json
```

## Antigen

> Note: I was previously using Antibody. That is now discontinued.

[Antigen](https://github.com/zsh-users/antigen) is a plugin manager for ZSH
(MacOS's default shell as of Catalina). It is installed automatically with all other brews.

Any time you update any `zsh` plugins (`~/.zsh/.plugins.zsh`), restart `zsh`:
```bash
source ~/.zshrc
```

## Autojump

[Autojump](https://github.com/wting/autojump) is a tool to quickly browse through your files.
It works in most shells, but only for files you've already navigated to. Install it,
then it should work with either of the existing configurations for either Bash or ZSH.

```bash
$ brew install autojump
```

## Bash

MacOS ships with a 2007 (!!!) version of Bash. We should upgrade it.

```bash
$ brew install bash
```

You'll need to make this new `bash` the default shell. Add this line to `/etc/shells`:
```bash
/usr/local/bin/bash
```

And then change the default shell as follows:
```bash
$ chsh -s /usr/local/bin/bash
```

You'll also want to make sure all necessary configuration dotfiles are installed:
```bash
./install install.conf.bash.json
```

Voila!

## Bash Completion

Start by installing it (the proper [Bash](#bash) version is required for this step):
```bash
$ brew install bash-completion@2
```

### Resources

[Programmable Completion for Bash on MacOS](https://itnext.io/programmable-completion-for-bash-on-macos-f81a0103080b)

## Brew

The first thing to install on Mac OS is install [Brew](https://brew.sh).
The instructions should be available on the website. Most other things on
Mac will be installed through Brew.

If you have any problems with anything `brew` related, try `brew doctor` and read through
any messages that appear.

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
(This step has already been accomplished if you ran the dotbot `./install`.)

## ZSH

See [Antibody](#antibody).
