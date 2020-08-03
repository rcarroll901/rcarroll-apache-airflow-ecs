resource "aws_service_discovery_private_dns_namespace" "main" {
    name = "jc.pipeline"
    description = "domain for all services"
    vpc = aws_vpc.airflow.id
}

resource "aws_service_discovery_service" "queue" {
    name = "queue"
    dns_config {
        namespace_id = aws_service_discovery_private_dns_namespace.main.id
        routing_policy = "MULTIVALUE"
        dns_records {
            ttl = 10
            type = "A"
        }
    }
    health_check_custom_config {
        failure_threshold = 5
        }
}