output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "ecr_repository_url" {
  description = "URL del repositorio ECR"
  value       = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "DNS del Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "URL completa de la aplicación"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Nombre del servicio ECS"
  value       = aws_ecs_service.app.name
}

output "cloudwatch_log_group" {
  description = "Nombre del log group de CloudWatch"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "cloudwatch_dashboard_url" {
  description = "URL del dashboard de CloudWatch"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

# ==================== RDS Outputs ====================

output "rds_endpoint" {
  description = "Endpoint RDS completo (host:puerto)"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "Dirección del host RDS (sin puerto)"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "Puerto RDS MySQL"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "Nombre de la base de datos MySQL"
  value       = aws_db_instance.main.db_name
}

output "rds_username" {
  description = "Usuario master de RDS"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "database_url" {
  description = "DATABASE_URL completa para FastAPI (.env o Secrets Manager)"
  value       = "mysql+pymysql://${aws_db_instance.main.username}:****@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
  sensitive   = true
}

output "rds_security_group_id" {
  description = "ID del Security Group de RDS"
  value       = aws_security_group.rds.id
}