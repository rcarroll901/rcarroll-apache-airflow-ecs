
# META-DB FOR AIRFLOW
resource "aws_rds_cluster" "airflow-metadb" {
  cluster_identifier      = "airflow-metadb"
  engine                  = "aurora-postgresql"
  database_name           = "jc-pipeline-metadb"
  master_username         = "airflow"
  master_password         = "airflow"
}

resource "aws_rds_cluster_instance" "meta-instance" {
  count              = 1
  identifier         = "airflow-meta"
  cluster_identifier = aws_rds_cluster.airflow-metadb.id
  instance_class     = "db.t2.micro"
  engine             = aws_rds_cluster.airflow-metadb.engine
  engine_version     = aws_rds_cluster.airflow-metadb.engine_version
}

# PRODUCTION DATABASE FOR SCRAPED DATA
resource "aws_rds_cluster" "jc-db" {
  cluster_identifier      = "airflow-metadb"
  engine                  = "aurora-postgresql"
  database_name           = "jc-pipeline-metadb"
  master_username         = "airflow"
  master_password         = "airflow"
}

resource "aws_rds_cluster_instance" "prod-instance" {
  count              = 1
  identifier         = "jc-db-prod"
  cluster_identifier = aws_rds_cluster.jc-db.id
  instance_class     = "db.t2.micro"
  engine             = aws_rds_cluster.jc-db.engine
  engine_version     = aws_rds_cluster.jc-db.engine_version
}