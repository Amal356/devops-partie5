#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
K="kubectl -n tp14"
cd ~/tp14
t(){ echo; echo "========== $* =========="; }
# Plan B : K3s mono-nœud directement sur la VM de lab (RAM insuffisante pour 2 VM imbriquées)
V=v1.34.12+k3s1
if sudo ss -ltnp | grep -qE ':(80|443) '; then echo "⚠️ ports 80/443 déjà pris :"; sudo ss -ltnp | grep -E ':(80|443) '; exit 1; fi
t "Installation K3s $V"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$V sh -s - server --write-kubeconfig-mode 600 2>&1 | tail -3
mkdir -p ~/.kube && sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config && chmod 600 ~/.kube/config
grep -q KUBECONFIG ~/.bashrc || echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
grep -q whoami.lab.local /etc/hosts || echo "127.0.0.1 whoami.lab.local" | sudo tee -a /etc/hosts >/dev/null
echo "attente des composants système..."
until kubectl -n kube-system get deploy traefik >/dev/null 2>&1; do sleep 5; done
kubectl -n kube-system wait --for=condition=Available deploy --all --timeout=300s >/dev/null
clear
t "kubectl get nodes -o wide"; kubectl get nodes -o wide
t "kubectl get pods -A"; kubectl get pods -A
