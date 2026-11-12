#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
cd ~/tp15
t(){ echo; echo "========== $* =========="; }
clear
t "helm lint"; helm lint chart-starter/whoami
t "helm template (extrait, ingress activé)"
helm template test chart-starter/whoami --set ingress.enabled=true | grep -vE "^\s*$" | sed -n '/kind: Deployment/,/livenessProbe/p' | head -40
t "helm install --dry-run=server"
helm install test chart-starter/whoami --dry-run=server -n tp15 --create-namespace | head -8
