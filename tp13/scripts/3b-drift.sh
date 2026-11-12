#!/usr/bin/env bash
# TP13 partie 3 : dérive (drift) — suppression manuelle de la table puis terraform plan.
set -euo pipefail
export AWS_PROFILE=floci
cd ~/tp13/terraform-starter
export TF_VAR_api_key="$(cat ~/.tp13-api-key)"
echo "========== aws dynamodb delete-table (hors Terraform) =========="
aws dynamodb delete-table --table-name tp13-visits-dev --query TableDescription.TableName --output text
echo; echo "========== terraform plan =========="
terraform plan -input=false -no-color 2>&1 | grep -E "^ *# |^Plan:|will be created|has been deleted|Objects have changed" || true
