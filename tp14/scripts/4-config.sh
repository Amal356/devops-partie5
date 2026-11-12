#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
K="kubectl -n tp14"
cd ~/tp14
t(){ echo; echo "========== $* =========="; }
$K port-forward svc/whoami 18080:80 >/dev/null 2>&1 & PF=$!; sleep 3
envs(){ curl -s "localhost:18080/?env=true" | grep -E "^(APP_|API_KEY)" ; }
t "Secret : simple base64, PAS du chiffrement"
$K get secret whoami-secret -o jsonpath='{.data.api-key}'; echo
$K get secret whoami-secret -o jsonpath='{.data.api-key}' | base64 -d; echo
t "Variables injectées (envFrom ConfigMap + secretKeyRef)"; envs
$K patch configmap whoami-config -p '{"data":{"APP_COLOR":"green"}}' >/dev/null
t "ConfigMap modifiée (APP_COLOR=green) : pods existants ?"; envs
kill $PF; $K rollout restart deploy/whoami >/dev/null; $K rollout status deploy/whoami --timeout=120s >/dev/null
$K port-forward svc/whoami 18080:80 >/dev/null 2>&1 & PF=$!; sleep 3
t "Après kubectl rollout restart"; envs; kill $PF
