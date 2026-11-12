#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
cd ~/tp15
t(){ echo; echo "========== $* =========="; }
clear
t "diff staging / prod"
diff <(kubectl kustomize kustomize-starter/overlays/staging) <(kubectl kustomize kustomize-starter/overlays/prod)
