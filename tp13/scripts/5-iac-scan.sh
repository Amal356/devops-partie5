#!/usr/bin/env bash
# TP13 partie 5a : scan IaC avec Trivy (config), d'abord sur le code sain, puis sur une copie mal configurée.
set -uo pipefail
cd ~/tp13
TRIVY=aquasec/trivy:0.76.2
echo "========== 1. Code du TP (bucket versionné, non public, chiffré) =========="
docker run --rm -v "$PWD/terraform-starter:/tf:ro" $TRIVY config --severity HIGH,CRITICAL --exit-code 1 /tf 2>/dev/null | grep -E "Tests:|Failures:|^│|Report Summary|tf │" ; echo "code retour : ${PIPESTATUS[0]}"

echo; echo "========== 2. Copie avec mauvaise configuration =========="
rm -rf /tmp/tf-mal && mkdir -p /tmp/tf-mal && cp -r terraform-starter/modules /tmp/tf-mal/
cat > /tmp/tf-mal/main.tf <<'TF'
resource "aws_s3_bucket" "public" {
  bucket = "tp13-mauvais"
}
resource "aws_s3_bucket_public_access_block" "public" {
  bucket                  = aws_s3_bucket.public.id
  block_public_acls       = false   # MAUVAIS : ACL publiques autorisées
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
# MAUVAIS : aucun chiffrement ni versioning
TF
docker run --rm -v /tmp/tf-mal:/tf:ro $TRIVY config --severity HIGH,CRITICAL --exit-code 1 /tf 2>/dev/null | grep -E "AVD-|AWS-|HIGH|CRITICAL|Failures:" | head -12; echo "code retour : ${PIPESTATUS[0]}  (1 = bloquant en CI)"
