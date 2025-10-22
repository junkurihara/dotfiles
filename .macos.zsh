#################################
# macOS specific zsh settings
#################################

# zsh completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

  autoload -Uz compinit
  compinit
fi

# for Homebrew
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
# set homebrew github api token like 'export HOMEBREW_GITHUB_API_TOKEN="xxxxxxx"'
# use osx keychain to handle this.
# source $HOME/.brew_gh_token

# for Node.js
export PATH=$HOME/.npm:$PATH

# for Python 3
alias pip='pip3'
alias python='python3'
alias pip3_update_all='pip3 freeze --local | grep -v "^\-e" | cut -d = -f 1 | xargs pip3 install -U'
export PIPENV_VENV_IN_PROJECT=true

# for Go
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin

# for docker
alias dps='docker ps'
alias drun='docker run'
alias dstart='docker start'
alias dstop='docker stop'

# for Android Platform Tools
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools

# for wine
#alias wine='LC_ALL="ja_JP" wine'

# for Rust
source "$HOME/.cargo/env"
alias cargoup='cargo install-update --all'
. "$HOME/.cargo/env"

# for tar
tgz() {
  env COPYFILE_DISABLE=1 tar zcvf $1 --exclude=".DS_Store" ${@:2}
}

######
## Some more commands for macOS
## brew for intel and m1
if type brew &>/dev/null; then
  alias brewing="brew update; brew upgrade; brew upgrade --cask; brew cleanup -s; rm -rf \"$(brew --cache)\""
fi

## for texlive manager
if type tlmgr &>/dev/null; then
  alias texing="sudo tlmgr update --reinstall-forcibly-removed --self --all"
fi

######
## Work around
if type brew &>/dev/null; then
  export PATH=$(brew --prefix)/opt/openssl@3/bin:$PATH
  export PATH=$(brew --prefix)/opt/curl/bin:$PATH
fi
