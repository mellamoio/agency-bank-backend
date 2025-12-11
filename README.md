# Backend Agencias Scotia

Breve backend para la gestión de agencias (proyecto de práctica).

**Estado:** rama `feature` / Python + FastAPI

## Contenido
- `app/` - Código fuente (routers, modelos, esquemas, utilidades)
- `sql/` - Scripts de inicialización de base de datos
- `requirements.txt` - Dependencias del proyecto
- `INSTALL.md` - Manual de instalación detallado

## Requisitos
- Python 3.13 o superior
- Git
- MySQL (opcional, según `DATABASE_URL`)
- Docker y docker-compose (opcional)

## Instalación rápida (Windows - PowerShell)

1. Clona el repositorio:

```
git clone https://github.com/mellamoio/agency-bank-backend.git
cd backend-agencias-scotia
```

2. Crea y activa el entorno virtual:

```
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

3. Instala dependencias:

# Backend Agencias Scotia

Proyecto backend de ejemplo para gestión de agencias bancarias, implementado con FastAPI.

**Estado:** rama `feature` (desarrollo). Lenguaje: Python 3.11, FastAPI.

Contenido principal
- `app/` - Código fuente (routers, modelos, esquemas, utilidades).
- `sql/` - Script de inicialización de base de datos (`sql/init.sql`).
- `.github/workflows/ci-cd.yml` - Pipeline CI/CD (tests, build, deploy).
- `.github/workflows/terraform-plan.yml` - Pipeline para Terraform (plan/apply).
- `terraform/` - Infraestructura como código (ECS, ECR, RDS, ALB, VPC).
- `requirements.txt` - Dependencias Python.

Requisitos
- Python 3.11
- Git
- Docker & Docker Compose (opcional para local)
- Terraform 1.5.x (para infra)
- Una cuenta AWS con permisos adecuados (se recomienda OIDC + IAM role)

Instalación local (Windows - PowerShell)

1. Clona el repositorio:

```
git clone https://github.com/mellamoio/agency-bank-backend.git
cd backend-agencias-scotia
```

2. Crear y activar entorno virtual:

```
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

3. Instalar dependencias:

```
pip install --upgrade pip
pip install -r requirements.txt
```

4. Variables de entorno (crear `.env` o exportar en tu shell)

Principales variables usadas por la aplicación:
- `DATABASE_URL` (ej. `mysql+pymysql://user:pass@host:3306/dbname`)
- `JWT_SECRET_KEY`, `JWT_ALGORITHM`
- Variables AWS usadas por workflows: el pipeline usa OIDC y asume un role (`secrets.AWS_ROLE_TO_ASSUME`).

Arrancar la app localmente:

```
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

La API estará en `http://localhost:8000`. Docs en `/docs` (Swagger) y `/redoc`.

Tests y lint

```
pip install -r requirements.txt pytest pytest-cov pylint
pytest
pylint app --disable=C0111,C0103 --fail-under=7.0
```

Docker (build & push a ECR)

Este repo produce una imagen que se publica en ECR. En CI/CD usamos OIDC para autenticación.

Comandos de ejemplo (PowerShell):

```
# Login (si no usas OIDC localmente)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Construir imagen
docker build -t agencias-scotia:latest .

# Tag y push (ejemplo genérico)
docker tag agencias-scotia:latest <ECR_REGISTRY>/agencias-scotia-dev-app:latest
docker push <ECR_REGISTRY>/agencias-scotia-dev-app:latest
```

Infraestructura (Terraform)

La carpeta `terraform/` contiene los módulos y recursos para desplegar en AWS:
- ECR repository
- ECS Fargate (cluster, task, service)
- Application Load Balancer (ALB)
- RDS (MySQL)
- VPC, subnets, security groups

Comandos básicos:

```
cd terraform
terraform init
terraform plan -var-file=terraform.dev.tfvars
terraform apply -var-file=terraform.dev.tfvars
```

Nota: existen `terraform.dev.tfvars` y `terraform.prod.tfvars` con configuraciones por ambiente.

CI / CD

Se incluyen dos workflows principales:
- ` .github/workflows/ci-cd.yml`: tests → build image → push a ECR → deploy a ECS.
- ` .github/workflows/terraform-plan.yml`: valida, planifica y aplica cambios de Terraform (con aprobación para `main`).

Importante: Los workflows están configurados para detectar el ambiente según la rama:
- `main` → `prod` (nombres de recursos terminan en `-prod`)
- `dev`, `feature/*` → `dev` (nombres terminan en `-dev`)

Los pipelines usan OIDC para asumir un role en AWS, la variable secreta esperada es `AWS_ROLE_TO_ASSUME` en GitHub Secrets.

Variables y convenciones de nombres

Terraform usa `project_name` y `environment` para nombrar recursos. Formato:

```
${project_name}-${environment}-{resource-type}
```

Ejemplos (dev): `agencias-scotia-dev-cluster`, `agencias-scotia-dev-service`, `agencias-scotia-dev-app`.

Arquitectura (resumen)

```
		Internet
		   |
		 ALB (HTTPS)
		   |
	   -----------------
	  |  Public Subnets  |
	   -----------------
		   |
	   -----------------
	  |  ECS Fargate (Tasks) |
	   -----------------
		   |       |
	   (Log → CloudWatch)  (Storage → S3)
		   |
		 RDS MySQL (Private Subnets)
```

Componentes clave
- ALB: balanceador público que enruta tráfico al servicio ECS.
- ECS Fargate: ejecuta las tareas del contenedor (FastAPI).
- ECR: repositorio de imágenes Docker.
- RDS MySQL: base de datos relacional en subredes privadas.
- CloudWatch: logs y métricas.
- IAM OIDC: autenticación segura para GitHub Actions.

Diagramas y detalle

- Diagrama ASCII arriba: flujo general. Para diagramas más detallados usa herramientas como draw.io o mermaid.

Buenas prácticas
- No codifiques credenciales en el repo. Usa GitHub Secrets y Terraform variables.
- Revisa que los nombres de recursos en CI coincidan con Terraform (ya se actualizó `ci-cd.yml` para esto).
- Usa `terraform plan` antes de `apply` y revisa cambios.

Solución de problemas
- Error "resource not found" en deploy: verifica que el nombre del cluster/service coincida con los creados por Terraform (schema: `${project_name}-${environment}-...`).
- Fallos de permisos AWS en GitHub Actions: revisa el role OIDC y el secret `AWS_ROLE_TO_ASSUME`.

Referencias útiles
- Ver archivo de pipeline: `.github/workflows/ci-cd.yml`
- Infraestructura: `terraform/`
- Código aplicación: `app/`

Contacto

Si necesitas ayuda, abre un issue en el repositorio o contacta al mantenedor.

---
Última actualización: Diciembre 11, 2025
