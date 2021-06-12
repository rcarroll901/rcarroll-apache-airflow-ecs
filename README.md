# Apache Airflow ECS Cluster

I built this infrastructure to host an ETL pipeline and manage a series of interweaving tasks of scraping, transformating, uploading, and analyzing data. 

This AWS Elastic Container Service (ECS) cluster took advantage of Apache Airflow's CeleryExecutor to parallelize task execution along with RabbitMQ as the messenger to communicate tasks between the different nodes. Because I used Fargate instances which could not be assigned an EIP, the cluster used AWS Service Discovery to keep the workers, flower, webserver, and scheduler nodes fixed on the queue's private IP which changed as the cluster was started and stopped. 

The VPC is standard with a single private subnet (for the nodes and RDS cluster) and single public subnet (to host the webserver + NAT), and I built it from the ground up, including security groups, routing tables, subnets, etc...

Soon after I completed this (painstaking) process, [AWS released their own "Managed Workflows for Apache Airflow"](https://aws.amazon.com/blogs/aws/introducing-amazon-managed-workflows-for-apache-airflow-mwaa/). This cluster worked well for many purposes, but I also soon realized the power of AWS Lambda and laid this cluster to rest. 
