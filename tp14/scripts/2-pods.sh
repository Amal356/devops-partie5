#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
K="kubectl -n tp14"
cd ~/tp14
t(){ echo; echo "========== $* =========="; }
t "Pod nu : supprimé => PAS recréé (aucun contrôleur ne le surveille)"
kubectl run test --image=traefik/whoami:v1.10.0 >/dev/null
kubectl wait --for=condition=Ready pod/test --timeout=120s >/dev/null; kubectl get pods -o wide
kubectl delete pod test --wait=true >/dev/null; sleep 3; echo "après delete :"; kubectl get pods 2>&1
t "Namespace, ConfigMap, Secret (hors Git), Deployment"
kubectl apply -f k8s-starter/01-namespace.yaml -f k8s-starter/02-config.yaml
$K create secret generic whoami-secret --from-literal=api-key='lab-only-value' --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f k8s-starter/03-deployment.yaml
$K rollout status deploy/whoami --timeout=180s
$K get deploy,rs,pods -o wide
t "Suppression d'un pod du Deployment => recréé par le ReplicaSet"
P=$($K get pod -l app=whoami -o name | head -1); $K delete $P --wait=false; sleep 6
$K get pods -o wide
t "exec dans whoami (image scratch, pas de shell)"
$K exec deploy/whoami -- sh 2>&1 | tail -2
t "kubectl explain deployment.spec.strategy"; kubectl explain deployment.spec.strategy | sed -n '1,12p'
