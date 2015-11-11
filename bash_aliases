#!/bin/bash

# GIT
######

# alias
alias git="cd . && git"
alias gst="git status"


# MISC
#######

# Create a directory and got into
function mcd() {
  mkdir -p "$1" && cd "$1";
}

# search a process
alias psgrep='ps -ef | grep'


###### end
echo -e "\e[1;33m*** Bash aliases have been loaded ***\e[0m"
