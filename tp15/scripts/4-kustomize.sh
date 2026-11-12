#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
cd ~/tp15
t(){ echo; echo "========== $* =========="; }
t "Base"; kubectl kustomize kustomize-starter/base | grep -E "kind:|name: whoami-config|part-of"
t "Overlay dev"; kubectl kustomize kustomize-starter/overlays/dev | grep -E "namespace:|name: whoami-config|environment|replicas"
kubectl apply -k kustomize-starter/overlays/dev
kubectl apply -k kustomize-starter/overlays/staging
kubectl apply -k kustomize-starter/overlays/prod
for e in dev staging prod; do kubectl -n tp15-$e rollout status deploy/whoami --timeout=180s >/dev/null; done
clear
t "Trois environnements (dev / staging / prod)"
kubectl get deploy -A -l app.kubernetes.io/part-of=tp15 -o wide
