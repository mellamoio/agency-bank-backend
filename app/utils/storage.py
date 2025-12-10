import os
import uuid
import io
from botocore.exceptions import NoCredentialsError
from minio import Minio
import boto3

# ==============================
# ⚙ Configuración general
# ==============================
STORAGE_TYPE = os.getenv("STORAGE_TYPE", "minio").lower()  # "minio" por defecto



# ==============================
# 🌩 AWS S3 PRODUCCIÓN
# ==============================
AWS_BUCKET = os.getenv("AWS_S3_BUCKET")
AWS_REGION = os.getenv("AWS_REGION")
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")


# ==============================
# 📦 Minio LOCAL
# ==============================
MINIO_ENDPOINT = os.getenv("STORAGE_ENDPOINT", "minio:9000")   # coincide con tu compose
MINIO_BUCKET = os.getenv("MINIO_BUCKET_NAME")
MINIO_ACCESS = os.getenv("STORAGE_ACCESS_KEY")
MINIO_SECRET = os.getenv("STORAGE_SECRET_KEY")

# Base URL correcta para servir archivos MinIO
LOCAL_BASE_URL = os.getenv("LOCAL_S3_BASE_URL", f"http://{MINIO_ENDPOINT}")


# =================================================
# CLIENTE según entorno
# =================================================
def get_client():
    """Retorna cliente AWS o MinIO según variable STORAGE_TYPE."""

    # ---------------- AWS ----------------
    if STORAGE_TYPE == "s3":
        print("⚡ Usando AWS S3")
        return boto3.client(
            "s3",
            aws_access_key_id=AWS_ACCESS_KEY,
            aws_secret_access_key=AWS_SECRET_KEY,
            region_name=AWS_REGION
        ), "s3"

    # ---------------- Minio LOCAL ----------------
    print("💾 Usando MinIO local")
    endpoint = MINIO_ENDPOINT.replace("http://", "").replace("https://", "")
    return Minio(endpoint, MINIO_ACCESS, MINIO_SECRET, secure=False), "minio"



# =================================================
# SUBIDA DE ARCHIVOS
# =================================================
def upload_file(file, folder="profiles"):
    """
    Guarda archivo en AWS o MinIO y retorna URL pública
    """

    client, mode = get_client()
    file_ext = file.filename.split(".")[-1]
    file_key = f"{folder}/{uuid.uuid4()}.{file_ext}"


    # ---------------- AWS S3 ----------------
    if mode == "s3":
        try:
            client.upload_fileobj(
                file.file,
                AWS_BUCKET,
                file_key,
                ExtraArgs={"ContentType": file.content_type}
            )

            return f"https://{AWS_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{file_key}"

        except NoCredentialsError:
            print("❌ Credenciales AWS no configuradas")
            return None


    # ---------------- MinIO 🏠 LOCAL ----------------
    if not client.bucket_exists(MINIO_BUCKET):
        client.make_bucket(MINIO_BUCKET)

    content = file.file.read()  # necesario para cargar archivo completo

    client.put_object(
        MINIO_BUCKET,
        file_key,
        io.BytesIO(content),
        len(content),
        content_type=file.content_type
    )

    # URL accesible correctamente estructurada
    return f"{LOCAL_BASE_URL}/{file_key}"
