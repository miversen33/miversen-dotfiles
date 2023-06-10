FROM ubuntu:latest
# Basic Setup commands

COPY ./entrypoint.sh /usr/bin/entrypoint

ENV NOTMUX=1
ENV TERM=xterm-256color
ENV COLORTERM=
RUN \
    echo "Setting up basic Ubuntu env" &&\
    rm -rf /opt/neovim/ /usr/local/bin/nvim* /tmp/setup /etc/apt/keyrings/docker.gpg /usr/bin/python ~/.ssh ~/.dotfiles ~/.config/nvim ~/.zshrc ~/.p10k.zsh /workspace /usr/local/bin/* &&\
    yes | unminimize 2>&1 > /dev/null &&\
    apt-get update  -y 2>&1 > /dev/null &&\
    apt-get upgrade -y 2>&1  > /dev/null &&\
    echo "Installing required packages" &&\
    apt-get install -y \
        apt-utils \
        unzip \
        cron \
        python3-pip \
        postgresql-client \
        mysql-client \
        wget \
        make \
        cmake \
        apt-transport-https \
        software-properties-common \
        vim \
        clang \
        gcc \
        g++ \
        ca-certificates \
        gnupg \
        curl \
        iputils-ping \
        man-db \
        zsh \
        bash \
        rsync \
        git \
        nodejs \
        openssh-client \
        tmux \
        2>&1 > /dev/null &&\
    # Setting up the basic editor
    echo "Downloadin Neovimg Nightly" &&\
    mkdir -p /opt/neovim/ /tmp/setup/ &&\
    curl -sLo /tmp/setup/nvim-nightly.tar.gz https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz &&\
    tar -xzf /tmp/setup/nvim-nightly.tar.gz -C /opt/neovim/ && mv /opt/neovim/nvim-linux* /opt/neovim/nightly &&\
    echo "Downloading Neovim Stable" &&\
    curl -sLo /tmp/setup/nvim-stable.tar.gz https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz &&\
    tar -xzf /tmp/setup/nvim-stable.tar.gz -C /opt/neovim/ && mv /opt/neovim/nvim-linux* /opt/neovim/stable &&\
    ln -s /opt/neovim/nightly/ /opt/neovim/current && ln -s /opt/neovim/current/bin/nvim /usr/local/bin/nvim && ln -s /opt/neovim/nightly/bin/nvim /usr/local/bin/nvim-nightly && ln -s /opt/neovim/stable/bin/nvim /usr/local/bin/nvim-stable &&\
    # Setting up Docker out of Docker
echo "Setting up Docker out of Docker" &&\
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>&1 >/dev/null &&\
    chmod a+r /etc/apt/keyrings/docker.gpg &&\
    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null &&\
    apt-get update -y 2>&1 > /dev/null &&\
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>&1 > /dev/null &&\
    curl -Lso /tmp/setup/deno.zip https://github.com/denoland/deno/releases/latest/download/deno-x86_64-unknown-linux-gnu.zip &&\
    unzip -qd /usr/local/bin/ /tmp/setup/deno.zip &&\
    chmod +x /usr/local/bin/deno &&\
    # Setting sane defaults
    ln -s `which python3` /usr/bin/python &&\
    python3 -m pip -q install virtualenv &&\
    chmod +x /usr/bin/entrypoint &&\
    echo "Cleaning up" &&\
    rm -rf /tmp/setup

ENTRYPOINT ["/bin/bash", "/usr/bin/entrypoint"]
