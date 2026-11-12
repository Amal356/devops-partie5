#!/usr/bin/env bash
# TP13 étape 0 : outils (AWS CLI v2, Terraform) + démarrage de Floci. Idempotent.
set -euo pipefail
cd ~
command -v unzip >/dev/null && command -v jq >/dev/null || sudo apt-get install -y -q unzip jq zip
command -v zip >/dev/null || sudo apt-get install -y -q zip

if ! command -v aws >/dev/null; then
  echo "== AWS CLI v2"
  curl -fsSL --retry 3 -C - "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
  unzip -q -o awscliv2.zip && sudo ./aws/install --update && rm -rf aws awscliv2.zip
fi

if ! command -v terraform >/dev/null; then
  echo "== Terraform (binaire officiel, empreinte vérifiée)"
  V=$(curl -fsSL https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)
  curl -fsSL --retry 3 -O "https://releases.hashicorp.com/terraform/${V}/terraform_${V}_linux_amd64.zip"
  curl -fsSL -O "https://releases.hashicorp.com/terraform/${V}/terraform_${V}_SHA256SUMS"
  grep "terraform_${V}_linux_amd64.zip" "terraform_${V}_SHA256SUMS" | sha256sum -c -
  unzip -q -o "terraform_${V}_linux_amd64.zip" terraform && sudo install -m 0755 terraform /usr/local/bin/terraform
  rm -f terraform "terraform_${V}_linux_amd64.zip" "terraform_${V}_SHA256SUMS"
fi

echo "== Floci"
docker rm -f floci >/dev/null 2>&1 || true
docker run -d --name floci -p 4566:4566 -v /var/run/docker.sock:/var/run/docker.sock floci/floci >/dev/null
for i in $(seq 1 30); do curl -s -o /dev/null localhost:4566 && break; sleep 2; done

echo "== Profil AWS 'floci' (identifiants fictifs)"
aws configure set aws_access_key_id test --profile floci
aws configure set aws_secret_access_key test --profile floci
aws configure set region us-east-1 --profile floci
aws configure set endpoint_url http://localhost:4566 --profile floci
grep -q 'AWS_PROFILE=floci' ~/.bashrc || echo 'export AWS_PROFILE=floci' >> ~/.bashrc

echo; echo "===== VERSIONS ====="
aws --version; terraform version | head -1; node --version; docker ps --filter name=floci --format '{{.Names}} {{.Image}} {{.Status}}'
docker logs floci 2>&1 | tail -3
AWS_PROFILE=floci aws sts get-caller-identity
df -h / | tail -1
