#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
K="kubectl -n tp14"
cd ~/tp14
t(){ echo; echo "========== $* =========="; }
t "metrics-server"; kubectl top nodes; $K top pods
kubectl apply -f k8s-starter/07-hpa.yaml >/dev/null; sleep 20
$K delete pod load --ignore-not-found >/dev/null
$K run load --image=busybox:1.37 --restart=Never -- sh -c 'while true; do wget -qO- http://whoami >/dev/null; done' >/dev/null
$K run load2 --image=busybox:1.37 --restart=Never -- sh -c 'while true; do wget -qO- http://whoami >/dev/null; done' >/dev/null
clear
t "Charge en cours : montée (150 s)"; timeout 150 $K get hpa whoami -w
$K delete pod load load2 --wait=false >/dev/null
t "Charge arrêtée : redescente (120 s)"; timeout 120 $K get hpa whoami -w
$K get deploy whoami
