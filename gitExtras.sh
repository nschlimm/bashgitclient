#!/bin/sh

function changeBlame () {
	git log --pretty=format:'%Cred%h%Creset | %Cgreen%ad%Creset | %s %C(yellow)%d%Creset %C(bold blue)[%an]%Creset %Cgreen(%cr)%Creset' --graph --date=short
	echo "Enter baseline commit:"
	read baseline
	echo "Enter until commit (default HEAD):"
	read untilcommit
	executeCommand "git guilt $baseline ${untilcommit:-HEAD}"
}

function removeLatest () {
	echo "How many commits to remove?"
	read ccommit
	executeCommand "git back $ccommit"
}

function findOut () {
	executeCommand "git authors --list"
	echo "Enter author to check:"
	read author
	echo "Since?"
	read since
	executeCommand "git standup $author \"$since\""
}

function obliberate () {
	read -p "This programm completely deletes. Continue (y/n)? " -n 1 -r
	echo
	if [[ $REPLY =~ [Yy]$ ]]; then
		selectItem "git ls-files"
		read -p "Remove $selected (y/n)? " -n 1 -r
		echo
		if [[ $REPLY =~ [Yy]$ ]]; then
		   executeCommand "git obliberate $selected"
		fi
	fi
	
}

while ${continuemenu:=true}; do
clear
menuInit "Git extras menu"
submenuHead "Project information"
menuPunkt a "Project summary in commits" "git summary"
menuPunkt b "Project summary in lines of code" "git summary --line"
menuPunkt c "Effort in the project per file" "git effort"
menuPunkt d "Show all ignore patterns from local and global" "git ignore"
menuPunkt e "Show information about the repo" "git info"
menuPunkt f "Generate changelog" "git changelog -a"
menuPunkt g "Show tree" "git show-tree"
menuPunkt h "Show activity calendar" "git cal"
echo
submenuHead "Author information"
menuPunkt k "List authors" "git authors --list"
menuPunkt l "Find out what somebody did since ..." findOut
menuPunkt m "Display change in blame between two revisions" changeBlame
echo
submenuHead "Effect repository actions"
menuPunkt q "Remove latest commits and add their changes to stage" removeLatest
menuPunkt r "Completely remove a file from the repository" obliberate
menuPunkt s "Setup git repository in current dir" "git setup"
echo
choice
done
noterminate
