# IAM Role para ECS Task Execution - Permite a ECS ejecutar tareas FastAPI
# Incluye permisos para logs, ECR, etc.
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Política adicional para CloudWatch Logs
resource "aws_iam_role_policy" "ecs_task_execution_cloudwatch" {
  name = "${var.project_name}-${var.environment}-ecs-cloudwatch-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}

# IAM Role para FastAPI Task - Permisos para la aplicación
# Útil si FastAPI accede a S3, DynamoDB, Secrets Manager, etc.
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-task-role"
  }
}

# Política para acceso a otros servicios de AWS (si se necesita)
resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${var.project_name}-${var.environment}-ecs-task-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = "*"
    }]
  })
}

# =======================================================
# PERMISOS PARA QUE ECS LEA SECRET MANAGER (MUY IMPORTANTE)
# =======================================================

# Policy para permitir obtener el valor del secreto RDS
resource "aws_iam_policy" "ecs_secrets_access" {
  name        = "${var.project_name}-${var.environment}-ecs-secrets-access"
  description = "Allow ECS tasks to read Secrets Manager secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        # Usa wildcard para permitir el ID dinámico que AWS agrega al final
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:agencias-scotia-${var.environment}-db-password*"
      }
    ]
  })
}

# Adjuntar la policy a la Execution Role (la que usa ECS para extraer secretos)
resource "aws_iam_role_policy_attachment" "ecs_secrets_access_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_secrets_access.arn
}
