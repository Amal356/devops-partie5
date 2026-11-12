#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
K="kubectl -n tp14"
cd ~/tp14
t(){ echo; echo "========== $* =========="; }
kubectl apply -f k8s-starter/04-service.yaml >/dev/null
t "Service et EndpointSlices"; $K get svc,endpointslices
t "port-forward : la requête tombe sur des pods différents"
$K port-forward svc/whoami 18080:80 >/dev/null 2>&1 & PF=$!; sleep 3
for i in 1 2 3 4; do curl -s localhost:18080 | grep Hostname; done; kill $PF
t "DNS interne"
$K run tmp --rm -i --image=busybox:1.37 --restart=Never -- wget -qO- http://whoami.tp14.svc.cluster.local 2>/dev/null | grep -E "Hostname|Host:"
kubectl apply -f k8s-starter/05-ingress.yaml >/dev/null
$K rollout status deploy/nginx --timeout=120s >/dev/null; sleep 5
clear
t "Ingress"; $K get ingress
t "curl http://whoami.lab.local"; curl -s http://whoami.lab.local | grep -E "Hostname|Host:|X-Forwarded-Host"
t "curl http://whoami.lab.local/api  (nginx)"; curl -s http://whoami.lab.local/api | grep -i "<title>"
