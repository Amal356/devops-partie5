#!/usr/bin/env bash
# TP13 partie 3 : cycle Terraform complet contre Floci, puis vérification avec AWS CLI.
set -euo pipefail
export AWS_PROFILE=floci
cd ~/tp13/terraform-starter
# Valeur du secret générée au vol : jamais dans le code ni dans un .tfvars versionné
[ -f ~/.tp13-api-key ] || (umask 077; openssl rand -hex 16 > ~/.tp13-api-key)   # hors du dépôt, lisible par moi seule
export TF_VAR_api_key="$(cat ~/.tp13-api-key)"
terraform init -input=false >/dev/null && echo "terraform init : OK"
terraform fmt -recursive && terraform validate
terraform plan -input=false -out tfplan | tail -3
echo; echo "========== terraform apply =========="
terraform apply -input=false tfplan | tail -4
echo; echo "========== terraform output =========="
terraform output
echo; echo "========== Vérification avec AWS CLI =========="
aws s3api get-bucket-versioning --bucket tp13-uploads-dev
aws s3api get-bucket-encryption --bucket tp13-uploads-dev --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault' 2>/dev/null || true
aws sqs list-queues --query QueueUrls --output text
aws dynamodb list-tables --query TableNames --output text
