# Programming

This file should contain a variety of setups that I use for programming.

## Pip

Pip can be installed with [get-pip.py](https://pip.pypa.io/en/stable/installing/#installing-with-get-pip-py)
```
$ curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
$ python3 get-pip.py
$ rm get-pip.py
```

## Powerline

If anything here doesn't work, follow the reference linked below.

First install [Pip](#pip) (above). Then do as follows:

```
$ pip install --user powerline-status
$ pip install --user powerline-gitstatus
```

Add these lines to `~/.bash_profile`:

```
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /Users/nathan/Library/Python/2.7/lib/python/site-packages/powerline/bindings/bash/powerline.sh
```

The final line can be gotten by running `pip show powerline-status` and then
using the `Location`  field, with everything past `site-packages`.

Copy the files from `./src/powerline` to the respective folders (and remove the `colorschemes.` and `themes.`
prefixes).
```
$ cp colorschemes.default.json ~/Library/Python/2.7/lib/python/site-packages/powerline/config_files/colorschemes/shell/default.json
$ cp themes.default.json ~/Library/Python/2.7/lib/python/site-packages/powerline/config_files/themes/shell/default.json
```

The necessary fonts may have already been installed, but if not, check [here](GettingStarted.md#menlo-for-powerline).

You will need to restart Terminal.app after installation.

#### References:
[How to Jazz Up Your Bash Terminal — A Step By Step Guide With Pictures](https://www.freecodecamp.org/news/jazz-up-your-bash-terminal-a-step-by-step-guide-with-pictures-80267554cb22/)

## SSH

To configure Mac OS to
[remember the SSH key in the keychain](https://apple.stackexchange.com/questions/48502/how-can-i-permanently-add-my-ssh-private-key-to-keychain-so-it-is-automatically),
run this command:

```
s$ sh-add -K ~/.ssh/[your-private-key]
```

Next, copy `PlatformAgnostic/ssh-config` to `~/.ssh/config`.
