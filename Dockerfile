# ==========================
#   Dockerfile LOCAL
# ==========================
FROM python:3.11-slim

WORKDIR /app

# Dependencias del sistema (por si usas mysqlclient, pillow, etc.)
RUN apt-get update && apt-get install -y build-essential && apt-get clean

# Instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar proyecto
COPY . .

EXPOSE 8000

# Ejecutar FastAPI con recarga automática para desarrollo
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
