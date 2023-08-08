#!/usr/bin/bash

function setup(){
    if [ ! -d /home/miversen/.ssh ]; then
        echo "Setting up ssh!"
        mkdir -p /home/miversen/.ssh
        chmod 664 /home/miversen/.ssh
        touch /home/miversen/.ssh/authorized_keys
        chmod 600 /home/miversen/.ssh/authorized_keys
        touch /home/miversen/.ssh/known_hosts
        chmod 640 /home/miversen/.ssh/known_hosts
        [ -f /tmp/ssh_config ] && cp /tmp/ssh_config /home/miversen/.ssh/
        [ -f /tmp/id_rsa.pub ] && cp /tmp/id_rsa.pub /home/miversen/.ssh/
        [ -f /tmp/id_rsa ] && cp /tmp/id_rsa /home/miversen/.ssh/
        [ -f /home/miversen/.ssh/id_rsa ] && chmod 600 /home/miversen/.ssh/id_rsa
        [ -f /home/miversen/.ssh/id_rsa.pub ] && chmod 664 /home/miversen/.ssh/id_rsa.pub
        chown miversen:miversen -R /home/miversen/.ssh
        if [ -f /home/miversen/.ssh/config ]; then
            control_path=`cat /home/miversen/.ssh/config | sed -n "s|^\s*ControlPath\s*['\"]\(.*\)%[a-zA-Z]['\"]$|\1|p"`
            if [ $control_path ]; then
                control_path="${control_path/#\~/home/miversen/}"
                do_log "Ensuring $control_path exists"
                mkdir -p $control_path
            fi
        fi
    fi
    DOTFILES_PATH="https://github.com/miversen33/miversen-dotfiles.git"
    # Only do this if it isn't already in our known_hosts
    if [ -f /home/miversen/.ssh/id_rsa ]; then
        do_log "Found SSH Key, pulling github pubkey"
        DOTFILES_PATH="git@github.com:miversen33/miversen-dotfiles.git";
        GITHUB_KEY=`ssh-keyscan github.com 2> /dev/null`
        echo $GITHUB_KEY >> /home/miversen/.ssh/known_hosts
    fi
    if [ ! -d /home/miversen/.dotfiles ]; then
        echo "Downloading Dotfiles"
        mkdir -p /home/miversen/.dotfiles /home/miversen/.config/{nvim,wezterm}
        git clone -q $DOTFILES_PATH /home/miversen/.dotfiles
        cd /home/miversen/.dotfiles
#         do_log "Updating Submodules of $DOTFILES_PATH"
        git submodule update -q --init --recursive 2>&1 > /dev/null
#         do_log "Setting up links"
        ln -s /home/miversen/.dotfiles/editors/nvim/* /home/miversen/.config/nvim/
        ln -s /home/miversen/.dotfiles/terminals/wezterm/* /home/miversen/.config/wezterm/
        ln -s /home/miversen/.dotfiles/terminals/user_wezconf.lua /home/miversen/.config/wezterm/
    fi

    if [ -d /home/miversen/.dotfiles/shells ]; then
        rm -rf /home/miversen/.zshrc /home/miversen/.p10k.zsh 2> /dev/null
        ln -s /home/miversen/.dotfiles/shells/.shellrc /home/miversen/.zshrc
        ln -s /home/miversen/.dotfiles/shells/.p10k.zsh /home/miversen/.p10k.zsh
    fi
    rm /home/miversen/workspace
    chown miversen:miversen -R /home/miversen
    ln -s /workspace /home/miversen/
    touch /.setup_complete
}

function start(){
    [ ! -f /.setup_complete ] && setup
    su -l miversen
}

start
