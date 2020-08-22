
# DB
resource "aws_security_group" "airflow-db" {
    name = "airflow-db"
    description = "security group for airflow meta-db"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "airflow-db"
    }
}

resource "aws_security_group_rule" "db-user-in" {
    type = "ingress"
    security_group_id = aws_security_group.airflow-db.id
    source_security_group_id = aws_security_group.airflow-db-user.id
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
}

# DB USER
resource "aws_security_group" "airflow-db-user" {
    name = "airflow-db-user"
    description = "security group for instances needing access to db"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "airflow-db-user"
    }
}

resource "aws_security_group_rule" "db-user-out" {
    type = "egress"
    security_group_id = aws_security_group.airflow-db-user.id
    source_security_group_id = aws_security_group.airflow-db.id
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
}

# BASTION
resource "aws_security_group" "bastion" {
    name = "jc_pipeline_bastion"
    description = "locked down sg for bastion"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "airflow-pipeline-bastion"
    }
}

resource "aws_security_group_rule" "bastion-ssh-from-world" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    # restrict this to only necessary IPs
    security_group_id = aws_security_group.bastion.id
    cidr_blocks = ["0.0.0.0/0"] # how to keep this dynamic and allow multiple?
}

resource "aws_security_group_rule" "bastion-ssh-out" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = aws_security_group.bastion.id
    source_security_group_id = aws_security_group.worker.id
}

# SSH FROM BASTION
resource "aws_security_group" "ssh-from-bastion" {
    name = "ssh-from-bastion"
    description = "for privatee subnet instances that need access from bastion"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "ssh-from-bastion"
    }
}

resource "aws_security_group_rule" "ssh-from-bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = aws_security_group.ssh-from-bastion.id
    source_security_group_id = aws_security_group.bastion.id
}

# QUEUE
resource "aws_security_group" "queue" {
    name = "jc_pipeline_queue"
    description = "For messenger queue to receive serve requests"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "airflow-queue"
    }
}

resource "aws_security_group_rule" "queue-user-in" {
    type = "ingress"
    from_port = 5672
    to_port = 5672
    protocol = "tcp"
    security_group_id = aws_security_group.queue.id
    source_security_group_id = aws_security_group.queue-user.id
}

# QUEUE USER
resource "aws_security_group" "queue-user" {
    name = "queue-user"
    description = "security group for instances needing access to db"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "airflow-db-user"
    }
}

resource "aws_security_group_rule" "queue-user-out" {
    type = "egress"
    security_group_id = aws_security_group.queue-user.id
    source_security_group_id = aws_security_group.queue.id
    from_port = 5672
    to_port = 5672
    protocol = "tcp"
}

# FLOWER
resource "aws_security_group" "flower" {
    name = "jc_pipeline_flower"
    description = "For flower to receive serve requests"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "airflow-flower"
    }
}

resource "aws_security_group_rule" "flower-from-world" {
    type = "ingress"
    from_port = 5555
    to_port = 5555
    protocol = "tcp"
    # restrict this to only necessary IPs
    security_group_id = aws_security_group.flower.id
    cidr_blocks = ["0.0.0.0/0"] # how to keep this dynamic and allow multiple?
}

resource "aws_security_group_rule" "flower-user-in" {
    type = "ingress"
    from_port = 5555
    to_port = 5555
    protocol = "tcp"
    security_group_id = aws_security_group.flower.id
    source_security_group_id = aws_security_group.flower-user.id
}

# FLOWER USER
resource "aws_security_group" "flower-user" {
    name = "flower-user"
    description = "security group for instances needing access to db"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "flower-user"
    }
}

resource "aws_security_group_rule" "flower-user-out" {
    type = "egress"
    security_group_id = aws_security_group.flower-user.id
    source_security_group_id = aws_security_group.flower.id
    from_port = 5555
    to_port = 5555
    protocol = "tcp"
}

# WORKER
resource "aws_security_group" "worker" {
    name = "jc_pipeline_worker"
    description = "For worker instances"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "airflow-worker"
    }
}

resource "aws_security_group_rule" "worker-user-in" {
    type = "ingress"
    from_port = 8793
    to_port = 8793
    protocol = "tcp"
    security_group_id = aws_security_group.worker.id
    source_security_group_id = aws_security_group.worker-user.id
}

resource "aws_security_group_rule" "webserver-in" {
    type = "ingress"
    from_port = 8793
    to_port = 8793
    protocol = "tcp"
    security_group_id = aws_security_group.worker.id
    source_security_group_id = aws_security_group.webserver.id
}

resource "aws_security_group_rule" "worker-internet-out" {
    type = "egress"
    security_group_id = aws_security_group.worker.id
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
}

# WORKER USER
resource "aws_security_group" "worker-user" {
    name = "worker-user"
    description = "security group for instances needing access to db"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "worker-user"
    }
}

resource "aws_security_group_rule" "worker-user-out" {
    type = "egress"
    security_group_id = aws_security_group.worker-user.id
    source_security_group_id = aws_security_group.worker.id
    from_port = 8793
    to_port = 8793
    protocol = "tcp"
}


# WEBSERVER (connect to rds, workers, bastion)
resource "aws_security_group" "webserver" {
    name = "jc_pipeline_webserver"
    description = "For webserver instances with access to rds, queue, flower, and workers"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "airflow-webserver"
    }
}

resource "aws_security_group_rule" "webserver-from-world" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_group_id = aws_security_group.webserver.id
    source_security_group_id = aws_security_group.load-balancer.id

}

resource "aws_security_group_rule" "worker-user-out-webserver" {
    type = "egress"
    security_group_id = aws_security_group.webserver.id
    source_security_group_id = aws_security_group.worker.id
    from_port = 8793
    to_port = 8793
    protocol = "tcp"
}

resource "aws_security_group_rule" "webserver-internet-out" {
    type = "egress"
    security_group_id = aws_security_group.webserver.id
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
}


# Load balancer
resource "aws_security_group" "load-balancer" {
    name = "jc_pipeline_alb"
    description = "ALB for webserver tasks"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "airflow-alb"
    }
}

resource "aws_security_group_rule" "alb-from-world" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    # restrict this to only necessary IPs
    security_group_id = aws_security_group.load-balancer.id
    cidr_blocks = ["0.0.0.0/0"] 
}

resource "aws_security_group_rule" "alb-to-webserver" {
    type = "egress"
    security_group_id = aws_security_group.load-balancer.id
    source_security_group_id = aws_security_group.webserver.id
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
}

# INTERNET USER
resource "aws_security_group" "internet-user" {
    name = "internet-access"
    description = "Allows instances to reach out via HTTPS"
    vpc_id = aws_vpc.airflow.id
    tags = {
        Name = "internet-access"
    }
}

resource "aws_security_group_rule" "internet-out" {
    type = "egress"
    security_group_id = aws_security_group.internet-user.id
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
}