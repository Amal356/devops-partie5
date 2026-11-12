#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
cd ~/tp15
t(){ echo; echo "========== $* =========="; }
clear
t "upgrade v9.9.9 avec --atomic --timeout 60s"
time helm upgrade whoami chart-starter/whoami -n tp15 -f chart-starter/values-dev.yaml --set replicaCount=3 --set image.tag=v9.9.9 --atomic --timeout 60s 2>&1 | tail -3
t "helm history"; helm history whoami -n tp15
kubectl -n tp15 get pods
