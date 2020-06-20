# Potential colors can be found by entering: spectrum_ls
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=247"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

export ZDOTDIR=$HOME/.zsh

# Set "hardcore mode" for zsh-you-should-use.
export YSU_HARDCORE=1

# Ripped from: https://carlosbecker.com/posts/speeding-up-zsh/
autoload -Uz compinit
if [ $(date +'%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]; then
  compinit
else
  compinit -C
fi

###########################################
#             Setup the Theme             #
###########################################

export ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%} ✘"

export TYPEWRITTEN_MULTILINE=false

# Import plugins.
source ~/.zsh/.plugins.sh

# Inspired by: https://gist.github.com/BretFisher/78a90d4e39e79d5f3c9769d4002f67a7
# Make sure to set this up after your theme. If the left prompt is dynamic,
# then initial_prompt should be declared *inside* the function.
local initial_prompt=$PROMPT
function _show_presenting () {
  local good_emoji=🍹

  # If we're in presentation mode, use coffee instead of alcohol.
  if [[ -n $PRESENT ]] then
    good_emoji=☕️

    if [[ ! $PWD == $PRESENT ]]; then
      # If we're not in the root, show the current folder.
      RPROMPT="%{$fg[magenta]%} %c %{$fg[blue]%}<%{$reset_color%}"
    else
      # Otherwise, show the minimum.
      RPROMPT="%{$fg[blue]%} <"
    fi
  fi
  PROMPT=%(?:$good_emoji:🔥)" ${initial_prompt}"
}

# MacOS doesn't support the more thorough colors format, but you can install gls with coreutils which does!
eval "$(gdircolors ~/.dir_colors)"
export LS_OPTIONS="--color=auto"
export LSCOLORS='GxfxcxcxBxcaeaababagag'

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Run the prompts, and change directories quicker.
setopt PROMPT_SUBST
setopt AUTO_CD

# Tab completion:
zstyle ':completion:*' menu select
zmodload zsh/complist

# Tab complete hidden files.
_comp_options+=(globdots)

# Aliases:

# Git.
alias ga='git add .'
alias gc='git commit -a'
alias gd='git diff'
alias gp='git push'
alias gpu='git push -u'
alias gs='git status'

# Common utilities.
alias ls='gls $LS_OPTIONS'
alias l='gls $LS_OPTIONS -AF'

# Presentation mode.
alias present='export PRESENT=$(pwd)'
alias unpresent='unset PRESENT'

alias build-antibody="antibody bundle < ~/.zsh/.plugins.txt > ~/.zsh/.plugins.sh && source ~/.zshrc"

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh/.history

precmd_functions+=(_show_presenting)

# Render colors when the shell starts. (Useful when testing colors.)
# ~/projects/setting-up-my-computer/dotfiles/color-viewer.sh
