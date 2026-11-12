# TP13 partie 4 : le bucket sécurisé est désormais un module, appelé deux fois.

module "uploads" {
  source = "./modules/secure-bucket"
  name   = "tp13-uploads-${var.environment}"
}

module "backups" {
  source = "./modules/secure-bucket"
  name   = "tp13-backups-${var.environment}"
}

# Blocs moved : les ressources existantes changent d'adresse dans le state SANS être détruites/recréées
moved {
  from = aws_s3_bucket.uploads
  to   = module.uploads.aws_s3_bucket.this
}
moved {
  from = aws_s3_bucket_versioning.uploads
  to   = module.uploads.aws_s3_bucket_versioning.this
}
moved {
  from = aws_s3_bucket_public_access_block.uploads
  to   = module.uploads.aws_s3_bucket_public_access_block.this
}
moved {
  from = aws_s3_bucket_server_side_encryption_configuration.uploads
  to   = module.uploads.aws_s3_bucket_server_side_encryption_configuration.this
}

# File de lettres mortes : reçoit les messages qui échouent 3 fois
resource "aws_sqs_queue" "contact_dlq" {
  name                      = "tp13-contact-${var.environment}-dlq"
  message_retention_seconds = 1209600 # 14 jours
}

resource "aws_sqs_queue" "contact" {
  name = "tp13-contact-${var.environment}"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.contact_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_dynamodb_table" "visits" {
  name         = "tp13-visits-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_secretsmanager_secret" "api_key" {
  name                    = "tp13/${var.environment}/api-key"
  recovery_window_in_days = 0 # suppression immédiate au destroy (lab)
}

resource "aws_secretsmanager_secret_version" "api_key" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = var.api_key # variable sensitive : jamais affichée dans plan/apply
}
