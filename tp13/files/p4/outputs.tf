output "bucket_name" {
  description = "Nom du bucket S3 des uploads"
  value       = module.uploads.bucket
}

output "backups_bucket" {
  description = "Nom du bucket S3 des sauvegardes"
  value       = module.backups.bucket
}

output "queue_url" {
  description = "URL de la file SQS"
  value       = aws_sqs_queue.contact.url
}

output "table_name" {
  description = "Nom de la table DynamoDB"
  value       = aws_dynamodb_table.visits.name
}
