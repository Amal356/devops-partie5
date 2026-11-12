#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
K="kubectl -n tp14"
cd ~/tp14
t(){ echo; echo "========== $* =========="; }
kubectl delete ns tp14 --wait=true
# Pour libérer totalement la VM après le TP15 : /usr/local/bin/k3s-uninstall.sh
