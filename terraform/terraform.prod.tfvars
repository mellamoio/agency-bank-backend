# terraform.prod.tfvars - Valores específicos para PRODUCCIÓN
# Solo incluir valores que DIFIEREN del default en variables.tf

# Environment
environment = "prod"

# FastAPI/ECS - Scale Up para producción
app_count      = 3
fargate_cpu    = "512"
fargate_memory = "1024"

# RDS MySQL Database - Scale Up para producción
db_instance_class    = "db.t3.small"
db_allocated_storage = 100
db_name              = "agencias_db"
db_username          = "admin"
db_password          = "Ingenier0io99" # ⚠️ CAMBIAR - Usar AWS Secrets Manager
aws_account_id       = "950071105194"
my_ip                = "138.84.39.13/32"

# Nota: aws_region y project_name mantienen sus defaults
