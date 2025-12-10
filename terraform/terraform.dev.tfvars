# terraform.dev.tfvars - Valores específicos para DESARROLLO
# Solo incluir valores que DIFIEREN del default en variables.tf

# FastAPI/ECS
app_count = 2

# RDS MySQL Database
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20
db_name              = "agencias_db"
db_username          = "admin"
db_password          = "Dev123456!"  # ⚠️ NO COMMITEAR - Usar valores locales
