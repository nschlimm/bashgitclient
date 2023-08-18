#!/bin/sh
supergithome=/Users/d6t6/workspace/bashgitclient
source $supergithome/flexmenu.sh
trackchoices=$1

function switchContext() {
    selectItem "kubectl config get-contexts" "awk '{print \$2}'"
    if [[ $fname == *"nothing"* ]]; then return 0; fi
    kubectl config use-context $fname
}

function addCluster() {
   echo "Cluster name (e.g. development)?"
   read clusterName
   echo "Cluster address (e.g. https://5.6.7.8)?"
   read clusterAddress
   kubectl config set-cluster $clusterName --server=$clusterAddress --insecure-skip-tls-verify
}

function addUsers() {
   echo "User name (e.g. admin)?"
   read userName
   echo "Token (e.g. bHVNUkxJZU82d0JudWtpdktBbzhDZFVuSDVEYWtiVmJua3RVT3orUkNzDFGH)?"
   read userToken
   kubectl config set-credentials $userName --token $userToken
}

function addContext() {
   echo "Context name (e.g. development-pennyworth)?"
   read contextName
   echo "Cluster name (e.g. development)?"
   read clusterName
   echo "Namespace (e.g. default)?"
   read namspace
   echo "User (e.g. admin)?"
   read userName
   kubectl config set-context $contextName --cluster=$clusterName --namespace=$namspace --user=$userName
}

function showPodManifest() {
    selectItem "kubectl get pods" "awk '{print \$1}'"
    if [[ $fname == *"nothing"* ]]; then return 0; fi
    kubectl get pods $fname -o yaml
}

function describePod() {
    selectItem "kubectl get pods" "awk '{print \$1}'"
    if [[ $fname == *"nothing"* ]]; then return 0; fi
    kubectl describe pods $fname
}

function getPodLogs() {
    selectItem "kubectl get pods" "awk '{print \$1}'"
    if [[ $fname == *"nothing"* ]]; then return 0; fi
    kubectl logs $fname
}

continuemenu=true

while ${continuemenu:=true}; do
clear
menuInit "Super GIT Home"
echo "Current context: $(kubectl config current-context)"
echo
submenuHead "Kubectl Config:"
menuPunktClm a "Show config" "kubectl config view" b "Switch context" switchContext
menuPunktClm c "Add cluster" addCluster d "Add users (token)" addUsers
menuPunktClm e "Add context" addContext 
echo
submenuHead "Pods:"
menuPunktClm f "List pods (ns=default)" "kubectl get pods" g "List pods (all namespaces)" "kubectl get pods --all-namespaces"
menuPunktClm h "Show pod manifest" showPodManifest i "Describe pod" describePod
menuPunktClm j "Get logs" getPodLogs
echo
choice
done
echo "bye, bye, homie!"
