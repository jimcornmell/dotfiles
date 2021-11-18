#  _______| |__  _ __ ___
# |_  / __| '_ \| '__/ __|
#  / /\__ \ | | | | | (__
# /___|___/_| |_|_|  \___|
# http://zsh.sourceforge.net/Doc/Release/zsh_toc.html

# Miscellaneous {{{
ostype=$(uname -r)
unsetopt BG_NICE

# export EDITOR='neovide'
# export EDITOR='goneovim'
export EDITOR='lvim'
export MNT=/mnt
export JAVA_HOME=/opt/java
export JQ_COLORS="1;33:4;33:0;33:0;33:0;32:1;37:1;37"
export DISPLAY=:0.0
export BC_ENV_ARGS=~/.bc
export KETTLE_HOME=/opt/data-integration
export CODE_HOME=$HOME/Code/
export LUNARVIM_CONFIG_DIR="${LUNARVIM_CONFIG_DIR:-/home/jim/.config/lvim}"
export LUNARVIM_RUNTIME_DIR="${LUNARVIM_RUNTIME_DIR:-/home/jim/.local/share/lunarvim}"

# Nodejs, npm and nvm
export NVM_DIR="$HOME/.nvm"

# Disable control S so it works with bash searching, like control r
stty -ixon

# Default file permissions.
umask 002

# Set colours of LS.  See: http://blog.twistedcode.org/2008/04/lscolors-explained.html
# https://github.com/trapd00r/LS_COLORS
[ -f ~/.dircolors ] && eval $(dircolors -b $HOME/.dircolors)

# }}}

# Path {{{
# PATH Start with nothing!
unset PATH
export PATH=$PATH:~/bin
export PATH=$PATH:$HOME/.local/kitty.app/bin
export PATH=$PATH:$JAVA_HOME/bin
export PATH=$PATH:/opt/nvim/usr/bin
export PATH=$PATH:/opt/node/bin
export PATH=$PATH:/bin
export PATH=$PATH:/sbin
export PATH=$PATH:/opt/gradle/bin
export PATH=$PATH:/opt/groovy/bin
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:/usr/bin
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/snap/bin
export PATH=$PATH:/opt/docker
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/usr/local/mysql/bin
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:.
# }}}

# ZSH {{{
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export EXA_COLORS="da=0;36"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# For debugging git status issues, comment out normally.
# GITSTATUS_LOG_LEVEL=DEBUG

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="false"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Trying to stop zsh hanging on close.
GIT_PROMPT_FETCH_REMOTE_STATUS=0

export GROFF_NO_SGR=1
ZSH_DISABLE_COMPFIX=true

# }}}

# Powerline10k Prompt {{{
# Switch user prompt.
USER_PROMPT="left_only"

p() {
    case "$USER_PROMPT" in
    "full")
        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user host dir_writable dir vcs)
        POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$'\uE0B0'
        POWERLEVEL9K_DISABLE_RPROMPT=false
        USER_PROMPT="left_only"
        ;;
    "left_only")
        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user host dir_writable dir vcs)
        POWERLEVEL9K_DISABLE_RPROMPT=true
        USER_PROMPT="minimal"
        ;;
    "minimal")
        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status)
        POWERLEVEL9K_DISABLE_RPROMPT=true
        USER_PROMPT="simple"
        ;;
    "simple")
        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir)
        POWERLEVEL9K_DISABLE_RPROMPT=true
        USER_PROMPT="traditional"
        ;;
    "traditional")
        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(custom_traditional_prompt)
        POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
        POWERLEVEL9K_DISABLE_RPROMPT=true
        USER_PROMPT="full"
        ;;
    esac
}

vcs() {
    if [ "$POWERLEVEL9K_LEFT_PROMPT_ELEMENTS" = "user host dir_writable dir" ]; then
        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user host dir_writable dir vcs)
    else
        POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user host dir_writable dir)
    fi
}

# Toggle display of the right prompt.
rprompt() {
    if [[ "$POWERLEVEL9K_DISABLE_RPROMPT" = "true" ]]; then
        POWERLEVEL9K_DISABLE_RPROMPT=false
    else
        POWERLEVEL9K_DISABLE_RPROMPT=true
    fi
}

# Custom traditional prompt.
custom_traditional_prompt() {
    echo "$"
}

# Change to customize for home/work etc.
custom_machine_id() {
    echo "\uF109"
}

# Settings for powerline.
POWERLEVEL9K_MODE='nerdfont-complete'

POWERLEVEL9K_DIR_HOME_BACKGROUND='cyan'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='cyan'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='cyan'

POWERLEVEL9K_HOST_LOCAL_FOREGROUND='black'
POWERLEVEL9K_HOST_LOCAL_BACKGROUND='red1'
POWERLEVEL9K_HOST_REMOTE_FOREGROUND='black'
POWERLEVEL9K_HOST_REMOTE_BACKGROUND='red1'

POWERLEVEL9K_USER_DEFAULT_FOREGROUND='black'
POWERLEVEL9K_USER_DEFAULT_BACKGROUND='red1'

POWERLEVEL9K_STATUS_ERROR_FOREGROUND='red1'
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='grey35'
POWERLEVEL9K_STATUS_OK_FOREGROUND='green'
POWERLEVEL9K_STATUS_OK_BACKGROUND='grey35'

POWERLEVEL9K_AWS_BACKGROUND='grey19'
POWERLEVEL9K_AWS_FOREGROUND='green'

POWERLEVEL9K_CUSTOM_MACHINE_ID="custom_machine_id"
POWERLEVEL9K_CUSTOM_MACHINE_ID_FOREGROUND="black"
POWERLEVEL9K_CUSTOM_MACHINE_ID_BACKGROUND="white"

POWERLEVEL9K_CUSTOM_TRADITIONAL_PROMPT="custom_traditional_prompt"
POWERLEVEL9K_CUSTOM_TRADITIONAL_PROMPT_FOREGROUND="green"
POWERLEVEL9K_CUSTOM_TRADITIONAL_PROMPT_BACKGROUND="grey32"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user host dir_writable dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs history command_execution_time time aws)
POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2

# Set name of the theme to load.
ZSH_THEME=powerlevel10k/powerlevel10k

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    autojump
    aws
    colored-man-pages
    docker
    kubectl
    gradle
    git
    jsontools
    npm
    zsh-autosuggestions
    zsh-syntax-highlighting
    jfrog
)

# Load full oh-my
source $ZSH/oh-my-zsh.sh
# }}}

# History Configuration {{{
HISTFILE=~/.zsh_history     #Where to save history to disk
HISTSIZE=10000              #How many lines of history to keep in memory
SAVEHIST=10000              #Number of history entries to save to disk
HISTDUP=erase               #Erase duplicates in the history file
setopt appendhistory        #Append history to the history file (no overwriting)
setopt sharehistory         #Share history across terminals
setopt incappendhistory     #Immediately append to the history file, not just when a term is killed
setopt HIST_IGNORE_ALL_DUPS
HIST_FORMAT="'%Y-%m-%d %T '"
alias h="fc -r -t "$HIST_FORMAT" -il 1 | \
    awk '{printf(\"\\033[33m%s\\033[36m %s\\033[37m%6d\\033[0m\",\$2,\$3,\$1); \
        out=\"\"; for(i=4;i<=NF;i++){out=out\" \"\$i}; print out}' | most"
# }}}

# GIT {{{
gcamp() {
    git commit -a -m "$1"
    git push
}
gtag () {
    git tag -a $1 -m "Release $1"
    git push origin $1
}

lg() {
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir
    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}

# }}}

# Functions {{{
editFile() {
    if [ "$EDITOR" = "neovide" ]
    then
        (nohup neovide $* &) > /dev/null 2>&1
    elif [ "$EDITOR" = "goneovim" ]
    then
        (nohup goneovim --nvim=/usr/local/bin/lvim --maximized --fullscreen $* &) > /dev/null 2>&1
    else
        $EDITOR $*
    fi
}

# Start bc as Codi a python scratchpad.
bc() {
    local syntax="${1:-python}"
    shift
    $EDITOR -c \
        "let g:startify_disable_at_vimenter = 1 |\
        set bt=nofile ls=0 noru nonu nolist |\
        hi CodiVirtualText guibg=NONE guifg=LightGreen |\
        let g:codi#rightsplit=0 |\
        let g:codi#virtual_text_prefix = '         ➭ ' |\
        Codi $syntax" "Scratchpad.py"
        # let g:codi#rightalign=1
        # let g:codi#width=40
        # hi ColorColumn guibg=NONE
        # hi VertSplit guibg=NONE
        # hi NonText guifg=0
        # let g:codi#virtual_text_prefix = ' ❯❯ ►⮚⮞➤⯈➭ '
}

vd() {
    editFile -d $*
}

vdi() {
    editFile -d -c "set diffopt+=iblank |\
                set diffopt+=icase |\
                set diffopt+=iwhiteall |\
                set diffopt+=iwhiteeol" $*
}

javaRun() {
    echo Compiling $1.java
    javac $1.java

    if [ $? -eq 0 ]; then
        echo Running $1
        echo -- ------------------------------- --
        java $1
        echo -- ------------------------------- --
    else
        echo Compilation error.
    fi
    echo Done
}

# Highlight whole line.
hil() {
    awk -vNRM='\033[0;0m' -vRED='\033[1;31m' -vYELLOW='\033[1;33m' '/ ERROR /{printf("%s%s%s\n", RED, $0, NRM)}/ INFO /{printf("%s%s%s\n", YELLOW, $0, NRM)}!/ ERROR | INFO /';
}

hi() {
    awk -vNRM='\033[0;0m' -vRED='\033[1;31m' -vYELLOW='\033[1;33m' '/^(.*) ERROR (.*)$/{printf("%s%s ERROR %s%s\n", $1, RED, NRM, $2)}/^(.*) INFO (.*)$/{printf("%s%s INFO %s%s\n", $1, YELLOW, NRM, $2)}!/ ERROR | INFO /';
}

# Make a directory and cd into it.
mcd () {
    mkdir -p -- "$1" && cd -P -- "$1"
}

# Given some numbers display a total.
total()
{
    awk '{s+=$1} END{print s}'
}

# Add a `r` function to zsh that opens ranger either at the given directory or
# at the one autojump suggests
r() {
    if [ "$1" != "" ]; then
        if [ -d "$1" ]; then
            ranger "$1" --choosedir=$HOME/.rangerdir
        else
            ranger "$(autojump $1)" --choosedir=$HOME/.rangerdir
        fi
    else
        ranger --choosedir=$HOME/.rangerdir
    fi

    cd $(\cat $HOME/.rangerdir)
    return $?
}
# }}}

# zsh-syntax-highlight colour settings {{{
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_STYLES[alias]=fg=green,bold
ZSH_HIGHLIGHT_STYLES[builtin]=fg=green,bold
ZSH_HIGHLIGHT_STYLES[command]=fg=green,bold
ZSH_HIGHLIGHT_STYLES[path]=fg=white,bold
ZSH_HIGHLIGHT_STYLES[globbing]=fg=white,bold
ZSH_HIGHLIGHT_STYLES[default]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[function]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[hashed-command]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[assig]=fg=cyan,bold
# }}}

# Aliases {{{
# Pretty ping: http://denilson.sa.nom.br/prettyping/
# ncdu: https://dev.yorhel.nl/ncdu

alias "?"="jobs"
alias "\-"="cd -"
alias "td"="~/Documents/Docs"
alias "tc"="~/Code"
alias "tw"="~/Downloads"

alias a=alias
alias banner=figlet
alias clip="xclip -selection c"
alias cls=clear
alias cx="chmod +x "
alias d="dirs -v | head -15"
alias delcolour="sed 's/\x1b\[[0-9;]*m//g'"
alias dol="(/usr/bin/dolphin . > /dev/null 2>&1 &)"
alias du=ncdu
alias e=echo
alias egrep='egrep --color=auto'
alias f=find
alias fgrep='fgrep --color=auto'
alias gaf="git add -f"
alias gcal="gcalcli calm"
alias gd="git diff"
alias g="grep --color=auto -i"
alias grep='grep --color=auto'
alias hibernate='systemctl suspend'
alias ip="ip -c -4 addr"
alias juplab="(jupyter lab > /dev/null 2>&1 &)"
alias kd="kitty +kitten diff"
alias ki="kitty +kitten icat"
alias k=kill
alias markGreen='kitty @ create-marker --self itext 3'
alias markAmber='kitty @ create-marker --self itext 2'
alias markRed='kitty @ create-marker --self itext 1'
alias kon="(/usr/bin/konsole . > /dev/null 2>&1 &)"
alias la='exa -F --git --icons -a --group-directories-first'
alias lla='exa -F --git --icons -la -h --group-directories-first'
alias llart='exa -F --git --icons -la -r -snew -h'
alias llat='exa -F --git --icons -la -snew -h'
alias ll='exa -F --git --icons -l -h --group-directories-first'
alias llrt='exa -F --git --icons -l -r -snew -h'
alias l=ls
alias llt='exa -F --git --icons -l -snew -h'
alias lo=locate
alias ls='exa -F --git --group-directories-first --icons -h'
alias mk="man -k"
alias o=openf
alias pkill="nocorrect pkill"
alias pping=prettyping
alias ping=gping
alias rmdir='rmdirtrash'
alias rm='rmtrash'
alias soffice="/opt/libreoffice/program/soffice"
alias s=sudo
alias sttyreset="stty 502:9:bf:107:0:f:0:0:4:7f:3:15:16:1:1c:12:11:13:1a:1a:0:17"
alias sup="sudo updatedb"
alias tocsv="/opt/libreoffice6.2/program/soffice --headless --convert-to csv "
alias top=bpytop
alias tree="exa -T -l -h --icons --git -F -L 3"
alias t=tail
alias u=uniq
alias v=editFile
alias vg="editFile .gitignore"
alias vgg="editFile ~/.gitignore_global"
alias vi=editFile
alias vj="editFile $CODE_HOME/fis-utils/RundeckJobsLinks.md"
alias vk="editFile ~/.config/kitty/kitty.conf"
# alias vp="editFile -c \":MarkdownPreview\""
alias vr="editFile -c \":MarkdownPreview\" README.md"
alias vv="editFile ~/.config/lvim/config.lua"
alias vz="editFile ~/.zshrc"
alias watchPorts="sudo watch ss -tulpn"
alias watch="watch -c"
alias winx="(/usr/bin/dolphin . > /dev/null 2>&1 &)"
alias w=where
alias x=xargs

# }}}

# Completion {{{
for file in ~/bin/completion-lists/*-completion.list
do
    # Turn on completion.
    command=$(basename $file -completion.list)
    complete -W "$(<$file)" $command
    # Also stop these from being auto corrected.
    alias $command="nocorrect $command"
done

# Completion scripts.
for file in ~/bin/completion-lists/*-completion.sh
do
    command=$(basename $file -completion.sh)
    source $file > /dev/null 2>&1
    # Also stop these from being auto corrected.
    alias $command="nocorrect $command"
done

fpath=(~/bin/completion-lists $fpath)

# Enable autocomplete function.
autoload -Uz compinit
compinit

# Completion for kitty
kitty + complete setup zsh | source /dev/stdin
# }}}

# Bat {{{
# https://github.com/sharkdp/bat
alias highlight=ranger_highlight
export HIGHLIGHT_STYLE=jimburn
alias cat=~/bin/dotfiles/bin/lion
alias more=~/bin/dotfiles/bin/lioness
alias less=~/bin/dotfiles/bin/lioness
alias m=~/bin/dotfiles/bin/lioness
export BAT_THEME=jimburn
export BAT_PAGER="less"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
# }}}

# Docker {{{
alias di='docker images'
alias dc='docker ps --all'

alias docker_images='docker images'
alias docker_ps='docker ps'
alias docker_ps_all='docker ps --all'
alias docker_exec_it='docker exec -it'
alias docker_tail='docker logs -f'
# List stats.
alias docker_stats='docker stats --all --format "table {{.Name}}\t{{.Container}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"'
# stops all containers
alias docker_stop_all='docker stop $(docker ps -a -q)'

alias goDocker="docker-machine start"
alias dm=docker-machine
alias docker_machine_inspect='docker-machine inspect'
alias docker_machine_ip='docker-machine ip'
alias docker_machine_env='docker-machine env'
alias docker_machine_ssh='docker-machine ssh'
alias docker_machine_status='docker-machine status'
alias docker_machine_upgrade='docker-machine upgrade'
alias docker_machine_version='docker-machine version'
# }}}

# Perl {{{
PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;
# }}}

# Source non-general config..... {{{
if [ -e ~/.zshrc_user ]
then
    . ~/.zshrc_user
fi
# }}}

# THIS MUST BE NEAR THE END OF THE FILE FOR FZF TO WORK!!! {{{1
# Fuzzy finder.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!! {{{1
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
