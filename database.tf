
# META-DB FOR AIRFLOW
resource "aws_rds_cluster" "airflow-meta-db" {
  cluster_identifier      = "airflow-meta-db"
  engine                  = "aurora-postgresql"
  database_name           = "jc_pipeline_metadb"
  engine_version          = "11.6"
  master_username         = var.database_username
  master_password         = var.database_password
  skip_final_snapshot  = true
}

resource "aws_rds_cluster_instance" "meta-instance" {
  count              = 1
  identifier         = "airflowmeta"
  cluster_identifier = aws_rds_cluster.airflow-meta-db.id
  instance_class     = "db.t3.medium"
  engine_version     = aws_rds_cluster.jc-db.engine_version
  engine             = aws_rds_cluster.airflow-meta-db.engine
}

# PRODUCTION DATABASE FOR SCRAPED DATA
resource "aws_rds_cluster" "jc-db" {
  cluster_identifier      = "jc-db"
  engine                  = "aurora-postgresql"
  engine_version          = "11.6"
  database_name           = "jc_pipeline_metadb"
  master_username         = var.database_username
  master_password         = var.database_password
  skip_final_snapshot  = true
}

resource "aws_rds_cluster_instance" "prod-instance" {
  count              = 1
  identifier         = "prod-db"
  cluster_identifier = aws_rds_cluster.jc-db.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.jc-db.engine
  engine_version     = aws_rds_cluster.jc-db.engine_version
}