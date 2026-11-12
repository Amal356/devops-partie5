#!/usr/bin/env bash
# TP13 partie 4b : bootstrap du bucket de state, puis migration du state local vers S3 (Floci).
set -euo pipefail
export AWS_PROFILE=floci
cd ~/tp13/terraform-starter
echo "========== bootstrap : bucket tp13-tfstate versionné =========="
aws s3 mb s3://tp13-tfstate 2>/dev/null || echo "(bucket déjà présent)"
aws s3api put-bucket-versioning --bucket tp13-tfstate --versioning-configuration Status=Enabled
aws s3api get-bucket-versioning --bucket tp13-tfstate --query Status --output text
cp ~/tp13/backend.tf ./backend.tf && rm -f backend.tf.example
echo; echo "========== terraform init -migrate-state =========="
terraform init -input=false -migrate-state -force-copy -no-color | grep -E "Successfully|backend|copy" || true
echo; echo "========== state dans s3://tp13-tfstate/envs/dev/ =========="
aws s3 ls s3://tp13-tfstate/envs/dev/
ls terraform.tfstate 2>/dev/null && echo "(state local résiduel)" || echo "plus de state local actif : il est dans S3"
