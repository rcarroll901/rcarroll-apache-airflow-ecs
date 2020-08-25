
resource "aws_alb" "webserver-load-balancer" {
    name = "webserver-load-balancer"
    security_groups = [aws_security_group.load-balancer.id]
    subnets = [aws_subnet.public.id, aws_subnet.private.id]

    access_logs {
        bucket = "jc-pipeline-load-balancer"
        enabled = true
    }
}

resource "aws_alb_target_group" "webserver-group" {
    name                = "webserver-group"
    port                = "8080"
    protocol            = "HTTP"
    vpc_id              = aws_vpc.airflow.id
    target_type         = "ip"
    depends_on = [aws_alb.webserver-load-balancer]

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "5"
        interval            = "120"
        matcher             = "302"
        path                = "/"
        port                = "8080"
        protocol            = "HTTP"
        timeout             = "60"
    }

    tags = {
      Name = "webserver-target-group"
    }
}

resource "aws_alb_listener" "alb-listener" {
    load_balancer_arn = aws_alb.webserver-load-balancer.arn
    port              = "8080"
    protocol          = "HTTP"
    
    default_action {
        target_group_arn = aws_alb_target_group.webserver-group.arn
        type             = "forward"
    }
}