#!/bin/sh
# specify keyfunktionsmap=() array and source this script for flex menu capability
# examplecall: menuPunkt a "Push actual (fetch, merge, commit, push)" pushActual.
rawdatafilename=rawdata.txt
summaryfilename=summary.txt
menuitemsfilename=menugroups.txt
rawdatahome=$supergithome/
configfilename=.sgitconfig
actualmenu=

function coloredLog () { # logentry ; color code
  export GREP_COLOR="$2"
  echo "$1" | grep --color ".*"
  export GREP_COLOR='01;31'
}

function blueLog() {
  log="$1"
  coloredLog "${log}" '1;37;44'
}

function menuInit () {
  touch $rawdatahome$rawdatafilename
  actualmenu="$1"
  menudatamap=()
  export GREP_COLOR='1;37;44'
  echo "$1" | grep --color ".*"
  export GREP_COLOR='01;31'
  echo
}

function submenuHead () {
   actualsubmenuname="$1"
  export GREP_COLOR='1;36'
  echo "$1" | grep --color ".*"
  export GREP_COLOR='01;31'
}

function menuPunkt () {

   menudatamap+=("$1#$2#$3#$actualsubmenuname#$actualmenu")
   echo "$1. $2"

}

function callKeyFunktion () { 
   for i in "${menudatamap[@]}"
     do
       keys=${i:0:1}
         if [ "$1" == "$keys" ]
           then
            method=$(echo "$i" | cut -f3 -d#)
            if [[ $trackchoices == 1 ]]; then
              logCommand "$1"
            fi
            clear
            coloredLog "$method" '1;37;44'
            $method
            return 1
         fi
   done
   return 5
}

function alternateRows() {
   #!/bin/bash
   header="$1"
   i=1
   while read line
    do
      if [[ $i == 1 ]] && [[ $header != "" ]]; then
        echo -e "\e[48;5;93m$line\e[0m"
      else 
        echo -e "\e[48;5;238m$line\e[0m"
      fi
      read line
      echo -e "\e[48;5;232m$line\e[0m"
      i=$((i+1))
    done
    echo -en "\e[0m"
}

function nowaitonexit () {
  waitstatus=false
}

function waitonexit () {
  waitstatus=true
}

function logCommand () {
   for i in "${menudatamap[@]}"
     do
       keys=${i:0:1}
         if [ "$1" == "$keys" ]
           then
            gkommando=$(echo "$i" | cut -f2 -d#)
            submenuname=$(echo "$i" | cut -f4 -d#)
            method=$(echo "$i" | cut -f3 -d#)
            today=$(date)
            echo "$today,$actualmenu,$submenuname,$gkommando,$method" >> $rawdatahome$rawdatafilename
         fi
   done
}

function compileMenu () {
   touch $rawdatahome$summaryfilename
   touch $rawdatahome$menuitemsfilename
   INPUT=$rawdatahome$rawdatafilename
   OLDIFS=$IFS
   IFS=,
   [ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
   while read logdate menu submenu kommando methode
   do
      counta=$(grep -c "$kommando" $rawdatahome$rawdatafilename)
      kommando=$(echo $kommando | sed 's#/#-#g')
      sed -i.bak "/$kommando/d" $rawdatahome$summaryfilename
      echo "$counta,$menu,$submenu,$kommando,$methode" >> $rawdatahome$summaryfilename
      sort -k1 -nr $rawdatahome$summaryfilename -o $rawdatahome$summaryfilename
      counta=$(grep -c "$submenu" $rawdatahome$rawdatafilename)
      kommando=$(echo $submenu | sed 's#/#-#g')
      sed -i.bak "/$submenu/d" $rawdatahome$menuitemsfilename
      echo "$counta,$menu,$submenu" >> $rawdatahome$menuitemsfilename      
      sort -k1 -nr $rawdatahome$menuitemsfilename -o $rawdatahome$menuitemsfilename
   done < $INPUT
   IFS=$OLDIFS
   importantLog "Your sorted summary of command favorites"
   cat $rawdatahome$summaryfilename
   echo
   importantLog "Your sorted summary of menu favorites"
   cat $rawdatahome$menuitemsfilename 
}

function purgeCash () {
  rm $rawdatahome$summaryfilename
  rm $rawdatahome$menuitemsfilename
  rm $rawdatahome$rawdatafilename
}

function importantLog() {
   echo -e -n "\033[1;36m$prompt"
   echo $1
   echo -e -n '\033[0m'
}

function showStatus () {
  importantLog $(pwd | grep -o "[^/]*$")
  actual=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  importantLog $actual 
  git log --decorate --oneline -n 1
  git status | grep "Your branch"
  analyzeWorkingDir
  git remote -v
}

function gentlyCommandNY () {
  
  frage="$1"
  kommando="$2"
  read -p "${frage}" -n 1 -r
  if [[ $REPLY =~ ^[yY]$ ]]
     then
       echo
       executeCommand "$kommando"
     else
      echo 
      echo "Command '$kommando' not executed ..."
  fi      

}


function breakOnNo () {
 read -p "$1" -n 1 -r
 echo
 if [[ $REPLY =~ ^[^Yy]$ ]]; then
   break
 fi
}

function executeCommand () {
 importantLog "Executing: '$1'"
 eval $1
 importantLog "Finished execution of '$1'"
}

function drillDown () {
   while true; do
     read -p "Drill down into file (y/n)? " -n 1 -r
     echo    # (optional) move to a new line                    if [[ $REPLY =~ ^[Yy]$ ]]
     if [[ $REPLY =~ ^[Yy]$ ]]
     then
        echo "Enter filename"
        read fname
        if [ $# -eq 1 ]
          then
            git difftool $1 $fname
        fi
        if [ $# -eq 2 ]
          then
            git difftool $1:$fname $2:$fname
        fi
     else
        break
     fi
   done
}

function selectItem () { # magic function letting user select from list. out: fname(selected item), message(dot-seperated part of number selection, e.g. 18.r -> r is the message)
  listkommando="$1" # list to select from
  regexp="$2" # optional: regexp to grep considered item from selected line item, e.g. 'M foo.bar -> grep foo.bar with "[^ ]*$"
  width="$3" # optional if coloring is desired
  header="$4" # special coloring for header

  blueLog "${listkommando}"

  if [[ $width = "" ]]; then
    eval $listkommando | nl -n 'ln' -s " "
  else 
    eval $listkommando | nl -n 'ln' -s " " | awk -v m=${width} '{printf("[%-'${width}'s]\n", $0)}' | alternateRows $header
  fi
  echo "Select line or nothing to exit:"
  read linenumber
  message=$(echo "${linenumber}" | cut -d '.' -f2) # message = linenumer if no dot-message selected 
  linenumber=$(echo "${linenumber}" | cut -d '.' -f1)
  if [ "$linenumber" = "q" ]; then
    break
  fi
  if [ -z "$linenumber" ]; then
     selected=""
   else
     selected=$(eval "$listkommando" | sed -n ${linenumber}p)
     echo $selected
  fi
  fname=$(echo $selected | grep -oh "${regexp:-.*}" | sed "s/ //g")
  echo "... selected ${fname:-nothing}"
}

function diffDrillDownAdvanced () { # list kommando; regexp to select filename from list command; baseline object name; other object name

  listkommando="$1"
  regexp="$2"

  if $listkommando | grep -q ".*"; then
   while true; do
        
        importantLog "Drill down into file diff: $listkommando"

        selectItem "$listkommando" "$regexp"

        if [[ $fname = "" ]]; then
          break
        fi
        if [ $# -eq 3 ]
          then
             kommando="git difftool $3 -- $fname"
             executeCommand "$kommando"
        fi
        if [ $# -eq 4 ]
          then
             kommando="git difftool $3 $4 -- $fname"
             executeCommand "$kommando"
        fi

#        read -p $'\n<Press any key to return>' -n 1 -r
#        if [ "$REPLY" = "c" ]; then
#           clear
#        fi        

   done

  fi

}

function circulateOnSelectedItem() {
     listkommando=$1
     regexp=$2
     comand=$3
     width=$4
     header=$5
     while true; do
        
        importantLog "Make a selection: $listkommando"

        selectItem "$listkommando" "$regexp" "$4" "$5"

        if [[ $fname = "" ]]; then
          break
        fi

        eval "$comand"

    done
}

function noterminate () { continuemenu=true; }
function terminate () { continuemenu=false; }

function choice () {
  echo
  echo "Press 'q' to quit"
  echo
  read -p "Make your choice: " -n 1 -r
  echo

  if [[ $REPLY == "q" ]]; then
       terminate
  else
    callKeyFunktion $REPLY
    if [[ $? -gt 1 ]]; then
      coloredLog "Huh ($REPLY)?" "1;31"
    fi
    if $waitstatus; then
      read -p $'\n<Press any key to return>' -n 1 -r
    else
      waitonexit # back to default after method execution
    fi
  fi

}

function quit () {
       echo "bye bye, homie!"
       nowaitonexit
       break #2> /dev/null
}

function exitGently () {
       echo "bye bye, homie!"
       nowaitonexit
       exit 1
}

function initConfig () {
   # read config to global arrays
   INPUT=$supergithome/$configfilename
   [ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
   i=0
   configlines=$(cat $INPUT)
   while read configline; do
      if echo "$configline" | grep -q "\[.*\]"; then
        configsection=$(echo "$configline" | grep -o "\[.*\]")
        configsectioname=${configsection:1:${#configsection}-2}
        i=0
        continue
      fi
      if [ -n "$configline" ]; then
         eval "$configsectioname[i]='$configline'"
      fi
      ((i++))
   done <<< "$(echo -e "$configlines")"
}

waitonexit

function selectFromSubdirectories() { #out: selected_subdir(name, not full path)
   dir="$1" #full dir name
   heading="$2"
   coloredLog "${dir}" '1;37;44'
   ! [ "${heading}" = "" ] && coloredLog "${heading}"
   selectItem "ls -F ${dir} | cut -d '/' -f1" ".*" 100
   selected_subdir=$fname
}

function selectFromCsv() { #out: $linenumber(selected of csv file), $headers(of csv file), $fname(selected row values)
   csvfile=$1 #source csv file full name
   linefrom=$2
   lineto=$3
   linefrom=${linefrom:=2}
   lineto=${lineto:=80}
   coloredLog "${csvfile}" '1;37;44'
   headers=$(head -1 $csvfile | sed 's/ /_/g' | awk -F, 'BEGIN {i=1} {while (i<=NF) {str=str substr($i,1,12)","; i++;}} END {print str}')
   selectItem '(echo "${headers}" && sed -n '${linefrom}','${lineto}'p "${csvfile}") | perl -pe "s/((?<=,)|(?<=^)),/ ,/g;" | column -t -s, | less -S' '.*' 192 1
}

function coloredCsvTable() { #show csv file with header line in nice format
   csvfile="$1" #source csv file full name
   linefromXX="$2"
   linetoXX="$3"
   width="$4" # optional if coloring is desired
   heading="$5"
   if [ "${linefromXX}" = "1" ]; then linefromXX="2"; fi
   headers=$(head -1 $csvfile | sed 's/ /_/g' | awk -F, 'BEGIN {i=1} {while (i<=NF) {str=str substr($i,1,12)","; i++;}} END {print str}')
   coloredLog "${csvfile}" '1;37;44'
   ! [ "${heading}" = "" ] && coloredLog ${heading}
   if [ "${width}" = "" ]; then
     (echo "${headers}" && sed -n "${linefromXX},${linetoXX}p" "${csvfile}") | perl -pe 's/((?<=,)|(?<=^)),/ ,/g;' | column -t -s, | less -S | alternateRows 1
   else
     (echo "${headers}" && sed -n "${linefromXX},${linetoXX}p" "${csvfile}") | perl -pe 's/((?<=,)|(?<=^)),/ ,/g;' | column -t -s, | less -S | awk -v m=${width} '{printf("[%-'${width}'s]\n", $0)}' | alternateRows 1
   fi
}
