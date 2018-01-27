#!/bin/sh
supergithome=~/workspaces/personal/supergitclient
source $supergithome/flexmenu.sh
trackchoices=$1

function analyzeWorkingDir (){
   wstat=$(git diff HEAD --shortstat) # analyze local dir working status vs. actual checkout
   if [ -z "$wstat" ]; then
      wstat="tracked files clean"
   fi
   untracked=$(git ls-files --others --exclude-standard)
   if [ -z "$untracked" ]; then
      wstat="$wstat (no untracked files present)"
    else
      filescount=$(git ls-files --others --exclude-standard | wc -l)
      wstat="$wstat (WARN: $filescount untracked file(s) present)"
   fi
   echo "Working directory vs. HEAD: $wstat"
   echo
}

function pushActual() {
  executeCommand "git fetch --all"
  importantLog "Checking your head state"
  if git status | grep -q "HEAD detached"; then
     echo "... you seem to be on a detached head state ... can't push ..."
  else
    echo "... your HEAD is attached to $actual ..."
    mergeChanges
    addAllUntracked
    commitChanges
    pushChanges
  fi
}

function pushChanges () {
    importantLog "Checking for stuff to push to origin/$actual"
    if git log origin/$actual..$actual --oneline | grep -q ".*"; then
      echo "... found commited updates in $actual waiting for push to origin/$actual ..."
      read -p "Push (y/n)? " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then #push
         executeCommand "git push -u origin $actual"
      fi
    else
      echo "... nothing to push ..."
    fi
}

function addAllUntracked () {
    importantLog "Checking for untracked files in the working tree"
    # check to see if untracked files are in working tree
    if git ls-files --others --exclude-standard | grep -q ".*"; then
      echo "... untracked files found ..."
      executeCommand "git ls-files --others --exclude-standard"
      read -p "Add all (y/n)? " -n 1 -r
      echo    # (optional) move to a new line
      if [[ $REPLY =~ ^[Yy]$ ]]; then
         executeCommand "git add ."
      fi
    else
      echo "... no untracked files present ..."
    fi
}

function mergeChanges () {
    importantLog "Checking for updates from origin/$actual"
    if git diff $actual origin/$actual | grep -q ".*"; then
       echo "... found diff between $actual and origin/$actual ..."
       if git status | grep "Your branch is ahead"; then
          echo "... your local branch is ahead of origin/$actual ... nothing to merge"
        else
          echo "... your local branch is behind of origin/$actual ... recommend merge !"
          diffDrillDownAdvanced "git diff --name-status $actual origin/$actual" " .*" "$actual" "origin/$actual"
          executeCommand "git diff --name-status $actual origin/$actual"
          read -p "Merge (y/n)? " -n 1 -r
          echo    # (optional) move to a new line
          if [[ $REPLY =~ ^[Yy]$ ]]; then
             executeCommand "git merge origin/$actual"
          fi
        fi
    else
       echo "... nothing to merge ... up to date"
    fi
}

function commitChanges () {
    importantLog "Checking for stuff to commit from the working tree"
    if git status -s -uno| grep -q ".*"; then
      echo "... found updates on tracked files in working tree ..."
      diffDrillDownAdvanced "git status -s -uno" " .*" HEAD
      read -p "Commit the updates (y/n)? " -n 1 -r
      echo    # (optional) move to a new line
      if [[ $REPLY =~ ^[Yy]$ ]]; then
           read -p "Enter commit message:" cmsg
           executeCommand "git commit -am '${cmsg}'" # stage and commit all tracked filess
      fi
    else
      echo "... nothing to commit ..."
    fi
}

function mergeActualFromOrigin() {
  git fetch 
  git merge origin/$actual
}

function adminRemotes() {
              echo
            echo "Administer remotes:"
            echo "a. Show remotes"
            echo "b. Add remote"
            echo "c. Inspect remote"
            echo
            read -p "Make your choice: " -n 1 -r subreply
            echo

            case $subreply in
                "a")
                   echo $'\nKnown remotes:'
                   git remote -v
                ;;
                "b")
                    echo "What is the adress?"
                    read adress
                    echo "Type an alias for this remote?"
                    read ralias
                    git remote add $ralias $adress
                ;;
                "c")
                    git remote -v
                    echo "Name of the remote to inspect"
                    read rname
                    git remote show $rname
                ;;
            esac

}

function showRepoHisto() {
            git log --pretty=format:'%Cred%h%Creset | %Cgreen%ad%Creset | %s %C(yellow)%d%Creset %C(bold blue)[%an]%Creset %Cgreen(%cr)%Creset' --graph --date=short --all
}

function cloneRemote() {
            echo "Where?"
            . ~/Personal/fl.sh
            pwd
            echo "Remote repository url:"
            read url
            git clone $url
}

function newLocalBranch() {
              echo "Name des neuen Branch?"
            read branchname
            git branch $branchname 
            git checkout $branchname
            read -p "Set upstream? " -n 1 -r
            echo    # (optional) move to a new line
            if [[ $REPLY =~ ^[Yy]$ ]]
                then
                   git push --set-upstream origin $branchname
            fi      
}

function rollBackLast() {
            git reset HEAD~1
            read -p "Override updates in local working dir? " -n 1 -r
            echo    # (optional) move to a new line
            if [[ $REPLY =~ ^[Yy]$ ]]
                then
                    git reset HEAD --hard
            fi      
}

function deleteBranch() {
              git branch
            echo "Welchen Branch löschen?"
            read dbranch
            git branch -d $dbranch
            read -p "Delete remote? " -n 1 -r
            echo    # (optional) move to a new line
            if [[ $REPLY =~ ^[Yy]$ ]]
                then
                   git push origin --delete $dbranch
            fi 
}

function mergeSourceToTarget(){
              git branch --all
            echo "Enter merge target branch"
            read target
            echo "Enter merge source branch"
            read bsource
            git checkout $target
            git merge $bsource
}

function showAllBranches () {
              git branch --all
}

function showBranchHisto(){
              git branch 
            echo "Select branch (hit enter for actual):"
            read bname
            if [[ ! -z "$bname" ]]; then
                  git checkout $bname
            fi
            git log --pretty=format:'%Cred%h%Creset | %Cgreen%ad%Creset | %s %C(yellow)%d%Creset %C(bold blue)[%an]%Creset %Cgreen(%cr)%Creset' --graph --date=short
}

function setUpstream() {
   git push --set-upstream origin $actual
}

function localGitConfig() {
            vim .git/config
}

function globalGitConfig() {
            vim ~/.gitconfig
}

function adminAliases() {
            echo $'\nActual aliases:'
            git config --get-regexp alias
            read -p "Add or delete aliases (a/d)? " -n 1 -r
            echo    # (optional) move to a new line
            if [[ $REPLY =~ ^[a]$ ]]
                then
                    echo "Which command?"
                    read bcommand
                    echo "Define alias:"
                    read calias
                    git config --global alias.$calias $bcommand
                    echo "Alias $calias create for $bcommand!"
                else
                    echo "Which alias to delete:"
                    read calias
                    git config --global --unset alias.$calias
            fi      
}

function gitIgnore() {
            vim .gitignore
}

function undoReset () {
  git reflog --date=iso
  echo "Choose commit to reset:"
  read cname
  if [ -z "$cname" ]; then
    echo "No commit entered!"
  else
    git reset $cname
  fi
}

function interactiveStage () {
   git add -i
}

function changeBranch () {
       git branch --all
       echo "Which branch?"
       read bname
       git checkout $bname
}

function fetachAll () {
       git fetch --all
}

# submenus

function workingDiffs() {
  source $supergithome/diff.sh
  nowaitonexit
}

function atlassiansView() {
  source $supergithome/atlassian.sh
  nowaitonexit
}

function changeProject () {
  source $supergithome/fl.sh
  nowaitonexit
}

function gitExtras () {
  source $supergithome/gitExtras.sh
  nowaitonexit
}

function reset () {
  executeCommand "git reset"
}

function commitAll () {
    executeCommand "git commit -a"
}

function assumeUnchanged () {
    git ls-files
    echo "Which file?"
    read filename
    executeCommand "git update-index --assume-unchanged $filename"
}

function unAssumeUnchanged () {
    git ls-files -v | grep '^[[:lower:]]'
    echo "Which file?"
    read filename
    executeCommand "git update-index --no-assume-unchanged $filename"
}

git fetch --all 2> /dev/null

while ${continuemenu:=true}; do
clear
menuInit "Super GIT Home"
submenuHead "Working with remotes:"
menuPunkt a "Gently push actual" pushActual
menuPunkt c "Merge actual from actual origin" mergeActualFromOrigin
menuPunkt e "Set upstream to actual" setUpstream
menuPunkt f "Administer remotes" adminRemotes
menuPunkt g "Show repository history" showRepoHisto
echo
submenuHead "Working on local branches:"
menuPunkt k "New local branch, checkout" newLocalBranch
menuPunkt n "Delete local branch" deleteBranch
menuPunkt o "Merge from source branch to target branch" mergeSourceToTarget
menuPunkt p "Show all branches (incl. remote)" showAllBranches
menuPunkt r "Show branch history" showBranchHisto
menuPunkt u "Unstage all staged files" reset
menuPunkt x "Commit all changes" commitAll
echo
submenuHead "Navigating commit pointers:"
menuPunkt l "Rollback head to last commit" rollBackLast
menuPunkt m "Undo reset commands" undoReset
echo
submenuHead "Other usefull actions:"
menuPunkt s "Working with diffs" workingDiffs
menuPunkt t "Interactively staging/unstaging files" interactiveStage
menuPunkt w "Atlassian's view" atlassiansView
menuPunkt y "Assume unchanged" assumeUnchanged
menuPunkt z "Unassume unchanged" unAssumeUnchanged
echo
submenuHead "Git admin actions:"
menuPunkt 1 "Show local git config" localGitConfig
menuPunkt 2 "Show global git config" globalGitConfig
menuPunkt 3 "Administering aliases" adminAliases
menuPunkt 4 "Show .gitignore" gitIgnore
menuPunkt 5 "Git extras" gitExtras
echo
submenuHead "Shortcuts"
menuPunkt P "Change project" changeProject
menuPunkt B "Change branch" changeBranch
menuPunkt F "Fetch all" fetachAll
menuPunkt C "Compile favorites" compileMenu
menuPunkt X "Purge cache" purgeCash
echo
showStatus
choice
done
echo "bye, bye, homie!"