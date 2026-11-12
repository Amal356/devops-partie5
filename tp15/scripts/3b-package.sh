#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
cd ~/tp15
t(){ echo; echo "========== $* =========="; }
mkdir -p ~/tp15/dist && cd ~/tp15/dist
t "helm package (version 0.1.0)"; helm package ../chart-starter/whoami
sed -i 's/^version: 0.1.0/version: 0.1.1/' ../chart-starter/whoami/Chart.yaml
t "version 0.1.0 -> 0.1.1, nouveau package"; helm package ../chart-starter/whoami
ls -l *.tgz
sed -i 's/^version: 0.1.1/version: 0.1.0/' ../chart-starter/whoami/Chart.yaml
t "Challenge 2 : values.schema.json refuse replicaCount: \"trois\""
helm lint ../chart-starter/whoami --set replicaCount=trois 2>&1 | tail -4
