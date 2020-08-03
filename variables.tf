# main creds for AWS connection
variable "aws_access_key_id" {
    description = "AWS access key"
}

variable "aws_secret_access_key" {
    description = "AWS secret access key"
}

variable "region" {
    description = "AWS region to create/manage resources"
}

variable "key_path" {
    description = "file path to public key"
}

variable "github_key_path" {
    description = "file path to private key to get access to private github repos"
}

variable "account_id" {
    description = "IAM account ID"
}