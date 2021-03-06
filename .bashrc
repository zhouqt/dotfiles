#!/bin/bash
# vim:fdm=marker

# Check if this is a non-login shells {{{
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac
# }}}


# Define variants {{{
unset PROMPT_COMMAND

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoredups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000
EDITOR='vim'
EDITOR=vim
VISUAL=vim

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
# }}}

# Prompt {{{

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
    xterm-kitty) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    [[ -f $HOME/.bash_promptcolor ]] && source $HOME/.bash_promptcolor || BASH_PROMPT_COLOR=2
    PS_CHROOT="${debian_chroot:+($debian_chroot)}"
    PS_TIME="[\[$(tput setaf 4)\]\t\[$(tput sgr0)\]] "
    PS_USER="\[$(tput bold)$(tput setaf $BASH_PROMPT_COLOR)\]\u\[$(tput sgr0)\]"
    PS_HOST="\[$(tput bold)$(tput setaf $BASH_PROMPT_COLOR)\]\h\[$(tput sgr0)\]"
    PS_DIR="\[$(tput bold)$(tput setaf 4)\]\w\[$(tput sgr0)\]"
    PS1="$PS_TIME$PS_CHROOT$PS_USER@$PS_HOST:$PS_DIR\$ "
    unset PS_TIME PS_CHROOT PS_USER PS_HOST PS_DIR
else
    PS1='[\t] ${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
# }}}

# Key binding {{{
bind '"": history-search-backward'
bind '"": history-search-forward'
# }}}


# Path {{{
# brew install coreutils
COREUTTILS_DIR="/usr/local/opt/coreutils/libexec/"
if [ -d $COREUTTILS_DIR ]; then
    export PATH="$COREUTTILS_DIR/gnubin:${PATH:+:${PATH}}"
    export MANPATH="$COREUTTILS_DIR/gnuman:${MANPATH:+:${MANPATH}}"
fi
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
export PATH="/usr/local/sbin${PATH:+:${PATH}}"
export PATH="$HOME/bin${PATH:+:${PATH}}"
# }}}


# Alias definitions {{{
# enable color support of ls and also add handy aliases
DIRCOLORS=`which dircolors`
if [ x"$DIRCOLORS" != x"" ]; then
    test -r ~/.dircolors && eval "$($DIRCOLORS -b ~/.dircolors)" || eval "$($DIRCOLORS -b)"
    [[ -f $HOME/.lscolor256 ]] && eval $($DIRCOLORS -b $HOME/.lscolor256) || eval $($DIRCOLORS -b)
    alias ls='ls --color=auto'
    #alias dir='ls --color=auto --format=vertical'
    #alias vdir='ls --color=auto --format=long'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias df='df -Th'
alias du='du -h'
#show directories size
alias dud='du -s *'
#date for Many countries
alias adate='for i in GMT US/Eastern Australia/Brisbane Asia/Shanghai UK/London Europe/Paris; do printf %-22s "$i:";TZ=$i date +"%m-%d %a %H:%M";done'
alias info='info --vi-keys'
alias rsync='rsync --progress --partial'
alias grep='grep -n --exclude-dir="__pycache__"'

alias aria2c='aria2c --summary-interval=0'
alias ssh-fingerprint='ssh-keygen -E md5 -lf'

# For specific distros
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # Linux {{{
    alias dmesg='dmesg -H'
    alias autoremove='sudo apt-get -y autoremove --purge && sudo apt-get clean && dpkg -l |grep ^rc |awk "{print \$2}" |sudo xargs -r dpkg -P'
    alias upgrade='sudo apt-get update && sudo apt-get -y dist-upgrade && autoremove'
    # Add an "alert" alias for long running commands.  Use like so:
    #   sleep 10; alert
    #alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
    alias maas-sysid="maas admin nodes read | jq '.[] | {hostname:.hostname, system_id: .system_id, status:.status}' --compact-output"
    #}}}
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX {{{
    #alias ls='ls -G'
    alias brew='ALL_PROXY=127.0.0.1:12345 brew'
    #alias vim='/usr/local/bin/vim'
    #alias vimdiff='/usr/local/bin/vimdiff'
    alias ssh='TERM=xterm-color ssh'
    alias upgrade='brew update && brew upgrade && brew cask upgrade && brew cleanup'
    #}}}
fi
# }}}

# Include internal used alias
if [ -r ".bash_alias_company" ]; then
    source ~/.bash_alias_company
fi

# Enable syntax-highlighting in less.
# brew install highlight
# apt-get install highlight
if [ -f /usr/local/bin/highlight ] || [ -f /usr/bin/highlight ]; then
    export LESS_TERMCAP_so=$'\e[03;38;5;202m'
    export LESS_TERMCAP_se=$'\e[0m'
    export LESS_TERMCAP_mb=$'\e[01;31m'
    export LESS_TERMCAP_md=$'\e[01;38;5;180m'
    export LESS_TERMCAP_me=$'\e[0m'
    export LESS_TERMCAP_ue=$'\e[0m'
    export LESS_TERMCAP_us=$'\e[04;38;5;139m'
    export LESSOPEN="| $(which highlight) %s --out-format xterm256 --quiet --force --style edit-vim-dark"
    export LESS=" -R "
    alias less='less -m -N -g -i -J --underline-special --SILENT'
    alias more='more -LF'
fi

# enable programmable completion features {{{
# (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi

    # Git completion
    if [ -f /usr/local/share/zsh/site-functions/git-completion.bash ]; then
        # MacOS
        . /usr/local/share/zsh/site-functions/git-completion.bash
    elif [ -f /usr/share/bash-completion/completions/git ]; then
        # Linux
        . /usr/share/bash-completion/completions/git
    fi

    KUBECTL=`which kubectl`
    if [ x"$KUBECTL" != x"" ]; then
        source <($KUBECTL completion bash)
    fi
fi
# }}}

# Bash git prompt {{{
# https://github.com/magicmonty/bash-git-prompt
if [ -f "/usr/local/opt/bash-git-prompt/share/gitprompt.sh" ]; then
    __GIT_PROMPT_DIR="/usr/local/opt/bash-git-prompt/share"
    GIT_PROMPT_ONLY_IN_REPO=1
    # GIT_PROMPT_FETCH_REMOTE_STATUS=0   # uncomment to avoid fetching remote status
    # GIT_PROMPT_IGNORE_SUBMODULES=1 # uncomment to avoid searching for changed files in submodules
    # GIT_PROMPT_WITH_VIRTUAL_ENV=0 # uncomment to avoid setting virtual environment infos for node/python/conda environments

    # GIT_PROMPT_SHOW_UPSTREAM=1 # uncomment to show upstream tracking branch
    # GIT_PROMPT_SHOW_UNTRACKED_FILES=normal # can be no, normal or all; determines counting of untracked files

    # GIT_PROMPT_SHOW_CHANGED_FILES_COUNT=0 # uncomment to avoid printing the number of changed files

    # GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh # uncomment to support Git older than 1.7.10

    # GIT_PROMPT_START=...    # uncomment for custom prompt start sequence
    # GIT_PROMPT_END=...      # uncomment for custom prompt end sequence

    # as last entry source the gitprompt script
    # GIT_PROMPT_THEME=Custom # use custom theme specified in file GIT_PROMPT_THEME_FILE (default ~/.git-prompt-colors.sh)
    GIT_PROMPT_THEME=Solarized_Ubuntu
    # GIT_PROMPT_THEME_FILE=~/.git-prompt-colors.sh
    # GIT_PROMPT_THEME=Solarized # use theme optimized for solarized color scheme
    source "/usr/local/opt/bash-git-prompt/share/gitprompt.sh"
fi
# }}}


# SSH agent {{{
if [ x"$SSH_CLIENT" == x"" ]; then
    if [ x"$SSH_AUTH_SOCK" == x"" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
        if [ ! -S ~/.ssh/ssh_auth_sock ]; then
            eval `ssh-agent`
            ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
        fi
        export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
    fi
    ssh-add -l > /dev/null || ssh-add
fi
# }}}


# This line was appended by KDE
# Make sure our customised gtkrc file is loaded.
export GTK2_RC_FILES=$HOME/.gtkrc-2.0

export LC_ALL=en_US.UTF-8
