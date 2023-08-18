#!/bin/sh
supergithome=/Users/d6t6/workspace/bashgitclient
source $supergithome/flexmenu.sh
trackchoices=$1

function switchContext() {
    selectItem "kubectl config get-contexts" "awk '{print \$2}'"
    if [[ $fname == "" ]]; then return 0; fi
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
    if [[ $fname == "" ]]; then return 0; fi
    kubectl get pods $fname -o yaml
}

function describePod() {
    selectItem "kubectl get pods" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    kubectl describe pods $fname
}

function getPodLogs() {
    selectItem "kubectl get pods" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    kubectl logs $fname
}

function logOnPod() {
    selectItem "kubectl get pods" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    kubectl exec -it $fname -- sh
}

function logOnDb(){
   selectItem "kubectl get pods" "awk '{print \$1}'"
   if [[ $fname == "" ]]; then return 0; fi
   echo "DB user name (e.g. testUser)?"
   read userName
   echo "DB name (e.g. testDB)?"
   read dbName
   kubectl exec -it $fname -- psql --host localhost --username $userName -d $dbName
}

function switchNamespace() {
    selectItem "kubectl get ns" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    kubectl config set-context --current --namespace $fname
}

function applyPodManifest() {
    selectItem "grep -r 'kind: Pod' . | cut -d':' -f1" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    cat $fname
    read -p "Apply manifest to Kubernetes (y/n)? " -n 1 -r
    echo    # (optional) move to a new line                    if [[ $REPLY =~ ^[Yy]$ ]]
    if [[ $REPLY =~ ^[Yy]$ ]]
     then
      kubectl apply -f $fname
     fi
}

function deletePod() {
    selectItem "kubectl get pods" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    kubectl delete pod $fname
}

function createNamespace(){
   echo "Namespace name (e.g. frontend)?"
   read nsName
   kubectl create ns $nsName
}

continuemenu=true

while ${continuemenu:=true}; do
clear
menuInit "Super KUBECTL Home"
echo "Current context: $(kubectl config current-context)"
echo "Namespace: $(kubectl config view --minify -o jsonpath='{..namespace}')"
echo
submenuHead "Kubectl Config:"
menuPunktClm a "Show config" "kubectl config view" b "Switch context" switchContext
menuPunktClm c "Switch namespace" switchNamespace d "Add cluster" addCluster 
menuPunktClm e "Add users (token)" addUsers f "Add context" addContext 
menuPunktClm g "Edit config" "vim ~/.kube/config" h "Create namespace" createNamespace  
echo
submenuHead "Pods:"
menuPunktClm j "List pods (ns=default)" "kubectl get pods" k "List pods (all namespaces)" "kubectl get pods --all-namespaces"
menuPunktClm l "Show pod state (desirec/observed)" showPodManifest m "Describe pod" describePod
menuPunktClm n "Get logs" getPodLogs o "Log on to pod" logOnPod
menuPunktClm p "Log on to DB" logOnDb r "Apply pod manifest" applyPodManifest
menuPunkt s "Delete pod" deletePod
echo
choice
done
echo "bye, bye, homie!"
