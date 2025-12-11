# ================================================
# TERRAFORM VARIABLES - DESARROLLO
# ================================================
# Usar: terraform apply -var-file=terraform.dev.tfvars
# ================================================

# AWS Region
aws_region = "us-east-1"

# Project Info
project_name = "agencias-scotia"
environment  = "dev"

# ===== ECS CONFIGURACIÓN DESARROLLO =====
# 1 instancia (estudio, sin costo de múltiples instancias)
app_count = 1

# CPU y Memoria para FastAPI en DEV (recursos mínimos)
fargate_cpu    = "256"   # 0.25 vCPU
fargate_memory = "512"   # 512MB RAM

# ===== RDS CONFIGURACIÓN DESARROLLO =====
# Free Tier
db_instance_class   = "db.t3.micro"     # Free Tier
db_allocated_storage = 20               # 20 GB

# Database
db_name     = "agencias_db"
db_username = "admin"

# ⚠️ IMPORTANTE: 
# No incluir db_password aquí - se inyecta vía variable de ambiente TF_VAR_db_password
# Los valores sensibles se toman de GitHub Secrets durante el apply en CI/CD

# Para aplicar localmente, descomentar y establecer valores:
# db_password    = "TU_PASSWORD_AQUI"  # Mínimo 8 caracteres
# aws_account_id = "123456789012"      # Tu AWS Account ID
# my_ip          = "203.0.113.0/32"    # Tu IP pública/32 para Workbench
