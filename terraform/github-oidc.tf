# ============================================
# GitHub Actions OIDC Configuration CORREGIDO
# IAM Roles seguros para CI/CD
# ============================================

variable "github_owner" {
  description = "Owner del repositorio GitHub"
  type        = string
  default     = "mellamoio"
}

variable "github_repo" {
  description = "Nombre del repositorio GitHub"
  type        = string
  default     = "agency-bank-backend"
}

# ======== OIDC Provider ========
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aba1"
  ]

  client_id_list = ["sts.amazonaws.com"]

  tags = {
    Name = "github-actions-oidc"
  }
}

# ======== Role para GitHub Actions ========
resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"

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
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# ======== PERMISOS NECESARIOS y SEGUROS ========
resource "aws_iam_role_policy" "github_ci_cd" {
  name = "github-ci-cd-permissions"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ----- ECR (push & pull) -----
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = "*"
      },

      # ----- ECS (actualizar servicios) -----
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "*"
      },

      # ----- IAM para ECS (obligatorio) -----
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "${aws_iam_role.ecs_task_execution_role.arn}",
          "${aws_iam_role.ecs_task_role.arn}"
        ]
      },

      # ----- Logs (ver registros) -----
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      },

      # ----- Permisos para Terraform -----
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "rds:*",
          "secretsmanager:*",
          "cloudwatch:*",
          "logs:*",
          "cloudformation:*",
          "tag:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# ======== OUTPUTS ========
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}
