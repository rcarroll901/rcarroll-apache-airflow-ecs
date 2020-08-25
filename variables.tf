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

variable "access_ssh_public_key" {
    description = "public key for accessing bastion"
}

variable "github_ssh_private_key" {
    description = "private key to get access to private github repos"
}

variable "account_id" {
    description = "IAM account ID"
}

variable "database_username" {
    description = "username to log into databases"
}

variable "database_password" {
    description = "password to log into databases"
}

variable "queue_dns" {
    description = "route 53 dns name for queue instance"
}

variable "allowed_ip" { # I want to make this to list of ips later.
    description = " ip addresses that can access vpc. "
    type = string
}