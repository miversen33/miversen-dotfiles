# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# This should do a dynamic check to see what editors are available. By default, prefer vscode, nvim, vim, vi, nano (in that order)
export EDITOR="vscode"
export TERM="xterm-256color"
export LC_ALL=C.UTF-8

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Oh my zsh stuff
if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    export ZSH="$HOME/.oh-my-zsh"
    # Set name of the theme to load. Optionally, if you set this to "random"
    # it'll load a random theme each time that oh-my-zsh is loaded.
    # See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
    ZSH_THEME="powerlevel10k/powerlevel10k"
    # ZSH_THEME="random"

    # reloads zsh after new program is installed

    # Set list of themes to load
    zstyle ':completion:*' rehash true
    # Setting this variable when ZSH_THEME=random
    # cause zsh load theme from this variable instead of
    # looking in ~/.oh-my-zsh/themes/
    # An empty array have no effect
    # ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

    # Uncomment the following line to use case-sensitive completion.
    # CASE_SENSITIVE="true"

    # Uncomment the following line to use hyphen-insensitive completion. Case
    # sensitive completion must be off. _ and - will be interchangeable.
    # HYPHEN_INSENSITIVE="true"

    # Uncomment the following line to disable bi-weekly auto-update checks.
    # DISABLE_AUTO_UPDATE="true"

    # Uncomment the following line to change how often to auto-update (in days).
    # export UPDATE_ZSH_DAYS=13

    # Uncomment the following line to disable colors in ls.
    # DISABLE_LS_COLORS="true"

    # Uncomment the following line to disable auto-setting terminal title.
    # DISABLE_AUTO_TITLE="true"

    # Uncomment the following line to enable command auto-correction.
    # ENABLE_CORRECTION="true"

    # Uncomment the following line to display red dots whilst waiting for completion.
    # COMPLETION_WAITING_DOTS="true"

    # Uncomment the following line if you want to disable marking untracked files
    # under VCS as dirty. This makes repository status check for large repositories
    # much, much faster.
    # DISABLE_UNTRACKED_FILES_DIRTY="true"

    # Uncomment the following line if you want to change the command execution time
    # stamp shown in the history command output.
    # The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
    # HIST_STAMPS="mm/dd/yyyy"

    # Would you like to use another custom folder than $ZSH/custom?
    # ZSH_CUSTOM=/path/to/new-custom-folder

    # Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
    # Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
    # Example format: plugins=(rails git textmate ruby lighthouse)
    # Add wisely, as too many plugins slow down shell startup.
    plugins=(
        git docker
    )

    autoload -U compinit && compinit
    source $ZSH/oh-my-zsh.sh
fi

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#source /usr/share/zsh-theme-powerlevel9k/powerlevel9k.zsh-theme
#source /etc/profile.d/apps-bin-path.sh


[ -d ${HOME}/.local/bin ] && export PATH="$PATH:$HOME/.local/bin" # Adds local bin to path
[ -d /opt/gradle/current/bin ] && export PATH="$PATH:/opt/gradle/current/bin" # Adds gradle to path if it exists
[ -d /opt/kotlinc/current/bin ] && export PATH="$PATH:/opt/kotlinc/current/bin" # Adds kotlin compiler to path if it exists
[ -d /opt/Unity/current ] && export PATH="$PATH:/opt/Unity/current" # Adds kotlin compiler to path if it exists
if [ -d ${HOME}/perl5 ]; then #The perl shits
  export PATH="$PATH:$HOME/perl5/bin"; # Adds perl5 (perlbrew) to path if it exists
  export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}";
  export PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}";
  export PERL_MB_OPT="--install_base \"$HOME/perl5\"";
  export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5";
  \. $HOME/perl5/perlbrew/etc/bashrc # Executes perlbrew bashrc because ¯\_(ツ)_/¯
fi
if [ -d "${HOME}.nvm" ]; then  # nvm shit
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi
if [ -d "/opt/nodejs" ]; then #Handle Node shit
  export NODE_PARENT=/opt/nodejs/current
  export PATH=${NODE_PARENT}/bin:${PATH}
  export NODE_PATH=${NODE_PARENT}/lib/node_modules
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
