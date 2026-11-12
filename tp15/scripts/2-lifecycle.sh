#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
cd ~/tp15
t(){ echo; echo "========== $* =========="; }
W="--wait --timeout 3m"
t "install (values-dev)"; helm install whoami chart-starter/whoami -n tp15 --create-namespace -f chart-starter/values-dev.yaml $W | head -3
sleep 3; curl -s http://whoami.lab.local | grep -E "Hostname|Name"
t "upgrade replicaCount=3"; helm upgrade whoami chart-starter/whoami -n tp15 -f chart-starter/values-dev.yaml --set replicaCount=3 $W | head -3
t "upgrade image v9.9.9 (inexistante)"; helm upgrade whoami chart-starter/whoami -n tp15 -f chart-starter/values-dev.yaml --set replicaCount=3 --set image.tag=v9.9.9 | head -3
sleep 25; kubectl -n tp15 get pods
clear
t "helm history (après upgrade, échec)"; helm history whoami -n tp15
t "helm rollback whoami 2"; helm rollback whoami 2 -n tp15 --wait
t "helm history : le rollback crée une NOUVELLE révision"; helm history whoami -n tp15
kubectl -n tp15 get pods
