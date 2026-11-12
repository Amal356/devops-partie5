#!/usr/bin/env bash
# TP13 partie 4a : module secure-bucket (blocs moved) + validation + fichiers .tfvars.
set -euo pipefail
export AWS_PROFILE=floci TF_VAR_api_key="$(cat ~/.tp13-api-key)"
cd ~/tp13/terraform-starter
terraform init -input=false >/dev/null && terraform fmt -recursive && terraform validate
echo; echo "========== validation : environment=test doit être refusé =========="
terraform plan -input=false -var environment=test 2>&1 | grep -E "Invalid value|dev, staging ou prod" | head -2 || true
echo; echo "========== plan avec dev.tfvars : déplacements (moved), AUCUNE destruction =========="
terraform plan -input=false -var-file=dev.tfvars -out tfplan -no-color | grep -E "has moved to|will be created|will be destroyed|^Plan:" || true
terraform apply -input=false tfplan -no-color | grep -E "^Apply complete" 
terraform state list
