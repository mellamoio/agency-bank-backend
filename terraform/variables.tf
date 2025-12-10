variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto (FastAPI Backend Agencias Scotia)"
  type        = string
  default     = "agencias-scotia"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "app_count" {
  description = "Número de instancias de la aplicación"
  type        = number
  default     = 1
}

variable "fargate_cpu" {
  description = "CPU para Fargate task - FastAPI recomienda 256 para desarrollo"
  type        = string
  default     = "256"
}

variable "fargate_memory" {
  description = "Memoria para Fargate task (MB) - FastAPI recomienda 512MB mínimo"
  type        = string
  default     = "512"
}

# ==================== RDS Variables ====================

variable "db_instance_class" {
  description = "Tipo de instancia RDS (db.t3.micro para dev, db.t3.small para prod)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Almacenamiento inicial de RDS en GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Nombre de la base de datos MySQL"
  type        = string
  default     = "agencias_db"
}

variable "db_username" {
  description = "Usuario master de RDS"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Contraseña del usuario master de RDS (CAMBIAR EN PRODUCCIÓN)"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.db_password) >= 8
    error_message = "La contraseña debe tener al menos 8 caracteres"
  }
}