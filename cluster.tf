resource "aws_ecs_cluster" "jc_pipeline" {
    name = "jc-pipeline"
}



# WEBSERVER
resource "aws_ecs_task_definition" "webserver" {
    family                = "webserver"
    requires_compatibilities = ["FARGATE"]
    cpu = 512
    memory = 1024
    task_role_arn = aws_iam_role.secret_task_role.arn
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    container_definitions = data.template_file.webserver.rendered
    network_mode = "awsvpc"
}

data  "template_file" "webserver" {
    template = file("templates/container_def.json")

    vars = {
        name = "webserver"
        account_id = var.account_id
        private_key_arn = aws_secretsmanager_secret.github_ssh_private_key.arn
        queue_ip = var.queue_dns
        db_name = aws_rds_cluster.airflow-meta-db.database_name
        postgres_host = aws_rds_cluster.airflow-meta-db.endpoint
        db_user = var.database_username
        db_password = var.database_password
        cpu = 512
        memory = 1024
    }
}

resource "aws_ecs_service" "webserver" {
  	name            = "webserver"
  	cluster         = aws_ecs_cluster.jc_pipeline.id
  	task_definition = aws_ecs_task_definition.webserver.family
    launch_type = "FARGATE"
  	desired_count   = 1
    depends_on = [aws_alb_target_group.webserver-group]

    network_configuration {
        subnets = [aws_subnet.public.id]
        security_groups = [
            aws_security_group.ssh-from-bastion.id,
            aws_security_group.webserver.id,
            aws_security_group.queue-user.id,
            aws_security_group.flower-user.id,
            aws_security_group.airflow-db-user.id
        ]
        assign_public_ip = true
    }

    load_balancer {
    	target_group_arn  = aws_alb_target_group.webserver-group.arn
    	container_port    = 8080
    	container_name    = "webserver"
	}

}



# SCHEDULER
resource "aws_ecs_task_definition" "scheduler" {
    family                = "scheduler"
    requires_compatibilities = ["FARGATE"]
    cpu = 512
    memory = 2048
    task_role_arn = aws_iam_role.secret_task_role.arn
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    container_definitions = data.template_file.scheduler.rendered
    network_mode = "awsvpc"
}

data  "template_file" "scheduler" {
    template = file("templates/container_def.json")

    vars = {
        name = "scheduler"
        account_id = var.account_id
        private_key_arn = ""
        queue_ip = var.queue_dns
        db_name = aws_rds_cluster.airflow-meta-db.database_name
        postgres_host = aws_rds_cluster.airflow-meta-db.endpoint
        db_user = var.database_username
        db_password = var.database_password
        cpu = 512
        memory = 2048
    }
}

resource "aws_ecs_service" "scheduler" {
  	name            = "scheduler"
  	cluster         = aws_ecs_cluster.jc_pipeline.id
  	task_definition = aws_ecs_task_definition.scheduler.family
    launch_type = "FARGATE"
  	desired_count   = 1
    
    network_configuration {
        subnets = [aws_subnet.private.id]
        security_groups = [
            aws_security_group.ssh-from-bastion.id,
            aws_security_group.queue-user.id,
            aws_security_group.flower-user.id,
            aws_security_group.airflow-db-user.id,
            aws_security_group.internet-user.id
        ]
    }
}



# WORKER
resource "aws_ecs_task_definition" "worker" {
    family                = "worker"
    requires_compatibilities = ["FARGATE"]
    cpu = 1024
    memory = 3072
    task_role_arn = aws_iam_role.secret_task_role.arn
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    container_definitions = data.template_file.worker.rendered
    network_mode = "awsvpc"
}

data  "template_file" "worker" {
    template = file("templates/container_def.json")

    vars = {
        name = "worker"
        account_id = var.account_id
        private_key_arn = aws_secretsmanager_secret.github_ssh_private_key.arn
        queue_ip = var.queue_dns
        db_name = aws_rds_cluster.airflow-meta-db.database_name
        postgres_host = aws_rds_cluster.airflow-meta-db.endpoint
        db_user = var.database_username
        db_password = var.database_password
        cpu = 1024
        memory = 3072
    }
}

resource "aws_ecs_service" "worker" {
  	name            = "worker"
  	cluster         = aws_ecs_cluster.jc_pipeline.id
  	task_definition = aws_ecs_task_definition.worker.family
    launch_type = "FARGATE"
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
    cpu = 256
    memory = 512
    task_role_arn = aws_iam_role.secret_task_role.arn
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    container_definitions = data.template_file.flower.rendered
    network_mode = "awsvpc"
}

data  "template_file" "flower" {
    template = file("templates/container_def.json")

    vars = {
        name = "flower"
        account_id = var.account_id
        private_key_arn = ""
        queue_ip = var.queue_dns
        db_name = aws_rds_cluster.airflow-meta-db.database_name
        postgres_host = aws_rds_cluster.airflow-meta-db.endpoint
        db_user = var.database_username
        db_password = var.database_password
        cpu = 256
        memory = 512
    }
}

resource "aws_ecs_service" "flower" {
  	name            = "flower"
  	cluster         = aws_ecs_cluster.jc_pipeline.id
  	task_definition = aws_ecs_task_definition.flower.family
    launch_type = "FARGATE"
  	desired_count   = 1

    network_configuration {
        subnets = [aws_subnet.public.id]
        security_groups = [
            aws_security_group.ssh-from-bastion.id,
            aws_security_group.flower.id,
            aws_security_group.queue-user.id,
            aws_security_group.internet-user.id
        ]
        assign_public_ip = true
    }
}



# RABBITMQ
resource "aws_ecs_task_definition" "queue" {
    family                = "rabbitmq"
    requires_compatibilities = ["FARGATE"]
    task_role_arn = aws_iam_role.secret_task_role.arn
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    network_mode = "awsvpc"
    cpu = 1024
    memory = 2048
    container_definitions = <<DEFINITION
[
  {
    "name": "rabbitmq",
    "cpu": 1024,
    "memory": 2048,
    "image": "rabbitmq:latest",
    "essential": true,
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "practice",
            "awslogs-region": "us-east-2",
            "awslogs-stream-prefix": "queue"
        }
    },
    "portMappings": [
      {
        "containerPort": 5672,
        "hostPort": 5672
      },
      {
        "containerPort": 22,
        "hostPort": 22
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "queue" {
  	name            = "queue"
  	cluster         = aws_ecs_cluster.jc_pipeline.id
  	task_definition = aws_ecs_task_definition.queue.family
  	desired_count   = 1
    launch_type     = "FARGATE"

    service_registries {
        registry_arn = aws_service_discovery_service.queue.arn
    }

    network_configuration {
        subnets = [aws_subnet.private.id]
        security_groups = [
            aws_security_group.ssh-from-bastion.id,
            aws_security_group.queue.id,
            aws_security_group.internet-user.id
        ]
    }
}