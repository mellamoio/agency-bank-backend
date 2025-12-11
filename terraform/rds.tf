# RDS - MySQL Free Tier Optimizado para Aprendizaje

# Subnet Group para RDS (en subnets privadas)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

# Security Group para RDS - permite acceso desde ECS Y desde tu IP
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Permitir acceso MySQL desde ECS Tasks y Workbench"
  vpc_id      = aws_vpc.main.id

  # Acceso desde ECS Tasks
  ingress {
    description     = "MySQL from ECS Tasks"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  # 🔥 NUEVA REGLA: Acceso desde tu computadora para Workbench
  ingress {
    description = "MySQL from my computer (Workbench)"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] # Usaremos una variable para tu IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  }
}

# Parameter Group básico compatible Free Tier
resource "aws_db_parameter_group" "main" {
  name   = "${var.project_name}-${var.environment}-mysql80-params"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-db-params"
  }
}

# RDS Instance Free Tier
resource "aws_db_instance" "main" {
  identifier                 = "${var.project_name}-${var.environment}-db"
  engine                     = "mysql"
  engine_version             = "8.0"
  auto_minor_version_upgrade = true

  # FREE TIER
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # ✅ Ya está en true - necesario para acceso desde Workbench
  publicly_accessible = true
  port                = 3306

  backup_retention_period = 1
  multi_az                = false
  monitoring_interval     = 0
  enabled_cloudwatch_logs_exports = []

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-mysql-db"
  }

  depends_on = [
    aws_db_subnet_group.main,
    aws_security_group.rds,
    aws_db_parameter_group.main
  ]
}

# Alarmas opcionales
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  dimensions          = { DBInstanceIdentifier = aws_db_instance.main.id }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "2147483648"
  dimensions          = { DBInstanceIdentifier = aws_db_instance.main.id }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  dimensions          = { DBInstanceIdentifier = aws_db_instance.main.id }
}