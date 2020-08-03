resource "aws_secretsmanager_secret" "github_ssh_private_key" {
    name = "jc_pipeline_github_ssh_private_key"
}

resource "aws_secretsmanager_secret_version" "github_ssh_private_key" {
  secret_id     = aws_secretsmanager_secret.github_ssh_private_key.id
  secret_string = file(var.github_key_path)
}

resource "aws_kms_key" "jc_pipeline_key" {
    description = "KMS key for AWS Secrets Manager"
    key_usage = "ENCRYPT_DECRYPT"
    
}