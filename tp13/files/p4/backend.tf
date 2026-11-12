# TP13 partie 4 : state distant dans Floci (bucket tp13-tfstate créé au bootstrap).
terraform {
  backend "s3" {
    bucket = "tp13-tfstate"
    key    = "envs/dev/terraform.tfstate"
    region = "us-east-1"

    access_key = "test"
    secret_key = "test"

    endpoints = {
      s3 = "http://localhost:4566"
    }
    use_path_style              = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true

    # Verrouillage natif S3 (Terraform >= 1.10) : fichier .tflock à côté du state
    use_lockfile = true
  }
}
