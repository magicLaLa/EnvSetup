# Mac 下 zsh 配置

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit light romkatv/zsh-defer

zsh-defer zinit snippet OMZ::lib/history.zsh
zsh-defer zinit snippet OMZ::lib/key-bindings.zsh
zsh-defer zinit snippet OMZ::lib/git.zsh
zsh-defer zinit snippet OMZ::plugins/sudo/sudo.plugin.zsh

zsh-defer zinit wait'1' lucid for \
    zsh-users/zsh-autosuggestions \
    agkozak/zsh-z \
    zsh-users/zsh-completions \
    zdharma-continuum/fast-syntax-highlighting

### End of Zinit's installer chunk

export_init_fun() {
    export NVM_DIR="$HOME/.nvm"
        [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
        [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

    export PATH="/Users/mac/Yinge/cli/bin:$PATH"
    autoload -U compinit; compinit

    export PATH="$HOME/.ycli/release:$PATH"
}
zsh-defer export_init_fun

init_fun() {
    autoload -U add-zsh-hook
}

load_nvmrc() {
    if [[ -f .nvmrc && -r .nvmrc ]]; then
        nvm use
    fi
}

add-zsh-hook chpwd load_nvmrc

alias ..="cd .."

eval "$(starship init zsh)"