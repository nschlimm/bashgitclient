#!/bin/sh

function revertToCommit () {
   git revert HEAD
}

function revertToCommit () {
   echo "Last 15 commits"
   git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n 100
   echo "Enter commit to revert (all changes of that commit will be reverted)"
   read cname
   [ "${cname}" = "" ] && waitonexit && return 
   git revert $cname
}

function resetToCommit () {
   echo "Last 15 commits"
   git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n 100
   echo "Enter target commit for reset (all commits after the commit will be deleted)"
   read cname
   [ "${cname}" = "" ] && waitonexit && return 
   git reset $cname
}

function resetToCommitHard () {
   echo "Last 15 commits"
   git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n 100
   echo "Enter target commit for reset (all commits after the commit will be deleted) - YOUR LOCAL WORKING DIR WILL BE OVERWRTITTEN!"
   read cname
   [ "${cname}" = "" ] && waitonexit && return 
   git reset --hard $cname 
}

while ${continuemenu:=true}; do
clear
menuInit "Undoing changes"
submenuHead "Undoing changes"
menuPunkt a "Revert last commit - (keep commit history)" revertLastCommit
menuPunkt b "Revert commit - (keep commit history)" revertToCommit
menuPunkt c "(Soft) Reset commit - (delete some commits)" resetToCommit
menuPunkt d "(Hard) Reset commit - (delete some commits)" resetToCommitHard

echo
echo "NOTE: if your work with remote repos and already 
      pushed commits that you want to undo -> PREFER REVERT !!"

choice
done
noterminate