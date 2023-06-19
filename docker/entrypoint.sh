#!/usr/bin/bash

DEBUG=1

function do_log() {
    if [ $DEBUG == 1 ]; then
        echo "Entrypoint: $*"
    fi
}

function setup(){
    if [ -f /.setup_complete ]; then
        do_log "Setup Complete"
        return 0
    fi
    # do_log "Clearing out home directory"
    # rm -rf ~/* ~/.* 2> /dev/null
    if [ ! -f ~/.zshrc ]; then
        do_log "Prepopulating ZSHRC"
        echo -n "echo \"ZSH is still setting up, please wait!\";exit 1;" > ~/.zshrc
    fi


    DOTFILES_PATH="https://github.com/miversen33/miversen-dotfiles.git"
    if [ ! -d ~/.ssh ] && [ -d /config ]; then
        mkdir -p ~/.ssh
        do_log "Found config directory, checking for ssh stuff"
        [ -f /config/id_rsa ] && cp /config/id_rsa ~/.ssh/id_rsa && chown root:root ~/.ssh/id_rsa && chmod 400 ~/.ssh/id_rsa && DOTFILES_PATH="git@github.com:miversen33/miversen-dotfiles.git";
        [ -f /config/id_rsa.pub ] && cp /config/id_rsa.pub ~/.ssh/id_rsa.pub && chown root:root ~/.ssh/id_rsa && chmod 660 ~/.ssh/id_rsa.pub;
        [ -f /config/ssh_config ] && cp /config/ssh_config ~/.ssh/config && chown root:root ~/.ssh/config && chmod 600 ~/.ssh/config;
    fi
    if [ -f ~/.ssh/config ]; then
        control_path=`cat ~/.ssh/config | sed -n "s|^\s*ControlPath\s*['\"]\(.*\)%[a-zA-Z]['\"]$|\1|p"`
        if [ $control_path ]; then
            control_path="${control_path/#\~/$HOME}"
            do_log "Ensuring $control_path exists"
            mkdir -p $control_path
        fi
    fi
    if [ -f ~/.ssh/id_rsa ]; then
        do_log "Found SSH Key, pulling github pubkey"
        GITHUB_KEY=`ssh-keyscan github.com 2> /dev/null`
        echo $GITHUB_KEY >> ~/.ssh/known_hosts
    fi
    if [ ! -d ~/.dotfiles ]; then
        mkdir -p ~/.dotfiles ~/.config/{nvim,wezterm}
        do_log "Reaching out to $DOTFILES_PATH"
        git clone -q $DOTFILES_PATH ~/.dotfiles
        cd ~/.dotfiles
        do_log "Updating Submodules of $DOTFILES_PATH"
        git submodule update -q --init --recursive 2>&1 > /dev/null
        do_log "Setting up links"
        ln -s ~/.dotfiles/editors/nvim/* ~/.config/nvim/
        ln -s ~/.dotfiles/terminals/wezterm/* ~/.config/wezterm/
        ln -s ~/.dotfiles/terminals/user_wezconf.lua ~/.config/wezterm/
    fi

    if [ ! -d ~/.oh-my-zsh ]; then
        do_log "Setting up ohmyzsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 2>&1 >/dev/null
        git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

        rm -rf ~/.zshrc ~/.p10k.zsh 2> /dev/null

        if [ -d ~/.dotfiles/shells ]; then
            ln -s ~/.dotfiles/shells/.shellrc ~/.zshrc
            ln -s ~/.dotfiles/shells/.p10k.zsh ~/
        fi
    fi

    if [ ! -f /usr/local/bin/lazygit ]; then
        do_log "Setting up Lazygit"
        cd /tmp/
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        install lazygit /usr/local/bin
    fi

    if [ ! -f /usr/bin/tsserver ]; then
        do_log "Installing Typescript"
        npm install -g typescript 2>&1 > /dev/null
    fi

    if [ ! -d ~/workspace ]; then
        do_log "Setting up workspace link to ~/workspace"
        rm -rf ~/workspace
        ln -s /workspace ~/workspace
    fi

    do_log "Setting default shell to /bin/.zsh"
    chsh --shell /bin/zsh

    touch /.setup_complete
    echo "Dev Env Setup Complete"
}

function startup(){
    echo "Starting Wezterm Mux Server"
    if [ -x "$(command -v wezterm-mux-server)" ] && [ ! `pidof wezterm-mux-server` ]; then
        do_log "Starting Wezterm Mux Server"
        wezterm-mux-server --daemonize > /dev/null
    fi
    echo "Starting Cron"
    [ ! `pidof cron` ] || /etc/init.d/cron start > /dev/null

}

setup
startup
tail -f /dev/null

