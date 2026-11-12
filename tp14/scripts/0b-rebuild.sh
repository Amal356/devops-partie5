#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
K="kubectl -n tp14"
cd ~/tp14
t(){ echo; echo "========== $* =========="; }
# Reconstruction complète du cluster (équivalent plan B de vagrant destroy -f && vagrant up)
V=v1.34.12+k3s1
START=$(date +%s)
t "Désinstallation"; /usr/local/bin/k3s-uninstall.sh >/dev/null 2>&1; echo "k3s supprimé : $(command -v k3s || echo OK)"
t "Réinstallation $V"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$V sh -s - server --write-kubeconfig-mode 600 2>&1 | tail -1
sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config && chmod 600 ~/.kube/config
until kubectl -n kube-system get deploy traefik >/dev/null 2>&1; do sleep 5; done
kubectl -n kube-system wait --for=condition=Available deploy --all --timeout=300s >/dev/null
kubectl get nodes -o wide
echo; echo "⏱️  Cluster reconstruit en $(( $(date +%s) - START )) secondes"
