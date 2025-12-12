# MANUAL DE INSTALACIÓN - Backend Agencias Scotia

Guía completa paso a paso para instalar, configurar y desplegar el proyecto desde cero.

---

## Quick Start (Windows - PowerShell)

Si quieres levantar el proyecto rápidamente en Windows usando los comandos simplificados, sigue estos pasos.

1) Clonar el repositorio y entrar en la carpeta:

```powershell
git clone https://github.com/mellamoio/agency-bank-backend.git
cd backend-agencias-scotia
```

2) Crear y activar entorno virtual:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

3) Instalar dependencias Python:

```powershell
python -m pip install --upgrade pip
pip install -r requirements.txt
```

4a) Ejecutar app localmente (sin Docker):

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

4b) O iniciar con Docker Compose (MySQL + MinIO incluidos):

```powershell
docker-compose up --build -d
```

5) Acceder a la API:

```text
http://localhost:8000  (Swagger: /docs)
```

Si necesitas pasos más detallados, continúa leyendo las secciones siguientes.


## PARTE 1: REQUISITOS DEL SISTEMA

### 1.1 Verificar Python 3.11

```powershell
# Windows PowerShell
python --version
# Debe mostrar: Python 3.11.x
```

Si no lo tienes, descargalo de https://www.python.org/downloads/ (versión 3.11 o superior).

### 1.2 Verificar Git

```powershell
git --version
# Debe mostrar: git version 2.x.x
```

Descargar desde https://git-scm.com/download/win si no lo tienes.

### 1.3 Verificar Docker y Docker Compose

```powershell
docker --version
# Debe mostrar: Docker version 20.x o superior

docker-compose --version
# Debe mostrar: Docker Compose version 1.29.x o superior
```

Descargar desde https://www.docker.com/products/docker-desktop si no lo tienes.

### 1.4 Verificar AWS CLI (opcional pero recomendado)

```powershell
aws --version
# Debe mostrar: aws-cli/2.x.x
```

Descargar desde https://aws.amazon.com/es/cli/ si necesitas deploy en AWS.

### 1.5 Verificar Terraform (opcional pero recomendado para AWS)

```powershell
terraform --version
# Debe mostrar: Terraform v1.5.0 o superior
```

Descargar desde https://www.terraform.io/downloads si necesitas deploy en AWS.

---

## PARTE 2: CLONAR Y PREPARAR EL REPOSITORIO

### 2.1 Clonar el repositorio

```powershell
# Ir a tu directorio de trabajo
cd C:\Users\<TuUsuario>\Desktop  # o el directorio que prefieras

# Clonar el repo
git clone https://github.com/mellamoio/agency-bank-backend.git

# Entrar al directorio del proyecto
cd backend-agencias-scotia

# Ver el estado
git status
# Debe mostrar que estás en la rama 'feature' (por defecto)
```

### 2.2 Verificar rama actual

```powershell
git branch --show-current
# Debe mostrar: feature

# Si necesitas cambiar a otra rama:
git checkout dev
```

---

## PARTE 3: ENTORNO VIRTUAL PYTHON

### 3.1 Crear entorno virtual

```powershell
# En el directorio raíz del proyecto
python -m venv .venv
```

Este comando crea una carpeta `.venv/` con un intérprete Python aislado.

### 3.2 Activar entorno virtual

**Windows PowerShell:**

```powershell
.\.venv\Scripts\Activate.ps1
```

Si recibes un error sobre políticas de ejecución:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\.venv\Scripts\Activate.ps1
```

**macOS / Linux (Bash):**

```bash
source .venv/bin/activate
```

Debes ver `(.venv)` al inicio de tu línea de comando.

### 3.3 Actualizar pip

```powershell
python -m pip install --upgrade pip
```

---

## PARTE 4: INSTALAR DEPENDENCIAS PYTHON

### 4.1 Instalar dependencias del proyecto

```powershell
# Asegúrate de que el entorno virtual está activado
pip install -r requirements.txt
```

Este comando instala todas las librerías listadas en `requirements.txt`:
- FastAPI
- SQLAlchemy
- PyMySQL
- Boto3 (para AWS S3)
- Python-jose (para JWT)
- Uvicorn (servidor ASGI)
- Y otras...

### 4.2 Instalar herramientas de desarrollo (tests, lint)

```powershell
pip install pytest pytest-cov pylint
```

Para verificar:

```powershell
pip list
# Debe mostrar todas las librerías instaladas
```

---

## PARTE 5: CONFIGURAR VARIABLES DE ENTORNO

### 5.1 Crear archivo `.env`

En la raíz del proyecto (mismo nivel que `app/`, `terraform/`, etc.), crea un archivo llamado `.env`:

```powershell
# Windows PowerShell - crear un archivo .env vacío
New-Item -Path .\.env -ItemType File -Force
```

O si prefieres, ábrelo en tu editor favorito (VS Code, Notepad++, etc.).

### 5.2 Rellenar el archivo `.env`

Copia y pega el siguiente contenido en `.env`, ajustando los valores según tu entorno:

```env
# ===== Base de datos MySQL =====
DATABASE_URL=mysql+pymysql://admin:tu_password_aqui@localhost:3306/agencias_db
DB_NAME=agencias_db
DB_USER=admin
DB_PASSWORD=tu_password_aqui
MYSQL_ROOT_PASSWORD=tu_root_password_aqui

# ===== JWT Auth =====
JWT_SECRET_KEY=tu_clave_secreta_muy_larga_y_segura_aqui_123456789
JWT_ALGORITHM=HS256
TOKEN_EXPIRE_MINUTES=30

# ===== Storage (MinIO o S3) =====
STORAGE_ACCESS_KEY=minioadmin
STORAGE_SECRET_KEY=minioadmin
STORAGE_URL=http://localhost:9000
STORAGE_BUCKET=agencias

# ===== AWS (solo si usas S3 real) =====
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=tu_access_key_aqui
AWS_SECRET_ACCESS_KEY=tu_secret_key_aqui

# ===== App =====
APP_NAME=Agencias Scotia Backend
APP_VERSION=1.0.0
DEBUG=true
```

**Notas importantes:**
- No uses contraseñas simples o valores por defecto en producción.
- No hagas commit de `.env` (ya está en `.gitignore`).
- Los valores `JWT_SECRET_KEY` deben ser cadenas largas y seguras.

---

## PARTE 6: EJECUTAR APLICACIÓN LOCALMENTE (sin Docker)

### 6.1 Ejecutar FastAPI

```powershell
# Asegúrate de que el entorno virtual está activado
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Verás algo como:

```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete
```

### 6.2 Acceder a la aplicación

Abre tu navegador y ve a:

```
http://localhost:8000
```

Para ver la documentación interactiva (Swagger UI):

```
http://localhost:8000/docs
```

Para ver ReDoc:

```
http://localhost:8000/redoc
```

### 6.3 Detener la aplicación

Presiona `Ctrl + C` en la terminal.

---

## PARTE 7: EJECUTAR CON DOCKER COMPOSE (con MySQL + MinIO)

### 7.1 Iniciar servicios

```powershell
# Asegúrate de estar en la raíz del proyecto
docker-compose up --build -d
```

**Qué hace este comando:**
- `-d`: ejecuta en background (detached mode).
- `--build`: reconstruye la imagen de FastAPI.

**Espera un momento** para que MySQL se inicialice (suele tardar 10-30 segundos).

### 7.2 Verificar que los servicios están corriendo

```powershell
docker-compose ps
```

Debes ver:

```
NAME            COMMAND                  SERVICE     STATUS
mysql8          "docker-entrypoint.s…"   mysql       Up 2 minutes
phpmyadmin      "docker-php-entrypoin…"  phpmyadmin  Up 2 minutes
minio_local     "minio server /data …"   minio       Up 2 minutes
fastapi_app     "uvicorn app.main:app"   fastapi     Up 2 minutes
```

### 7.3 Acceder a los servicios

- **FastAPI**: http://localhost:8000
- **Swagger docs**: http://localhost:8000/docs
- **phpMyAdmin**: http://localhost:8080 (user: `admin`, password: valor de `DB_PASSWORD`)
- **MinIO Console**: http://localhost:9001 (user: `minioadmin`, password: `minioadmin`)

### 7.4 Ver logs

```powershell
# Ver todos los logs
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f fastapi
docker-compose logs -f mysql
```

### 7.5 Parar servicios

```powershell
docker-compose down
```

**Para eliminar volúmenes de datos también (ATENCIÓN: borra datos):**

```powershell
docker-compose down -v
```

---

## PARTE 8: INICIALIZAR BASE DE DATOS

### 8.1 Si usas Docker Compose

El script `sql/init.sql` se ejecuta automáticamente cuando MySQL inicia. No necesitas hacer nada adicional.

### 8.2 Si usas MySQL local

Si tienes MySQL instalado localmente y no usas Docker:

```powershell
# En PowerShell (requiere MySQL en PATH o usar ruta completa)
mysql -u <usuario> -p < sql/init.sql
```

Cuando te pida password, ingresa la contraseña de tu usuario MySQL.

**Alternativa: desde MySQL Workbench o phpMyAdmin**
- Abre el archivo `sql/init.sql`
- Copia y pega el contenido en tu cliente MySQL
- Ejecuta

---

## PARTE 9: TESTS Y LINTING

### 9.1 Ejecutar tests

```powershell
# Asegúrate de que el entorno virtual está activado
pytest app/test/ -v
```

Para incluir reporte de cobertura:

```powershell
pytest app/test/ -v --cov=app --cov-report=html
```

Esto genera un reporte en `htmlcov/index.html`.

### 9.2 Ejecutar Pylint

```powershell
pylint app --disable=C0111,C0103 --fail-under=7.0
```


## PARTE 11: DESPLIEGUE CON TERRAFORM (AWS)

### 11.1 Navegar a la carpeta terraform

```powershell
cd terraform
```
**Primero define tus variables**
$env:TF_VAR_db_password="TU_PASSWORD"
$env:TF_VAR_aws_account_id="TU_ID_ACCOUNT"
$env:TF_VAR_my_ip="TU_IP_PUBLICA"



### 11.2 Inicializar Terraform

```powershell
terraform init
```

Esto descarga los proveedores necesarios (AWS).

### 11.3 Planificar para ambiente DEV

```powershell
terraform plan
```

**Revisa el output:**
- Debe mostrar qué recursos va a crear
- ECR repository: `agencias-scotia-dev-app`
- ECS cluster: `agencias-scotia-dev-cluster`
- RDS: `agencias-scotia-dev-dbinstance` (approx)

### 11.4 Aplicar cambios (DEV)

```powershell
terraform apply -var-file=terraform.dev.tfvars
terraform apply -var-file=terraform.prod.tfvars
```

Terraform preguntará: `Do you want to perform these actions?`

Escribe `yes` y presiona Enter.

**Espera:** puede tardar 5-15 minutos en crear todos los recursos.

### 11.5 Verificar outputs

```powershell
terraform output
```

Verás información como:
- Endpoint del ALB
- Cluster name
- Service name
- RDS endpoint

## PARTE 10: BUILD Y PUSH A ECR (AWS)

### 10.1 Crear repositorio ECR (si no existe)

```powershell```

# Requiere AWS CLI configurado
# Obtener URL del ECR
$ECR_URL = terraform output -raw ecr_repository_url
Write-Host "ECR URL: $ECR_URL"

# Generar un token temporal
aws ecr get-login-password --region us-east-1

# Guardar el token en una variable
$TOKEN = aws ecr get-login-password --region us-east-1

# Realizar un login manual usando el token
docker login --username AWS --password $TOKEN $ECR_URL

Debes ver: `Login Succeeded`

# Navegar a la carpeta de la app
cd ..

### Construir imagen
docker build -t ${ECR_URL}:latest -f Dockerfile.prod .

# Verificar imagen
docker images

# Subir imagen a ECR
docker push ${ECR_URL}:latest



### 11.6 Destruir infraestructura (si necesitas limpiar)

```powershell
# Para DEV
terraform destroy -var-file=terraform.dev.tfvars

# Para PROD
terraform destroy -var-file=terraform.prod.tfvars
```

**⚠️ ATENCIÓN:** Esto eliminará TODOS los recursos (RDS, ECS, etc.). Úsalo solo en desarrollo.

---

## PARTE 12: CONFIGURAR GITHUB PARA CI/CD

### 12.1 Preparar AWS para GitHub Actions (OIDC)

```powershell
# Este paso requiere permisos en AWS para crear roles IAM
# Se recomienda hacerlo desde AWS Console o AWS CLI avanzado

# Ver guía en: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
```

Necesitas:
1. Crear un role IAM con trust relationship para GitHub OIDC
2. Obtener el ARN del role (ej: `arn:aws:iam::123456789:role/github-actions-role`)

### 12.2 Añadir Secrets en GitHub

En tu repositorio GitHub:
1. Ir a **Settings** → **Secrets and variables** → **Actions**
2. Click en **New repository secret**
3. Añadir:
   - **Name:** `AWS_ROLE_TO_ASSUME`
   - **Value:** (el ARN del role OIDC)

```
arn:aws:iam::123456789:role/github-actions-role
```

4. Click en **Add secret**

5. Añadir:
   - **Name:** `TF_VAR_DB_PASSWORD`
   - **Value:** (CONTRASEÑA_DEFINIDA)

6. Click en **Add secret**

7. Ir a **Settings** → **Secrets and variables** → **Variables**
8. Click en **New repository secret** y agregar sus valores respectivos
   -ECR_REPO
   -ECS_CLUSTER
   -ECS_SERVICE



### 12.3 Verificar configuración OIDC en AWS

```powershell
# Listar identity providers
aws iam list-open-id-connect-providers

# Ver detalles del provider
aws iam get-open-id-connect-provider-thumbprint --open-id-connect-provider-arn "arn:aws:iam::123456789:oidc-provider/token.actions.githubusercontent.com"
```

---

## PARTE 13: FLUJO GIT Y PUSH

### 13.1 Configurar Git (primera vez)

```powershell
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

### 13.2 Crear rama para tus cambios

```powershell
git checkout -b feature
```

### 13.3 Hacer cambios

- Modifica los archivos que necesites
- Asegúrate de ejecutar tests localmente:

```powershell
pytest app/test/ -v
pylint app --disable=C0111,C0103 --fail-under=7.0
```

### 13.4 Agregar cambios y hacer commit

```powershell
# Ver qué archivos cambiaste
git status

# Agregar todos los cambios
git add .

# O agregar solo archivos específicos
git add app/routers/mi_router.py

# Hacer commit con mensaje descriptivo
git commit -m "feat: agregar nuevo endpoint para agencias"
```

**Convención de commits (Conventional Commits):**
- `feat:` para nuevas funcionalidades
- `fix:` para correcciones de bugs
- `docs:` para cambios en documentación
- `test:` para cambios en tests
- `refactor:` para refactoring de código

### 13.5 Hacer push al repositorio

```powershell
git push origin feature/tu-usuario
```

### 13.6 Abrir Pull Request en GitHub

1. Ir a https://github.com/mellamoio/agency-bank-backend
2. Click en **Pull requests**
3. Click en **New pull request**
4. Selecciona:
   - **Base:** `feature` (o `dev` si necesitas ir a development)
   - **Compare:** `feature/tu-cambio`
5. Añade descripción
6. Click en **Create pull request**

### 13.7 Esperar que los checks pasen

Los workflows `ci-cd.yml` y `terraform-plan.yml` se ejecutarán automáticamente:
- ✅ Tests
- ✅ Linting
- ✅ Security scan
- ✅ Build de imagen
- ✅ (opcional) Deploy a staging/dev

Si todo está verde (✅), puedes hacer merge.

### 13.8 Mergear PR

1. Espera aprobación del revisor
2. Click en **Merge pull request**
3. Selecciona **Squash and merge** o **Create a merge commit**
4. Click en **Confirm merge**

---

## PARTE 14: DEPLOY A PRODUCCIÓN (main)



### 14.1 Crear PR desde `feature` → `main`

```powershell
git checkout main
git pull origin main
git merge feature/tu-cambio
git push origin main
```

O a través de GitHub UI:
1. Crear PR con base `main`
2. Esperar checks
3. Merge después de aprobación

### 14.2 CI/CD automatizado se ejecutará

El workflow `ci-cd.yml` hará:
- ✅ Tests
- ✅ Linting
- ✅ Scan de seguridad
- ✅ Build de imagen Docker
- ✅ Push a ECR con tag `-prod`
- ✅ Deploy a ECS en cluster `agencias-scotia-prod-cluster`

### 14.3 Verificar deployment

```powershell
# Ver estado del servicio
aws ecs describe-services \
  --cluster agencias-scotia-prod-cluster \
  --services agencias-scotia-prod-service

# Ver logs en CloudWatch
aws logs tail /ecs/agencias-scotia-prod-task --follow
```

---

## PARTE 15: TROUBLESHOOTING COMÚN

### Error: "ModuleNotFoundError: No module named 'fastapi'"

**Solución:**
```powershell
# Asegúrate de que el entorno virtual está activado
.\.venv\Scripts\Activate.ps1

# Reinstala dependencias
pip install -r requirements.txt
```

### Error: "Cannot connect to MySQL"

**Solución:**
```powershell
# Verifica que MySQL está corriendo
docker-compose ps mysql

# Si no está corriendo, inicia los servicios
docker-compose up -d mysql

# Verifica las credenciales en .env
# DATABASE_URL debe ser correcta
```

### Error: "docker: command not found"

**Solución:**
- Instala Docker Desktop desde https://www.docker.com/products/docker-desktop
- Reinicia PowerShell después de instalar

### Error: "Access Denied" en GitHub Actions

**Solución:**
```powershell
# Verifica que el secret AWS_ROLE_TO_ASSUME está configurado
# Y que el role OIDC existe en AWS

# Ver roles disponibles
aws iam list-roles --query 'Roles[?contains(AssumeRolePolicyDocument, `token.actions.githubusercontent.com`)]'
```

### Error: "Terraform plan shows no changes"

**Solución:**
```powershell
# Verifica que estás usando el .tfvars correcto
terraform plan -var-file=terraform.dev.tfvars -refresh=true
```

### Error: "pytest: command not found"

**Solución:**
```powershell
# Instala pytest
pip install pytest pytest-cov

# O en el .venv específico
.\.venv\Scripts\pip install pytest
```

---

## PARTE 16: RECURSOS Y REFERENCIAS

### Archivos importantes del proyecto

- **Código app:** `app/` (routers, modelos, schemas, utilidades)
- **Infraestructura:** `terraform/` (variables.tf, ecs.tf, rds.tf, etc.)
- **Pipelines:** `.github/workflows/ci-cd.yml` y `.github/workflows/terraform-plan.yml`
- **Docker:** `Dockerfile` y `docker-compose.yml`
- **SQL:** `sql/init.sql` (script inicial)
- **Requisitos:** `requirements.txt`

### Enlaces útiles

- **FastAPI Docs:** https://fastapi.tiangolo.com/
- **SQLAlchemy Docs:** https://docs.sqlalchemy.org/
- **Terraform Docs:** https://www.terraform.io/docs/
- **AWS ECS:** https://docs.aws.amazon.com/ecs/
- **GitHub Actions:** https://docs.github.com/en/actions
- **Docker:** https://docs.docker.com/

---

## RESUMEN RÁPIDO DE COMANDOS

### Desarrollo local

```powershell
# Activar entorno virtual
.\.venv\Scripts\Activate.ps1

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar app
uvicorn app.main:app --reload

# Ejecutar tests
pytest app/test/ -v

# Linting
pylint app
```

### Docker

```powershell
# Iniciar servicios
docker-compose up -d

# Ver status
docker-compose ps

# Ver logs
docker-compose logs -f

# Parar
docker-compose down
```

### Terraform

```powershell
cd terraform

# Inicializar
terraform init

# Planificar
terraform plan -var-file=terraform.dev.tfvars

# Aplicar
terraform apply -var-file=terraform.dev.tfvars

# Destruir
terraform destroy -var-file=terraform.dev.tfvars
```

### Git

```powershell
# Crear rama
git checkout -b feature

# Hacer commit
git add .
git commit -m "descripción"

# Push
git push origin feature

# Pull request desde GitHub UI
```

---

**Última actualización:** Diciembre 11, 2025
