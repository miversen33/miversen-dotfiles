#!/usr/bin/bash

function setup(){
    if [ -f /.setup_complete ]; then
        return 0
    fi
    rm -rf ~/* ~/.* 2> /dev/null
    echo -n "echo \"ZSH is still setting up, please wait!\";exit 1;" > ~/.zshrc

    mkdir -p ~/.config/{nvim,wezterm} ~/.dotfiles ~/.ssh

    DOTFILES_PATH="https://github.com/miversen33/miversen-dotfiles.git"
    if [ -d /config ]; then
        [ -f /config/id_rsa ] && cp /config/id_rsa ~/.ssh/id_rsa && chown root:root ~/.ssh/id_rsa && chmod 400 ~/.ssh/id_rsa && DOTFILES_PATH="git@github.com:miversen33/miversen-dotfiles.git";
        [ -f /config/id_rsa.pub ] && cp /config/id_rsa.pub ~/.ssh/id_rsa.pub && chown root:root ~/.ssh/id_rsa && chmod 660 ~/.ssh/id_rsa.pub;
        [ -f /config/ssh_config ] && cp /config/ssh_config ~/.ssh/config && chown root:root ~/.ssh/config && chmod 600 ~/.ssh/config;
    fi
    GITHUB_KEY=`ssh-keyscan github.com 2> /dev/null`
    echo $GITHUB_KEY >> ~/.ssh/known_hosts
    git clone -q $DOTFILES_PATH ~/.dotfiles
    cd ~/.dotfiles
    git submodule update -q --init --recursive 2>&1 > /dev/null
    ln -s ~/.dotfiles/editors/nvim/* ~/.config/nvim/
    ln -s ~/.dotfiles/terminals/wezterm/* ~/.config/wezterm/
    ln -s ~/.dotfiles/terminals/user_wezconf.lua ~/.config/wezterm/

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 2>&1 >/dev/null
    git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    rm -rf ~/.zshrc ~/.p10k.zsh 2> /dev/null

    ln -s ~/.dotfiles/shells/.shellrc ~/.zshrc
    ln -s ~/.dotfiles/shells/.p10k.zsh ~/

    chsh --shell /bin/zsh

    touch /.setup_complete
}

function startup(){
    echo "Starting Wezterm Mux Server"
    [ ! `pidof wezterm-mux-server` ] || wezterm-mux-server --daemonize > /dev/null
    
    echo "Starting Cron"
    [ ! `pidof cron` ] || /etc/init.d/cron start > /dev/null

}

setup
startup
tail -f /dev/null

