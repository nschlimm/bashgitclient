#!/bin/sh

# all your menu actions here

function ignorePrevCommited () {
    selectItem "git ls-files"
	executeCommand "git rm --cached $selected"
}

function commitIgnored () {
    selectItem "git ls-files --others -i --exclude-standard"
    executeCommand "git add -f $selected" 
    executeCommand "git commit -m \"Force adding $selected\""
}

function defineIgnoreException () {
	selectItem "git ls-files --others -i --exclude-standard"
	executeCommand "echo !$selected >> .gitignore"
}


while ${continuemenu:=true}; do
clear
menuInit "Ignore menu"
submenuHead "Ignoring files:"
menuPunkt a "Adding shared ignore rules (.gitignore)" "vim .gitignore"
menuPunkt b	"Adding personal git ignore rules (.git/info/exclude)" "vim .git/info/exclude"
menuPunkt c	"Adding global git ignore rules (~/.gitignore)" "vim ~/.gitignore"
menuPunkt d	"Ignoring a previously commited file" ignorePrevCommited
menuPunkt e "Committing an ignored file" commitIgnored
menuPunkt f "Defining exceptions to ignore rules (.gitignore)" defineIgnoreException
echo
submenuHead "File status:"
menuPunkt j "List tracked files" "git ls-files"
menuPunkt k "List untracked files" "git ls-files --others --exclude-standard"
menuPunkt l "List ignored files" "git ls-files --others -i --exclude-standard"
echo
choice
done
noterminate