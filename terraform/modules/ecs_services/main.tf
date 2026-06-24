resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security Group del Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP desde Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Salida libre"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-${var.environment}-ecs-tasks-sg"
  description = "Security Group de las tareas ECS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    description = "PostgreSQL interno entre tareas ECS"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "PostgreSQL desde la VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  ingress {
    description = "HTTP interno desde la VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb" "this" {

  name = "${var.project_name}-${var.environment}-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = var.public_subnet_ids

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["ui"].arn
  }
}

resource "aws_lb_listener_rule" "admin" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["admin"].arn
  }

  condition {
    path_pattern {
      values = ["/admin", "/admin/", "/auth/*"]
    }
  }
}

resource "aws_lb_target_group" "services" {
  for_each = {
    for name, url in var.repository_urls :
    name => url
    if contains(var.public_services, name)
  }

  name        = "${var.project_name}-${var.environment}-${each.key}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = each.key
  }
}

resource "aws_cloudwatch_log_group" "services" {
  for_each = var.repository_urls

  name              = "/ecs/${var.project_name}-${var.environment}-${each.key}"
  retention_in_days = 7

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = each.key
  }
}

resource "aws_ecs_task_definition" "services" {
  for_each = var.repository_urls

  family                   = "${var.project_name}-${var.environment}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = "${each.value}:latest"
      essential = true

      environment = [
        for env_name, env_value in lookup(var.service_environment, each.key, {}) : {
          name  = env_name
          value = env_value
        }
      ]

      secrets = [
        for secret_name, secret_arn in lookup(var.service_secrets, each.key, {}) : {
          name      = secret_name
          valueFrom = secret_arn
        }
      ]

      portMappings = [
        {
          containerPort = each.key == "db" ? 5432 : var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.services[each.key].name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = each.key
  }
}

resource "aws_ecs_service" "services" {
  for_each = var.repository_urls

  name            = "${var.project_name}-${var.environment}-${each.key}-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.services[each.key].arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }


  dynamic "load_balancer" {
    for_each = contains(var.public_services, each.key) ? [1] : []

    content {
      target_group_arn = aws_lb_target_group.services[each.key].arn
      container_name   = each.key
      container_port   = var.container_port
    }
  }

  dynamic "load_balancer" {
    for_each = each.key == "db" ? [1] : []

    content {
      target_group_arn = aws_lb_target_group.db.arn
      container_name   = each.key
      container_port   = 5432
    }
  }

  dynamic "load_balancer" {
  for_each = each.key == "catalog" ? [1] : []

    content {
      target_group_arn = aws_lb_target_group.catalog.arn
      container_name   = each.key
      container_port   = 8080
    }
  }
  dynamic "load_balancer" {
  for_each = each.key == "carts" ? [1] : []

  content {
    target_group_arn = aws_lb_target_group.carts.arn
    container_name   = each.key
    container_port   = 8080
  }
}

dynamic "load_balancer" {
  for_each = each.key == "checkout" ? [1] : []

  content {
    target_group_arn = aws_lb_target_group.checkout.arn
    container_name   = each.key
    container_port   = 8080
  }
}

dynamic "load_balancer" {
  for_each = each.key == "orders" ? [1] : []

  content {
    target_group_arn = aws_lb_target_group.orders.arn
    container_name   = each.key
    container_port   = 8080
  }
}

  depends_on = [
    aws_lb_listener.http,
    aws_lb_listener_rule.admin,
    aws_lb_listener.db,
    aws_lb_listener.catalog,
    aws_lb_listener.carts,
    aws_lb_listener.checkout,
    aws_lb_listener.orders
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = each.key
  }
}

resource "aws_lb" "db" {
  name               = "${var.project_name}-${var.environment}-db-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "db"
  }
}

resource "aws_lb_target_group" "db" {
  name        = "${var.project_name}-${var.environment}-db-tg"
  port        = 5432
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol = "TCP"
    port     = "5432"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "db"
  }
}

resource "aws_lb_listener" "db" {
  load_balancer_arn = aws_lb.db.arn
  port              = 5432
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.db.arn
  }
}

resource "aws_lb" "catalog" {
  name               = "${var.project_name}-${var.environment}-catalog-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "catalog"
  }
}

resource "aws_lb_target_group" "catalog" {
  name        = "${var.project_name}-${var.environment}-catalog-tg"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol = "TCP"
    port     = "8080"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "catalog"
  }
}

resource "aws_lb_listener" "catalog" {
  load_balancer_arn = aws_lb.catalog.arn
  port              = 8080
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalog.arn
  }
}

resource "aws_lb" "carts" {
  name               = "${var.project_name}-${var.environment}-carts-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "carts"
  }
}

resource "aws_lb_target_group" "carts" {
  name        = "${var.project_name}-${var.environment}-carts-tg"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol = "TCP"
    port     = "8080"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "carts"
  }
}

resource "aws_lb_listener" "carts" {
  load_balancer_arn = aws_lb.carts.arn
  port              = 8080
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.carts.arn
  }
}

resource "aws_lb" "checkout" {
  name               = "${var.project_name}-${var.environment}-checkout-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "checkout"
  }
}

resource "aws_lb_target_group" "checkout" {
  name        = "${var.project_name}-${var.environment}-checkout-tg"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol = "TCP"
    port     = "8080"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "checkout"
  }
}

resource "aws_lb_listener" "checkout" {
  load_balancer_arn = aws_lb.checkout.arn
  port              = 8080
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.checkout.arn
  }
}

resource "aws_lb" "orders" {
  name               = "${var.project_name}-${var.environment}-orders-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "orders"
  }
}

resource "aws_lb_target_group" "orders" {
  name        = "${var.project_name}-${var.environment}-orders-tg"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol = "TCP"
    port     = "8080"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "orders"
  }
}

resource "aws_lb_listener" "orders" {
  load_balancer_arn = aws_lb.orders.arn
  port              = 8080
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.orders.arn
  }
}