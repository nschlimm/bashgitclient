#!/bin/sh

function revertToCommit () {
   echo "Last 15 commits"
   git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n 100
   echo "Enter commit name"
   read cname
   [ "${cname}" = "" ] && waitonexit && return 
   git revert $cname
}

function resetToCommit () {
   echo "Last 15 commits"
   git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n 100
   echo "Enter commit name"
   read cname
   [ "${cname}" = "" ] && waitonexit && return 
   git reset $cname
}

function resetToCommitHard () {
   echo "Last 15 commits"
   git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n 100
   echo "Enter commit name"
   read cname
   [ "${cname}" = "" ] && waitonexit && return 
   git reset --hard $cname 
}

while ${continuemenu:=true}; do
clear
menuInit "Undoing changes"
submenuHead "Undoing changes"
menuPunkt a "Revert commit - (keep commit history)" revertToCommit
menuPunkt b "(Soft) Reset commit - (delete some commits)" resetToCommit
menuPunkt c "(Hard) Reset commit - (delete some commits)" resetToCommitHard

choice
done
noterminate