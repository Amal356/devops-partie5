#!/usr/bin/env bash
# TP13 partie 4d : une clé de state par environnement (prod), puis retour à dev.
set -euo pipefail
export AWS_PROFILE=floci TF_VAR_api_key="$(cat ~/.tp13-api-key)"
cd ~/tp13/terraform-starter
terraform init -input=false -reconfigure -backend-config="key=envs/prod/terraform.tfstate" >/dev/null
echo "========== plan prod (state séparé envs/prod/) =========="
terraform plan -input=false -var-file=prod.tfvars -no-color | grep -E "^Plan:"
terraform init -input=false -reconfigure >/dev/null && echo "retour au state envs/dev/"
aws s3 ls s3://tp13-tfstate/ --recursive
