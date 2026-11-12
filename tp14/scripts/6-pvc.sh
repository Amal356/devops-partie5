#!/usr/bin/env bash
set -uo pipefail
export KUBECONFIG=$HOME/.kube/config
K="kubectl -n tp14"
cd ~/tp14
t(){ echo; echo "========== $* =========="; }
$K get secret postgres-secret >/dev/null 2>&1 || $K create secret generic postgres-secret --from-literal=password="$(openssl rand -hex 16)"
kubectl apply -f k8s-starter/06-postgres.yaml >/dev/null
$K rollout status deploy/postgres --timeout=300s >/dev/null; $K wait --for=condition=Ready pod -l app=postgres --timeout=120s >/dev/null
clear
t "Écriture dans PostgreSQL"
$K exec deploy/postgres -- psql -U postgres -c "CREATE TABLE IF NOT EXISTS notes(id serial, txt text);" -c "INSERT INTO notes(txt) VALUES ('donnee TP14 '||now());" -c "SELECT * FROM notes;"
OLD=$($K get pod -l app=postgres -o name)
t "Suppression du pod $OLD"; $K delete $OLD
$K wait --for=condition=Ready pod -l app=postgres --timeout=180s >/dev/null
echo "nouveau pod : $($K get pod -l app=postgres -o name)"
t "Lecture après recréation : les données sont toujours là"
$K exec deploy/postgres -- psql -U postgres -c "SELECT * FROM notes;"
t "PV / PVC"; kubectl get pv; $K get pvc
t "Où local-path stocke les données (sur CE nœud)"; sudo ls /var/lib/rancher/k3s/storage/
