# # # Setup wezterm mux server...
# # FROM ubuntu:latest AS wezterm
# # RUN \
# #     apt-get update -y 2>&1 > /dev/null &&\
# #     apt-get install git curl -y 2>&1 > /dev/null &&\
# #     curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y > /dev/null &&\
# #     PATH="$PATH:$HOME/.cargo/bin" &&\
# #     git clone https://github.com/wez/wezterm wezterm-git &&\
# #     # curl -sLo /wezterm-nightly.tar.gz https://github.com/wez/wezterm/releases/download/20230408-112425-69ae8472/wezterm-20230408-112425-69ae8472-src.tar.gz &&\
# #     # tar -xzf /wezterm-nightly.tar.gz &&\
# #     cd /wezterm-git &&\
# #     ./get-deps &&\
# #     cargo build --release &&\
# #     cp /wezterm-git/target/release/wezterm-mux-server / &&\
# #     cp /wezterm-git/target/release/wezterm /
#
FROM ubuntu:latest
# # Basic Setup commands
#
COPY ./entrypoint.sh /usr/bin/entrypoint
#

ENV NOTMUX=1
ENV TERM=xterm-256color
ENV COLORTERM=
ENV DEV_ENV=1
ENV NODE_VERSION=14
RUN \
    echo "Setting up basic Ubuntu env" &&\
    yes | unminimize 2>&1 > /dev/null &&\
    apt-get update  -y 2>&1 > /dev/null &&\
    apt-get upgrade -y 2>&1  > /dev/null &&\
    echo "Installing required packages" &&\
    apt-get install -y \
        dnsutils \
        ripgrep \
        locales \
        iproute2 \
        netcat-openbsd \
        apt-utils \
        unzip \
        cron \
        python3-pip \
        python3-venv \
        postgresql-client \
        mysql-client \
        wget \
        make \
        cmake \
        apt-transport-https \
        software-properties-common \
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
        aptitude \
        openssh-client \
        tmux \
        openssh-server \
        xxd \
        luarocks \
        2>&1 > /dev/null &&\
    locale-gen en_US.UTF-8 &&\
    echo "Setting up node and npm" &&\
    curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - 2>&1 1>/dev/null &&\
    aptitude install -y nodejs npm 2>&1 1>/dev/null &&\
    npm install -g typescript 2>&1 > /dev/null &&\
    # Setting up the basic editor
    echo "Downloading Neovim Nightly" &&\
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
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>&1 > /dev/null &&\
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') &&\
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" 2>&1 > /dev/null &&\
    tar xf /tmp/lazygit.tar.gz -C /tmp/ &&\
    install /tmp/lazygit /usr/local/bin 2>&1 1>/dev/null &&\
    # Setting sane defaults
    echo "Setting Sane Defaults" &&\
    mkdir /workspace &&\
    ln -s `which python3` /usr/bin/python &&\
    if [ ! -f /etc/profile.d/set_dev_env.sh ]; then\
        echo "export DEV_ENV=1" > /etc/profile.d/set_dev_env.sh;\
    fi;\
    if [ ! -f /etc/profile.d/set_term.sh ]; then\
        echo "export TERM=xterm-256color" > /etc/profile.d/set_term.sh;\
    fi;\
    if [ ! $(grep -qE 'AcceptEnv.*TERM' /etc/ssh/sshd_config) ]; then\
        accept_env_var=$(grep -E 'AcceptEnv.*' /etc/ssh/sshd_config);\
        [ ! -n "${accept_env_var}" ] && accept_env_var="AcceptEnv";\
        accept_env_var="$accept_env_var *TERM*";\
        sed -i --expression 's/\(AcceptEnv.*\)/\1 TERM/' /etc/ssh/sshd_config;\
    fi;\
    [ ! $(grep -qEi 'PubkeyAuthentication\s*yes' /etc/ssh/sshd_config) ] && sed -i --expression 's/^.*PubkeyAuthentication.*\$/PubkeyAuthentication yes/' /etc/ssh/sshd_config;\
    sed -i 's/#PubkeyAuthentication/PubkeyAuthentication/' /etc/ssh/sshd_config;\
    echo "Creating miversen User" ;\
    useradd -mG docker -s /bin/zsh miversen 2>&1 > /dev/null &&\
    touch /home/miversen/.notmux &&\
    chown miversen:miversen -R /home/miversen &&\
    ln -s /workspace /home/miversen/workspace &&\
    curl -fso /tmp/install.sh -L https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh 2>&1 > /dev/null &&\
    # For some reason we have to do these separately or it will break the following su...
    su miversen -c "/bin/sh /tmp/install.sh " 2>/dev/null 1>/dev/null &&\
    su miversen -c '/bin/sh -c "git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"' ;\
    rm -rf ~/.zshrc ~/.p10k.zsh 2> /dev/null &&\
    chmod +x /usr/bin/entrypoint &&\
    echo "Cleaning up" &&\
    rm -rf /tmp/{setup,install.sh}

# VOLUME [ "/var/mnt/miversen", "/var/mnt/opt", "/var/mnt/usr/", "/var/mnt/etc" ]


# # COPY --from=wezterm /wezterm-mux-server /usr/bin/wezterm-mux-server
# # COPY --from=wezterm /wezterm /usr/bin/wezterm

WORKDIR /home/miversen/

VOLUME [ "/home/miversen/" ]

# HEALTHCHECK --interval=10s --timeout=30s --start-period=5s --retries=10 CMD [ "test", "-f", "/.setup_complete" ]

ENTRYPOINT ["/bin/bash", "/usr/bin/entrypoint", "-t"]
