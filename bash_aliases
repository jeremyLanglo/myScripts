#!/bin/bash

###### alias
alias term="gnome-terminal"
# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'

alias moer='more'
alias moew='more'

alias c="clear"
alias r="reset"

alias termReset="c && r && . ~/.bashrc"

# Find a file with a pattern in name:
function ff()
{
    find . -type f -iname '*'"$*"'*' -ls ;
}

# Find a file with pattern $1 in name and Execute $2 on it:
function fe()
{
    find . -type f -iname '*'"${1:-}"'*' -exec ${2:-file} {} \;  ; 
}

#  Find a pattern in a set of files and highlight them:
#+ (needs a recent version of egrep).
function fstr()
{
    OPTIND=1
    local mycase=""
    local usage="fstr: find string in files. Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "
    while getopts :it opt
    do
        case "$opt" in
           i) mycase="-i " ;;
           *) echo "$usage"; return ;;
        esac
    done
    shift $(( $OPTIND - 1 ))
    if [ "$#" -lt 1 ]; then
        echo "$usage"
        return;
    fi
    find . -type f -name "${2:-*}" -print0 | xargs -0 egrep --color=always -sn ${mycase} "$1" 2>&- | more
}

function extract()      # Handy Extract Program
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# Creates an archive (*.tar.gz) from given directory.
function maketar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }

# Create a ZIP archive of a file or folder.
function makezip() { zip -r "${1%%/}.zip" "$1" ; }

# Make your directories and files access rights sane.
function sanitize() { chmod -R u=rwX,g=rX,o= "$@" ;}

function my_ip() # Get IP adress on ethernet.
{
    MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' |
      sed -e s/addr://)
    echo ${MY_IP:-"Not connected"}
}

# Create a directory and got into
function mcd() {
  mkdir -p "$1" && cd "$1";
}

# search a process
function fp()
{
    if [ "$#" -lt 1 ] || [ "$#" -gt 1 ]; then
        printf "Find process\nUsage: fp pattern\n"
        return;
    fi
    ps -ef | grep -v grep | grep $1
}

# Kill un process
function kp() 
{
    if [ "$#" -lt 1 ] || [ "$#" -gt 1 ]; then
        printf "Kill process\nUsage: kp pattern\n"
        return;
    fi
    sudo kill -9 `fp $1 | awk '{print $2}'`
}

# Misc utilities
#################
function repeat()       # Repeat n times command.
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do  # --> C-like syntax
        eval "$@";
    done
}


function ask()          # See 'killps' for example of use.
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function corename()   # Get name of app that created a corefile.
{
    for file ; do
        echo -n $file : ; gdb --core=$file --batch | head -1
    done
}

# Git
#################
alias maj="git fetchall && git pull"
alias gst="git status"

__define_git_completion () {
eval "
    _git_$2_shortcut () {
        COMP_LINE=\"git $2\${COMP_LINE#$1}\"
        let COMP_POINT+=$((4+${#2}-${#1}))
        COMP_WORDS=(git $2 \"\${COMP_WORDS[@]:1}\")
        let COMP_CWORD+=1

        local cur words cword prev
        _get_comp_words_by_ref -n =: cur words cword prev
        _git_$2
    }
"
}

__git_completion () {
    type _git_$2_shortcut &>/dev/null || __define_git_completion $1 $2
    complete -o default -o nospace -F _git_$2_shortcut $1
}

__git_completion  gba   branch -a
__git_completion  gco   checkout
complete -o default -o nospace -F _git g

###### end
echo -e "\e[1;33m*** Bash aliases have been loaded ***\e[0m"
