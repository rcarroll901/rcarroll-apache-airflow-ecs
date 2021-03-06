
# META-DB FOR AIRFLOW
resource "aws_rds_cluster" "airflow-meta-db" {
  cluster_identifier      = "airflow-meta-db"
  engine                  = "aurora-postgresql"
  database_name           = "jc_pipeline_metadb"
  engine_version          = "11.6"
  vpc_security_group_ids  = [aws_security_group.airflow-db.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  master_username         = var.db_username
  master_password         = var.db_password
  skip_final_snapshot  = true
}

resource "aws_rds_cluster_instance" "meta-instance" {
  count              = 1
  identifier         = "airflowmeta"
  cluster_identifier = aws_rds_cluster.airflow-meta-db.id
  instance_class     = "db.t3.medium"
  engine_version     = aws_rds_cluster.jc-db.engine_version
  engine             = aws_rds_cluster.airflow-meta-db.engine
  db_subnet_group_name    = aws_db_subnet_group.main.name
  publicly_accessible = false
}

# PRODUCTION DATABASE FOR SCRAPED DATA
resource "aws_rds_cluster" "jc-db" {
  cluster_identifier      = "jc-db"
  engine                  = "aurora-postgresql"
  engine_version          = "11.6"
  database_name           = "jc_pipeline_metadb"
  vpc_security_group_ids  = [aws_security_group.airflow-db.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  master_username         = var.db_username
  master_password         = var.db_password
  skip_final_snapshot  = true
}

resource "aws_rds_cluster_instance" "prod-instance" {
  count              = 1
  identifier         = "prod-db"
  cluster_identifier = aws_rds_cluster.jc-db.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.jc-db.engine
  engine_version     = aws_rds_cluster.jc-db.engine_version
  db_subnet_group_name    = aws_db_subnet_group.main.name
  publicly_accessible = false
}

# subnets
resource "aws_db_subnet_group" "main" {
  name       = "db_subnets"
  subnet_ids = [aws_subnet.private.id, aws_subnet.public.id]

  tags = {
    Name = "db subnet group"
  }
}