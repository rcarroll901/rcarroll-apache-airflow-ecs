output "bastion_public_ip" {
    value = aws_instance.bastion.public_ip
}

output "load_balancer_dns" {
    value = aws_alb.webserver-load-balancer.dns_name
}

output "service-discovery-id"{
    value = aws_service_discovery_service.queue.id
}