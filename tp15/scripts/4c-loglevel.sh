#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
cd ~/tp15
t(){ echo; echo "========== $* =========="; }
t "Avant : ConfigMap et pods de dev"
kubectl -n tp15-dev get cm,pods -l app.kubernetes.io/part-of=tp15
sed -i 's/LOG_LEVEL=debug/LOG_LEVEL=trace/' kustomize-starter/overlays/dev/kustomization.yaml
kubectl apply -k kustomize-starter/overlays/dev
kubectl -n tp15-dev rollout status deploy/whoami --timeout=120s
t "Après LOG_LEVEL=trace : nouveau hash => nouveau pod automatiquement"
kubectl -n tp15-dev get cm,pods -l app.kubernetes.io/part-of=tp15
sed -i 's/LOG_LEVEL=trace/LOG_LEVEL=debug/' kustomize-starter/overlays/dev/kustomization.yaml
