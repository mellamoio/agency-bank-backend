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

```
pip install -r requirements.txt
```

4. Configura variables de entorno:

```
cp .env.example .env  # o crea .env manualmente
```

Edita `/.env` con tus credenciales (DB, AWS, JWT, etc.).

5. Ejecuta la aplicación:

```
uvicorn app.main:app --reload
```

La API estará en `http://localhost:8000`. Documentación disponible en `/docs` y `/redoc`.

## Tests

Ejecuta tests con el entorno virtual activado:

```
pytest
```

## Añadir nuevas dependencias

1. Activa `.venv`.
2. Instala el paquete: `pip install nombre-paquete`.
3. Actualiza `requirements.txt`: `pip freeze > requirements.txt`.
4. Haz commit y push.

## Variables de Entorno importantes

- `DATABASE_URL` - URL de conexión a la base de datos (MySQL)
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` - para S3/MinIO
- `JWT_SECRET_KEY`, `JWT_ALGORITHM` - para auth

Revisa `app/main.py` y `app/database.py` para ver qué variables adicionales son requeridas.

## Docker (opcional)

Si prefieres usar Docker, revisa `docker-compose.yml` y ejecuta:

```
docker-compose up -d
```

## Contribuir

1. Crea una rama nueva desde `feature`.
2. Añade cambios y tests.
3. Haz PR hacia la rama `feature`.

## Recursos y archivos útiles
- Manual de instalación detallado: `INSTALL.md`
- Script SQL de inicialización: `sql/init.sql`

## Contacto
Para dudas o problemas, abre un issue en el repositorio o contacta al autor.

---
Última actualización: Diciembre 5, 2025
