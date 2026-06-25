#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1="\[\e[1;31m\]┌──[\[\e[0m\]\w\[\e[1;31m\]]\n\[\e[1;31m\]└─\[\e[1;34m\]$ \[\e[0m\]"
PS2='> '
