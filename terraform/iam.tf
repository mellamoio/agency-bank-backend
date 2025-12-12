# IAM Role para ECS Task Execution (para extraer imágenes y escribir logs)
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

# NOTA: NO agregamos una policy custom adicional para logs (la managed policy ya cubre)
# Si necesitas permisos extras los agregamos de forma específica.

# IAM Role para FastAPI Task (la app)
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

# Policy para que la tarea lea el secreto de DB (adjunta al task role)
resource "aws_iam_policy" "ecs_secrets_access" {
  name        = "${var.project_name}-${var.environment}-ecs-secrets-access"
  description = "Allow ECS tasks to read DB password from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:agencias-scotia-${var.environment}-db-password*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_secrets_access_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_secrets_access.arn
}

# Si tu app realmente necesita S3/otros, define políticas separadas y acótalas al bucket/ARN.
# Ejemplo mínimo S3 (descomentar solo si lo vas a usar):
# resource "aws_iam_policy" "ecs_task_s3" {
#   name = "${var.project_name}-${var.environment}-ecs-s3"
#   policy = jsonencode({...})
# }
# resource "aws_iam_role_policy_attachment" "ecs_task_s3_attach" {
#   role = aws_iam_role.ecs_task_role.name
#   policy_arn = aws_iam_policy.ecs_task_s3.arn
# }
