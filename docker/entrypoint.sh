#!/usr/bin/bash
function setup(){
    if [ ! -d /home/miversen/.ssh ]; then
        echo "Setting up ssh!"
        mkdir -p /home/miversen/.ssh
        chmod 774 /home/miversen/.ssh
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
                mkdir -p $control_path
            fi
        fi
    fi
    DOTFILES_PATH="https://github.com/miversen33/miversen-dotfiles.git"
    su miversen -c '/usr/bin/ssh-keygen -F github.com || /usr/bin/ssh-keyscan github.com >> /home/miversen/.ssh/known_hosts' 2> /dev/null 1> /dev/null
    if [ ! -d /home/miversen/.dotfiles ]; then
        echo "Downloading Dotfiles"
        mkdir -p /home/miversen/.config/{nvim,wezterm}
        su miversen -c "/usr/bin/git clone -q $DOTFILES_PATH /home/miversen/.dotfiles" 2>&1 > /dev/null
        cd /home/miversen/.dotfiles
        su miversen -c "/usr/bin/git submodule update -q --init --recursive" 2>&1 > /dev/null
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
    if [ -S /var/run/docker.sock ]; then
        docker_gid=`getent group docker`
        new_docker_gid=`stat -c %g /var/run/docker.sock`
        groupmod -g $new_docker_gid docker
        find / -gid $docker_gid ! -type l -exec chgrp -h $new_docker_gid {} \+ 2>/dev/null
    fi
    su -l miversen
}

start
