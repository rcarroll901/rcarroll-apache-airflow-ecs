resource "aws_ecs_cluster" "jc_pipeline" {
    name = "jc-pipeline"
}



# WEBSERVER
resource "aws_ecs_task_definition" "webserver" {
    family                = "webserver"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn = aws_iam_role.jc_ecs_task_execution_role.arn
    container_definitions = data.template_file.webserver.rendered
}

data  "template_file" "webserver" {
    template = file("templates/container_def.json")

    vars = {
        name = "webserver"
        account_id = var.account_id
        private_key_arn = aws_secretsmanager_secret.github_ssh_private_key.arn
        port1 = 8080
        queue_ip = "jc.pipeline.queue"
    }
}

resource "aws_ecs_service" "webserver" {
  	name            = "webserver"
  	cluster         = aws_ecs_cluster.jc_pipeline.id
  	task_definition = aws_ecs_task_definition.webserver.family
  	desired_count   = 1

    network_configuration {
        subnets = [aws_subnet.public.id]
        security_groups = [
            aws_security_group.ssh-from-bastion.id,
            aws_security_group.webserver.id,
            aws_security_group.worker-user.id,
            aws_security_group.queue-user.id,
            aws_security_group.flower-user.id,
            aws_security_group.airflow-db-user.id
        ]
    }
}



# SCHEDULER
resource "aws_ecs_task_definition" "scheduler" {
    family                = "scheduler"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn = aws_iam_role.jc_ecs_task_execution_role.arn
    container_definitions = data.template_file.scheduler.rendered
}

data  "template_file" "scheduler" {
    template = file("templates/container_def.json")

    vars = {
        name = "scheduler"
        account_id = var.account_id
        private_key_arn = ""
        queue_ip = "jc.pipeline.queue"
    }
}

resource "aws_ecs_service" "scheduler" {
  	name            = "scheduler"
  	cluster         = aws_ecs_cluster.jc_pipeline.id
  	task_definition = aws_ecs_task_definition.scheduler.family
  	desired_count   = 1
    
    network_configuration {
        subnets = [aws_subnet.private.id]
        security_groups = [
            aws_security_group.ssh-from-bastion.id,
            aws_security_group.queue-user.id,
            aws_security_group.flower-user.id,
            aws_security_group.airflow-db-user.id
        ]
    }
}



# WORKER
resource "aws_ecs_task_definition" "worker" {
    family                = "worker"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn = aws_iam_role.jc_ecs_task_execution_role.arn
    container_definitions = data.template_file.worker.rendered
}

data  "template_file" "worker" {
    template = file("templates/container_def.json")

    vars = {
        name = "worker"
        account_id = var.account_id
        private_key_arn = aws_secretsmanager_secret.github_ssh_private_key.arn
        queue_ip = "jc.pipeline.queue"
    }
}

resource "aws_ecs_service" "worker" {
  	name            = "worker"
  	cluster         = aws_ecs_cluster.jc_pipeline.id
  	task_definition = aws_ecs_task_definition.worker.family
  	desired_count   = 3

    network_configuration {
        subnets = [aws_subnet.private.id]
        security_groups = [
            aws_security_group.ssh-from-bastion.id,
            aws_security_group.worker.id,
            aws_security_group.queue-user.id,
            aws_security_group.flower-user.id,
            aws_security_group.airflow-db-user.id
        ]
    }
}



# FLOWER
resource "aws_ecs_task_definition" "flower" {
    family                = "flower"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn = aws_iam_role.jc_ecs_task_execution_role.arn
    container_definitions = data.template_file.flower.rendered
}

data  "template_file" "flower" {
    template = file("templates/container_def.json")

    vars = {
        name = "flower"
        account_id = var.account_id
        private_key_arn = aws_secretsmanager_secret.github_ssh_private_key.arn
        queue_ip = "jc.pipeline.queue"
    }
}

resource "aws_ecs_service" "flower" {
  	name            = "flower"
  	cluster         = aws_ecs_cluster.jc_pipeline.id
  	task_definition = aws_ecs_task_definition.flower.family
  	desired_count   = 1

    network_configuration {
        subnets = [aws_subnet.public.id]
        security_groups = [
            aws_security_group.ssh-from-bastion.id,
            aws_security_group.flower.id,
            aws_security_group.queue-user.id,
        ]
    }
}



# RABBITMQ
resource "aws_ecs_task_definition" "queue" {
    family                = "rabbitmq"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn = aws_iam_role.jc_ecs_task_execution_role.arn
    container_definitions = <<DEFINITION
[
  {
    "name": "rabbitmq",
    "image": "rabbitmq:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 5672,
        "hostPort": 5672
      }
    ],
    "memory": 500,
    "cpu": 2
  }
]
DEFINITION
}

resource "aws_ecs_service" "queue" {
  	name            = "queue"
  	cluster         = aws_ecs_cluster.jc_pipeline.id
  	task_definition = aws_ecs_task_definition.queue.family
  	desired_count   = 1

    service_registries {
        registry_arn = aws_service_discovery_service.queue.arn
    }

    network_configuration {
        subnets = [aws_subnet.private.id]
        security_groups = [
            aws_security_group.ssh-from-bastion.id,
            aws_security_group.queue.id
        ]
    }
}