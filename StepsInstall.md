# Manual de Instalación — agency-bank-backend

Documento para preparar un entorno desde cero y ejecutar el proyecto backend (agency-bank-backend) en Windows, macOS o Linux.

Última actualización: 2025-12-09

---

## Resumen de prerequisitos
- Git (si no está instalado, ver sección Instalación de herramientas)
- Python 3.13+ (incluye pip)
- Entorno de terminal:
  - Windows: PowerShell 5.1+ o CMD
  - Linux/macOS: bash / zsh
- (Opcional) Docker y Docker Compose
- (Opcional) Cliente MySQL para importación de SQL

---

## 1) Instalar herramientas básicas

- Git
  - Windows (winget): winget install --id Git.Git -e --source winget
  - Ubuntu/Debian: sudo apt update && sudo apt install git -y
  - macOS (Homebrew): brew install git
  - Verificar: git --version

- Python (3.13+)
  - Windows: descargar desde https://www.python.org o winget install Python.Python. Asegurarse de marcar "Add to PATH".
  - Ubuntu/Debian: sudo apt install python3 python3-venv python3-pip -y
  - macOS (Homebrew): brew install python
  - Verificar: python --version  (o python3 --version)

- Docker (opcional)
  - Instalar Docker Desktop (Windows/macOS) o docker & docker-compose en Linux.
  - Verificar: docker --version && docker compose version

- Cliente MySQL (opcional)
  - Ubuntu/Debian: sudo apt install mysql-client -y
  - Verificar: mysql --version

---

## 2) Clonar el repositorio

Abre tu terminal preferida y ejecuta:

- PowerShell / CMD / bash:
  git clone https://github.com/mellamoio/agency-bank-backend.git
  cd agency-bank-backend

Nota: reemplaza la URL por la de tu fork/privada si aplica.

---

## 3) Configurar Git (si es la primera vez)

git config --global user.name "Tu Nombre"
git config --global user.email "tu@correo.com"

---

## 4) Crear y activar ambiente virtual (recomendado)

- Windows (PowerShell):
  python -m venv .venv
  .\.venv\Scripts\Activate.ps1

  Si falla la activación por pol. de ejecución:
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

- Windows (CMD):
  python -m venv .venv
  .venv\Scripts\activate.bat

- Linux / macOS (bash):
  python3 -m venv .venv
  source .venv/bin/activate

Verificar que el prompt muestra (.venv) y python apunta al virtualenv:
- Windows PowerShell: Get-Command python
- Linux/macOS: which python

---

## 5) Instalar dependencias Python

Con el venv activado:
pip install --upgrade pip
pip install -r requirements.txt

Si hay problemas con paquetes nativos, instala compiladores/prerequisitos del SO (ej. build-essential en Debian/Ubuntu).

---

## 6) Variables de entorno (.env)

Copiar el ejemplo y editar:
- PowerShell:
  Copy-Item .env.example .env
  notepad .env
- Bash:
  cp .env.example .env
  nano .env

Rellenar las variables necesarias (ej. DATABASE_URL, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, SECRET_KEY, etc.). Asegúrate que DATABASE_URL apunte a la base de datos correcta.

---

## 7) Base de datos

Opción A — Usar Docker (recomendado para desarrollo rápido)
docker compose up -d --build
- Esto levanta servicios definidos en docker-compose.yml (DB, app, etc.). Revisa el archivo para ver nombres de servicios y puertos.

Opción B — Usar DB local/manual
- Crear base de datos y usuarios según .env.
- Importar esquema:
  mysql -u USUARIO -p NOMBRE_BD < sql/init.sql

Asegúrate de que DATABASE_URL en .env está correctamente configurada con host, puerto, usuario y contraseña.

---

## 8) Ejecutar la aplicación localmente (sin Docker)

Con el venv activado y .env configurado:
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

- App disponible en: http://localhost:8000
- Swagger: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

Si el entrypoint difiere, revisa app/main.py y ajusta el comando.

---

## 9) Ejecutar con Docker

Construir y levantar:
docker compose up --build

Para detener:
docker compose down

Para ver logs de un servicio:
docker compose logs -f <service_name>

---

## 10) Ejecutar tests y cobertura

Con el venv activado:
pytest -q

Para cobertura:
pytest --cov=app

Ajusta el directorio de cobertura si la estructura difiere.

---

## 11) Añadir / actualizar dependencias

1. Activar venv.
2. Instalar paquete:
   pip install nombre-paquete
3. Volcar dependencias:
   pip freeze > requirements.txt
4. Commit:
   git add requirements.txt
   git commit -m "chore: add dependencia nombre-paquete"
   git push origin <tu-rama>

---

## 12) Comandos útiles y trucos (Windows específicos)

- Si "python" no es reconocido:
  Usa la ruta completa: C:\Python\python.exe -m venv .venv
- Restablecer permisos de PowerShell:
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
- Forzar reinstalación de requerimientos:
  pip cache purge
  pip install -r requirements.txt --force-reinstall

---

## 13) Solución de problemas comunes

- Error de conexión a BD:
  - Verificar que el servicio MySQL/MariaDB esté corriendo.
  - Revisar DATABASE_URL en .env.
  - Revisar puertos expuestos en docker-compose.yml.

- Problemas con dependencias nativas (compilación):
  - Instalar compiladores / encabezados (build-essential, python-dev, libpq-dev, etc.) según DB o paquetes.

- Permisos al leer .env desde Docker:
  - Asegurar que el archivo .env esté en la ruta correcta y no ignorado por .dockerignore.

---

## 14) Estructura relevante del proyecto

- app/             → código fuente y punto de entrada app.main:app
- sql/init.sql     → scripts de inicialización de BD
- docker-compose.yml, Dockerfile → contenedores
- requirements.txt → dependencias Python
- .env.example     → variables de entorno de ejemplo

---