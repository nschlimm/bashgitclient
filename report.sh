#!/bin/bash

yaml_output='
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  annotations:
    deployment.kubernetes.io/desired-replicas: "1"
    deployment.kubernetes.io/max-replicas: "2"
    deployment.kubernetes.io/revision: "6"
    meta.helm.sh/release-name: pennyworth
    meta.helm.sh/release-namespace: sls-pennyworth
  creationTimestamp: "2024-01-19T14:37:29Z"
  generation: 2
  labels:
    app: pennyworth
    pod-template-hash: 5d5ffd6c57
    timocom.io/net-allow-egress-database: "true"
    timocom.io/net-allow-egress-external: "true"
---
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  annotations:
    deployment.kubernetes.io/desired-replicas: "1"
    deployment.kubernetes.io/max-replicas: "2"
    deployment.kubernetes.io/revision: "7"
    meta.helm.sh/release-name: pennyworth
    meta.helm.sh/release-namespace: sls-pennyworth
  creationTimestamp: "2024-02-27T13:52:15Z"
  generation: 1
  labels:
    app: pennyworth
    pod-template-hash: "755554886"
    timocom.io/net-allow-egress-database: "true"
    timocom.io/net-allow-egress-external: "true"
'

# Extract app and generation fields and format into a table
echo -e "App\tGeneration"
echo "$yaml_output" | awk '/app:/ {app=$2} /generation:/ {generation=$2} /^---/ {if (app != "" && generation != "") print app "\t" generation; app=""; generation="";}' | column -t
