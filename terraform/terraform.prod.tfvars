# ================================================
# TERRAFORM VARIABLES - PRODUCCIÓN
# ================================================
# Usar: terraform apply -var-file=terraform.prod.tfvars
# ================================================

# AWS Region
aws_region = "us-east-1"

# Project Info
project_name = "agencias-scotia"
environment  = "prod"

# ===== ECS CONFIGURACIÓN ESTUDIO =====
# 1 instancia (mismo que DEV para ahorrar)
app_count = 1

# CPU y Memoria MÍNIMAS para estudio
fargate_cpu    = "256"   # 0.25 vCPU
fargate_memory = "512"   # 512 MB RAM

# ===== RDS CONFIGURACIÓN ESTUDIO =====
# Free Tier en ambos ambientes
db_instance_class   = "db.t3.micro"     # Free Tier
db_allocated_storage = 20               # Mínimo para Free Tier

# Database
db_name     = "agencias_db"
db_username = "admin"
aws_account_id = "950071105194"

# ⚠️ IMPORTANTE: 
# No incluir db_password aquí - se inyecta vía variable de ambiente TF_VAR_db_password
# Los valores sensibles se toman de GitHub Secrets durante el apply en CI/CD

# Para aplicar localmente, descomentar y establecer valores:
# db_password    = "TU_PASSWORD_AQUI"  # Mínimo 8 caracteres
# aws_account_id = "TU_ACCOUNT_ID_REAL"      # Tu AWS Account ID
# my_ip          = "203.0.113.0/32"    # Tu IP pública/32 para Workbench
