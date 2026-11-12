#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
cd ~/tp15
t(){ echo; echo "========== $* =========="; }
helm uninstall whoami -n tp15
kubectl delete ns tp15 tp15-dev tp15-staging tp15-prod --wait=false
# Pour tout libérer : /usr/local/bin/k3s-uninstall.sh
