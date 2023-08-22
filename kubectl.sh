#!/bin/sh
supergithome=/Users/d6t6/workspace/bashgitclient
source $supergithome/flexmenu.sh
trackchoices=$1

function switchContext() {
    selectItem "kubectl config get-contexts" "awk '{print \$2}'"
    if [[ $fname == "" ]]; then return 0; fi
    executeCommand "kubectl config use-context $fname"
}

function addCluster() {
   echo "Cluster name (e.g. development)?"
   read clusterName
   echo "Cluster address (e.g. https://5.6.7.8)?"
   read clusterAddress
   executeCommand "kubectl config set-cluster $clusterName --server=$clusterAddress --insecure-skip-tls-verify"
}

function addUsers() {
   echo "User name (e.g. admin)?"
   read userName
   echo "Token (e.g. bHVNUkxJZU82d0JudWtpdktBbzhDZFVuSDVEYWtiVmJua3RVT3orUkNzDFGH)?"
   read userToken
   executeCommand "kubectl config set-credentials $userName --token $userToken"
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
   executeCommand "kubectl config set-context $contextName --cluster=$clusterName --namespace=$namspace --user=$userName"
}

function showPodManifest() {
    selectItem "kubectl get pods" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    executeCommand "kubectl get pods $fname -o yaml"
}

function describePod() {
    selectItem "kubectl get pods" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    executeCommand "kubectl describe pods $fname"
}

function showDeploymentManifest() {
    selectItem "kubectl get deployments" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    executeCommand "kubectl get deployment $fname -o yaml"
}

function describeDeployment() {
    selectItem "kubectl get deployments" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    executeCommand "kubectl describe deployment $fname"
}

function showServiceManifest() {
    selectItem "kubectl get svc" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    executeCommand "kubectl get svc $fname -o yaml"
}

function describeService() {
    selectItem "kubectl get svc" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    executeCommand "kubectl describe svc $fname"
}

function describeReplicaset() {
    selectItem "kubectl get rs" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    executeCommand "kubectl describe rs $fname"
}

function getPodLogs() {
    selectItem "kubectl get pods" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    executeCommand "kubectl logs $fname"
}

function logOnPod() {
    selectItem "kubectl get pods" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    executeCommand "kubectl exec -it $fname -- sh"
}

function logOnDb(){
   selectItem "kubectl get pods" "awk '{print \$1}'"
   if [[ $fname == "" ]]; then return 0; fi
   echo "DB user name (e.g. testUser)?"
   read userName
   echo "DB name (e.g. testDB)?"
   read dbName
   executeCommand "kubectl exec -it $fname -- psql --host localhost --username $userName -d $dbName"
}

function switchNamespace() {
    selectItem "kubectl get ns" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    executeCommand "kubectl config set-context --current --namespace $fname"
}

function applyPodManifest() {
    selectItem "grep -r 'kind: Pod' . | cut -d':' -f1" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    cat $fname
    read -p "Apply manifest to Kubernetes (y/n)? " -n 1 -r
    echo    # (optional) move to a new line                    if [[ $REPLY =~ ^[Yy]$ ]]
    if [[ $REPLY =~ ^[Yy]$ ]]
     then
      executeCommand "kubectl apply -f $fname"
     fi
}

function deletePod() {
    selectItem "kubectl get pods" "awk '{print \$1}'"
    if [[ $fname == "" ]]; then return 0; fi
    executeCommand "kubectl delete pod $fname"
}

function createNamespace(){
   echo "Namespace name (e.g. frontend)?"
   read nsName
   executeCommand "kubectl create ns $nsName"
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
menuPunktClm j "List pods (ns=current)" "kubectl get pods -o wide" k "List pods (all namespaces)" "kubectl get pods --all-namespaces -o wide"
menuPunktClm l "Show pod manifest (desired/observed)" showPodManifest m "Describe pod" describePod
menuPunktClm n "Get logs" getPodLogs o "Log on to pod" logOnPod
menuPunktClm p "Log on to DB" logOnDb r "Apply pod manifest" applyPodManifest
menuPunkt s "Delete pod" deletePod
echo
submenuHead "Deployments:"
menuPunktClm v "List deployments (ns=current)" "kubectl get deployments -o wide" w "List deployments (all namespaces)" "kubectl get deployments --all-namespaces -o wide"
menuPunktClm x "Show deployment manifest (desired/observed)" showDeploymentManifest y "Describe deployment" describeDeployment
menuPunktClm z "List replicasets (ns=current)" "kubectl get rs" 1 "Describe replica set" describeReplicaset
echo
submenuHead "Services:"
menuPunktClm 5 "List services (ns=current)" "kubectl get services -o wide" 6 "List services (all namespaces)" "kubectl get services --all-namespaces -o wide"
menuPunktClm 7 "Show service manifest (desired/observed)" showServiceManifest 8 "Describe service" describeService
choice
done
echo "bye, bye, homie!"
