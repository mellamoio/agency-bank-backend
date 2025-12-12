# ============ SUBNET GROUP ============
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id  # <-- FIX IMPORTANTE

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

# ============ SECURITY GROUP ============
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Permitir acceso MySQL desde ECS y Workbench"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from ECS Tasks"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  # Acceso desde tu IP solo en DEV
  ingress {
    description = "MySQL desde mi PC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.environment == "dev" ? [var.my_ip] : []
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

# ============ PARAMETER GROUP ============
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
}

# ============ RDS INSTANCE ============
resource "aws_db_instance" "main" {
  identifier                 = "${var.project_name}-${var.environment}-db"
  engine                     = "mysql"
  engine_version             = "8.0"

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Solo dev permite accesos públicos
  publicly_accessible = var.environment == "dev" ? true : false

  port = 3306

  backup_retention_period = 0
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
