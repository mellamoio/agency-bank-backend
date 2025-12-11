# ============================================
# GitHub Actions OIDC Configuration
# Crea automáticamente el provider OIDC y role IAM
# para que GitHub Actions pueda asumir credenciales AWS
# ============================================

# ===== Variables para GitHub =====
variable "github_owner" {
  description = "Owner del repositorio GitHub (usuario u organización)"
  type        = string
  default     = "mellamoio"
}

variable "github_repo" {
  description = "Nombre del repositorio GitHub"
  type        = string
  default     = "agency-bank-backend"
}

# ===== PROVEEDOR OIDC =====
# Permite que GitHub Actions obtenga tokens JWT para asumir roles
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  # Certificado de GitHub Actions
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aba1"
  ]

  # Audience - quién puede usar estos tokens
  client_id_list = ["sts.amazonaws.com"]

  tags = {
    Name = "github-actions-oidc"
  }
}

# ===== ROLE IAM PARA GITHUB ACTIONS =====
# Role que GitHub Actions puede asumir para obtener credenciales AWS
resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"

  # Trust policy - permite a GitHub OIDC asumir este role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/*"
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "github-actions-role"
    CreatedBy   = "Terraform"
    Purpose     = "GitHub Actions OIDC"
  }
}

# ===== PERMISOS PARA ECR (Pushear imágenes) =====
resource "aws_iam_role_policy_attachment" "github_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# ===== PERMISOS PARA ECS (Desplegar servicios) =====
resource "aws_iam_role_policy_attachment" "github_ecs" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# ===== PERMISOS PARA CLOUDWATCH (Logs) =====
resource "aws_iam_role_policy_attachment" "github_cloudwatch" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# ===== PERMISOS PARA TERRAFORM (Crear infraestructura) =====
# Política customizada con permisos amplios para Terraform
resource "aws_iam_role_policy" "github_terraform" {
  name = "github-terraform-permissions"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TerraformInfrastructure"
        Effect = "Allow"
        Action = [
          # EC2 - VPC, Subnets, Security Groups, NAT Gateways
          "ec2:*",
          
          # RDS - Base de datos
          "rds:*",
          
          # Elastic Load Balancing - ALB
          "elasticloadbalancing:*",
          
          # IAM - Roles y políticas
          "iam:*",
          
          # Secrets Manager - Credenciales
          "secretsmanager:*",
          
          # CloudWatch - Logs y métricas
          "cloudwatch:*",
          "logs:*",
          
          # CloudFormation - para algunos recursos
          "cloudformation:*",
          
          # Tagging
          "tag:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# ===== OUTPUTS =====
output "github_oidc_provider_arn" {
  description = "ARN del proveedor OIDC de GitHub"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "ARN del role IAM para GitHub Actions - USA ESTE VALOR EN GITHUB SECRET"
  value       = aws_iam_role.github_actions.arn
  sensitive   = false
}

output "github_actions_role_name" {
  description = "Nombre del role IAM"
  value       = aws_iam_role.github_actions.name
}

output "github_secret_value" {
  description = "Valor para agregar al Secret AWS_ROLE_TO_ASSUME en GitHub"
  value       = "Copia este ARN a GitHub: ${aws_iam_role.github_actions.arn}"
}
