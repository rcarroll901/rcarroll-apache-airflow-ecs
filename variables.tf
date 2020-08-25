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

variable "db_username" {
    description = "username to log into databases"
}

variable "db_password" {
    description = "password to log into databases"
}

variable "queue_dns" {
    description = "route 53 dns name for queue instance"
}

variable "allowed_cidr_blocks" { # I want to make this to list of ips later.
    description = " ip addresses (with "/32" at the end) that can access vpc."
    type = list(string)
}