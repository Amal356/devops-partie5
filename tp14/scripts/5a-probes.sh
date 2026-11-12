#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
K="kubectl -n tp14"
cd ~/tp14
t(){ echo; echo "========== $* =========="; }
P=$($K get pod -l app=whoami -o jsonpath='{.items[0].metadata.name}')
$K port-forward pod/$P 18081:8080 >/dev/null 2>&1 & PF=$!; sleep 3
clear
t "Panne simulée sur $P : /health renvoie 500"
curl -s -X POST -d '500' localhost:18081/health; echo "code /health : $(curl -s -o /dev/null -w '%{http_code}' localhost:18081/health)"
kill $PF 2>/dev/null
t "kubectl get pods -w (40 s) : READY 0/1 puis RESTARTS +1"
timeout 40 $K get pods -l app=whoami -w
t "Événements du pod"
$K describe pod $P | grep -E "Unhealthy|Killing|Restart Count" | tail -4
