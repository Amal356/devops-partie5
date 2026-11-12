#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
K="kubectl -n tp14"
cd ~/tp14
t(){ echo; echo "========== $* =========="; }
t "Rolling update v1.10.0 -> v1.10.1"
$K set image deploy/whoami whoami=traefik/whoami:v1.10.1; $K rollout status deploy/whoami --timeout=120s
t "Image inexistante v9.9.9"
$K set image deploy/whoami whoami=traefik/whoami:v9.9.9; sleep 25
$K get pods -l app=whoami
echo "service toujours servi : $(curl -s -o /dev/null -w '%{http_code}' http://whoami.lab.local)"
t "rollout history"; $K rollout history deploy/whoami
t "rollout undo"; $K rollout undo deploy/whoami; $K rollout status deploy/whoami --timeout=120s
$K get pods -l app=whoami
