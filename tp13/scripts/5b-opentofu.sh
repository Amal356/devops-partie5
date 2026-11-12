#!/usr/bin/env bash
# TP13 partie 5b : OpenTofu (binaire officiel, empreinte vérifiée) rejoue le cycle sur une COPIE du projet.
set -euo pipefail
export AWS_PROFILE=floci TF_VAR_api_key="$(cat ~/.tp13-api-key)"
V=1.13.9
SUM=b34b327cc1ef07178207b6f2cd1f5276537d3e5b7be316500f6dac50d4c0a857
if ! command -v tofu >/dev/null; then
  cd /tmp
  curl -fsSL --retry 3 -C - -O "https://github.com/opentofu/opentofu/releases/download/v${V}/tofu_${V}_linux_amd64.tar.gz"
  echo "${SUM}  tofu_${V}_linux_amd64.tar.gz" | sha256sum -c -
  tar xzf "tofu_${V}_linux_amd64.tar.gz" tofu && sudo install -m 0755 tofu /usr/local/bin/tofu && rm -f tofu "tofu_${V}_linux_amd64.tar.gz"
fi
tofu version | head -1
# Copie : state LOCAL (pas de backend.tf) et environnement staging, pour ne pas toucher au state dev de Terraform
rm -rf ~/tp13/tofu-copy && mkdir -p ~/tp13/tofu-copy
cd ~/tp13/terraform-starter && cp -r *.tf *.tfvars modules ~/tp13/tofu-copy/ && rm -f ~/tp13/tofu-copy/backend.tf
cd ~/tp13/tofu-copy
tofu init -input=false -no-color | grep -E "Installed|initialized"
tofu plan -input=false -var-file=staging.tfvars -out tfplan -no-color | grep -E "^Plan:"
tofu apply -input=false -no-color tfplan | grep -E "^Apply complete|^bucket_name|^backups_bucket|^queue_url|^table_name"
aws s3 ls | grep staging
