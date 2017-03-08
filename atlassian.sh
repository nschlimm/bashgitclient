#!/bin/sh

# submenus

function settingUp () {
	source $supergithome/atSettingUp.sh
    nowaitonexit
}

function savingChanges () {
	source $supergithome/atSaveChanges.sh
    nowaitonexit
}

function inspectingRepos () {
	source $supergithome/inspRepo.sh
	nowaitonexit
}


while ${continuemenu:=true}; do
clear
menuInit "Atlassian's View"
echo "Atlassians view on GIT, https://de.atlassian.com/git/tutorials"
echo 
submenuHead "Working on your local repository"
menuPunkt a "Setting up a repository" settingUp
menuPunkt b "Saving changes" savingChanges
menuPunkt c "Inspecting a repository" inspectingRepos
menuPunkt d "Undoing changes" 
menuPunkt e "Rewriting history" 
echo
submenuHead "Collaborating with your homies"
menuPunkt i "Syncing" 
menuPunkt k "Making a pull request" 
menuPunkt l "Using branches" 
echo
submenuHead "Advanced stuff"
menuPunkt n "Merging vs. Rebasing" 
menuPunkt o "Reset, checkout and revert" 
menuPunkt p "Advanced Git log" 
menuPunkt q "Git Hooks" 
menuPunkt r "Refs and the Reflog" 
menuPunkt s "Git LFS" 
echo
showStatus
choice
done
noterminate