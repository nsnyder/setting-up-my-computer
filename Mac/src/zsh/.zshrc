source ~/.zsh/.plugins.sh

# Ripped from: https://carlosbecker.com/posts/speeding-up-zsh/
autoload -Uz compinit
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
  compinit
else
  compinit -C
fi

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh/.history
