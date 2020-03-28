source ~/.zsh/.plugins.sh

setopt PROMPT_SUBST

# Tab completion:
zstyle ':completion:*' menu select
zmodload zsh/complist

# Ripped from: https://carlosbecker.com/posts/speeding-up-zsh/
autoload -Uz compinit
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
  compinit
else
  compinit -C
fi

# Tab complete hidden files
_comp_options+=(globdots)

# Aliases:
alias l='ls -AF'
alias build-antibody="antibody bundle < ~/.zsh/.plugins.txt > ~/.zsh/.plugins.sh"

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh/.history
