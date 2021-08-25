if [[ ! -n $ZSH_BOOTED ]] then;
  # Only apply plugins once.
  export ZSH_BOOTED=1

  # Nice plugins. :)
  antigen bundle wting/autojump bin
  antigen bundle ohmyzsh/ohmyzsh plugins/git-prompt
  antigen bundle ohmyzsh/ohmyzsh lib
  antigen bundle laggardkernel/zsh-thefuck
  antigen bundle MichaelAquilina/zsh-you-should-use
  antigen bundle brymck/print-alias
  antigen bundle zsh-users/zsh-autosuggestions

  # Setup syntax highlighting last (necessary, except for substring search for some reason).
  antigen bundle zsh-users/zsh-syntax-highlighting
  antigen bundle zsh-users/zsh-history-substring-search
fi

# My theme. :)
antigen theme reobin/typewritten@main typewritten
# antigen theme denysdovhan/spaceship-prompt

# Apply Antigen.
antigen apply
