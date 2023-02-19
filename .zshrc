#################################
# Environment specific settings
#################################
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

if [ $OS = "Manjaro Linux" ]; then
  source ~/.manjaro.zsh
elif [ $OS = "Darwin" ]; then
  source ~/.macos.zsh
else
  echo "Unsupported OS"
fi


#################################
# Common settings
#################################

######
## Using OpenPGP for SSH via gpg-agent only if GPG card is inserted.
sshgpg(){
  if gpg --card-status &>/dev/null; then
    SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket) command ssh $@
  else
    command ssh $@
  fi
}

export GPG_TTY="$(tty)"
gpgconf --launch gpg-agent
alias ssh='sshgpg'



######
## Customize terminal prompt
if type starship &>/dev/null; then
  export PS1="%~ %# "
  eval "$(starship init zsh)"
fi

######
## Customize some commands
if type lsd &>/dev/null; then
  alias ls='lsd'
  export LS_COLORS='di=01;36:ln=01;35:so=32:pi=33:ex=04;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:st=30;42:tw=30;43'
else
  alias ls='ls -G'
  export LSCOLORS=GxFxcxdxbxegedabagacad
  export LS_COLORS=GxFxcxdxbxegedabagacad
fi

if type bat &>/dev/null; then
  alias cat='bat'
fi

if type rg &>/dev/null; then
  alias grep='rg --color=auto'
else
  alias grep='grep --color=auto'
fi

######
## Some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vi='vim'
