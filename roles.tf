
# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_role" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsJCPipelineTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# TASK ROLE
resource "aws_iam_role" "secret_task_role" {
  name        = "jcPipelineTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role.json
}

data "aws_iam_policy_document" "ecs_secret_policy" {
    version = "2012-10-17"
    statement {
        effect = "Allow"
        actions = [
            "secretsmanager:GetSecretValue",
            "kms:Decrypt"
            ]
        resources = [
            "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${aws_secretsmanager_secret.github_ssh_private_key.name}",
            "arn:aws:kms::${var.account_id}:key/${aws_kms_key.jc_pipeline_key.key_id}"
            ]
    }
}

resource "aws_iam_policy" "ecs_secret_policy" {
    name = "jcPipelineSecretPolicy"
    path = "/"
    description = "Allows access to particular secrets for pipeline execution"
    policy = data.aws_iam_policy_document.ecs_secret_policy.json
}

resource "aws_iam_role_policy_attachment" "secret_task_role" {
  role       = aws_iam_role.secret_task_role.name
  policy_arn = aws_iam_policy.ecs_secret_policy.arn
}