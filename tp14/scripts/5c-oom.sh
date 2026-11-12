#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
K="kubectl -n tp14"
cd ~/tp14
t(){ echo; echo "========== $* =========="; }
# Pod de démonstration limité à 4Mi qui tente d'allouer 32 Mo (le Deployment whoami n'est pas touché)
cat <<'Y' | kubectl apply -f - >/dev/null
apiVersion: v1
kind: Pod
metadata: { name: oom-demo, namespace: tp14 }
spec:
  restartPolicy: Never
  containers:
    - name: oom
      image: busybox:1.37
      command: ["sh","-c","head -c 32m /dev/zero | tail > /dev/null"]
      resources: { limits: { memory: 4Mi, cpu: 100m } }
Y
sleep 20
t "Pod limité à 4Mi"; $K get pod oom-demo
$K describe pod oom-demo | grep -E "State|Reason|Exit Code|Limits|memory" | head -6
$K delete pod oom-demo --wait=false >/dev/null
