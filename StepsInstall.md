# Manual de Instalación - Backend Agencias Scotia

Este documento explica cómo configurar y ejecutar el proyecto backend de agencias Scotia en tu máquina local.

## Requisitos Previos

- Python 3.13 o superior
- Git
- Windows PowerShell 5.1 o superior (o cualquier terminal compatible)

## Pasos de Instalación

### 1. Clonar el Repositorio

```powershell
git clone https://github.com/mellamoio/agency-bank-backend.git
cd backend-agencias-scotia
```

### 2. Crear el Ambiente Virtual

```powershell
python -m venv .venv
```

### 3. Activar el Ambiente Virtual

En **Windows (PowerShell)**:
```powershell
.\.venv\Scripts\Activate.ps1
```

En **Windows (CMD)**:
```cmd
.venv\Scripts\activate.bat
```

En **Linux/macOS**:
```bash
source .venv/bin/activate
```

Después de activar, verás `(.venv)` al inicio de tu terminal.

### 4. Instalar Dependencias

```powershell
pip install -r requirements.txt
```

### 5. Configurar Variables de Entorno

Copia el archivo `.env` y configura las variables necesarias:

```powershell
Copy-Item .env.example .env
```

Abre el archivo `.env` y llena las variables con tus datos:
- `DATABASE_URL`: Conexión a la base de datos
- `AWS_ACCESS_KEY_ID`: Credenciales AWS
- `AWS_SECRET_ACCESS_KEY`: Credenciales AWS
- Otras configuraciones según sea necesario

### 6. Configurar la Base de Datos (Opcional)

Si usas Docker:
```powershell
docker-compose up -d
```

Para inicializar la base de datos manualmente, ejecuta el script SQL:
```powershell
mysql < sql/init.sql
```

## Ejecutar la Aplicación

### Iniciar el Servidor

```powershell
# Con el .venv activado
uvicorn app.main:app --reload
```

El servidor estará disponible en `http://localhost:8000`

### Acceder a la Documentación API

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Ejecutar Tests

```powershell
# Con el .venv activado
pytest
```

Para ver cobertura de tests:
```powershell
pytest --cov=app
```

## Instalar Nuevas Dependencias

### 1. Asegurate que el .venv esté activado:
```powershell
.\.venv\Scripts\Activate.ps1
```

### 2. Instala el paquete:
```powershell
pip install nombre-del-paquete
```

### 3. Actualiza requirements.txt:
```powershell
pip freeze > requirements.txt
```

### 4. Commit los cambios:
```powershell
git add requirements.txt
git commit -m "Add new dependency: nombre-del-paquete"
git push origin feature
```

## Desactivar el Ambiente Virtual

```powershell
deactivate
```

## Estructura del Proyecto

```
backend-agencias-scotia/
├── app/
│   ├── __init__.py
│   ├── main.py                 # Punto de entrada
│   ├── database.py             # Configuración de BD
│   ├── auth/                   # Autenticación y JWT
│   ├── models/                 # Modelos de BD
│   ├── routers/                # Rutas de la API
│   ├── schemas/                # Esquemas Pydantic
│   ├── utils/                  # Utilidades (AWS S3, etc)
│   └── test/                   # Tests unitarios
├── sql/
│   └── init.sql                # Scripts de inicialización BD
├── docker-compose.yml          # Configuración Docker
├── requirements.txt            # Dependencias Python
├── pytest.ini                  # Configuración de tests
└── README.md                   # Documentación principal
```

## Solución de Problemas

### Error: "python" no es reconocido

Usa la ruta completa de Python:
```powershell
C:\Python\python.exe -m venv .venv
```

### Error: El .venv no se activa

Verifica que PowerShell permite ejecutar scripts:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Dependencias no instaladas correctamente

Limpia la caché y reinstala:
```powershell
pip cache purge
pip install -r requirements.txt --force-reinstall
```

### Error de conexión a base de datos

- Verifica que el servidor MySQL está ejecutándose
- Comprueba las credenciales en el archivo `.env`
- Verifica la URL en `DATABASE_URL`

## Información de Contacto

Para reportar problemas o sugerencias, contacta al equipo de desarrollo.

---
**Última actualización:** Diciembre 4, 2025
