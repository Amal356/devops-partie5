#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
cd ~/tp15
t(){ echo; echo "========== $* =========="; }
t "Nettoyage du TP14 (libère whoami.lab.local et la RAM)"
kubectl delete ns tp14 --ignore-not-found --wait=false
if ! command -v helm >/dev/null; then
  t "Installation de Helm 3 (script officiel : vérifie l'empreinte SHA256)"
  curl -fsSL -o /tmp/get-helm-3 https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  bash /tmp/get-helm-3 && rm -f /tmp/get-helm-3
fi
helm version --short
t "Partie 1 : chart public podinfo"
helm repo add podinfo https://stefanprodan.github.io/podinfo >/dev/null 2>&1; helm repo update >/dev/null
helm search repo podinfo
helm show chart podinfo/podinfo | grep -E "^(name|version|appVersion)"
helm install demo podinfo/podinfo -n helm-demo --create-namespace --set replicaCount=2 --wait --timeout 5m | head -6
helm list -A
t "helm get values"; helm get values demo -n helm-demo
t "helm get manifest (extrait)"; helm get manifest demo -n helm-demo | grep -E "^kind:|^  name:|replicas:" | head -12
t "Où Helm stocke l'historique ? => dans des Secrets du namespace"
kubectl -n helm-demo get secrets -l owner=helm
helm uninstall demo -n helm-demo; kubectl delete ns helm-demo --wait=false >/dev/null
