import os
import uuid
import io
from botocore.exceptions import NoCredentialsError
from minio import Minio
import boto3

STORAGE_TYPE = os.getenv("STORAGE_TYPE", "minio")  # "minio" por defecto

# ========= AWS =========
AWS_BUCKET = os.getenv("AWS_S3_BUCKET_NAME")
AWS_REGION = os.getenv("AWS_REGION")

# ========= MINIO LOCAL =========
MINIO_ENDPOINT = os.getenv("STORAGE_ENDPOINT")
MINIO_BUCKET = os.getenv("MINIO_BUCKET_NAME")
MINIO_ACCESS = os.getenv("STORAGE_ACCESS_KEY")
MINIO_SECRET = os.getenv("STORAGE_SECRET_KEY")

BASE_URL = os.getenv("LOCAL_S3_BASE_URL")  # base para visualizar archivos en MinIO


def get_client():
    """Retorna client AWS o MinIO según entorno."""

    if STORAGE_TYPE == "aws":
        print("➡ Uso AWS S3")
        return boto3.client(
            "s3",
            aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
            region_name=AWS_REGION
        ), "aws"

    print("➡ Usando MinIO Local")
    return Minio(
        MINIO_ENDPOINT.replace("http://", "").replace("https://", ""),  # limpia endpoint
        access_key=MINIO_ACCESS,
        secret_key=MINIO_SECRET,
        secure=False
    ), "minio"


def upload_file(file, folder="users"):
    """
    Sube un archivo a AWS o MinIO según STORAGE_TYPE
    y devuelve la URL pública del archivo.
    """

    client, mode = get_client()

    file_ext = file.filename.split(".")[-1]
    file_key = f"{folder}/{uuid.uuid4()}.{file_ext}"

    # ============ AWS =============
    if mode == "aws":
        try:
            client.upload_fileobj(
                file.file,
                AWS_BUCKET,
                file_key,
                ExtraArgs={"ContentType": file.content_type}
            )
            return f"https://{AWS_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{file_key}"

        except NoCredentialsError:
            print("❌ Error: Credenciales AWS no configuradas")
            return None

    # ============ MINIO ============
    if not client.bucket_exists(MINIO_BUCKET):
        client.make_bucket(MINIO_BUCKET)

    # leemos el archivo completo
    content = file.file.read()  # <<< necesario para imagen completa

    client.put_object(
        MINIO_BUCKET,
        file_key,
        io.BytesIO(content),
        length=len(content),  # <<< tamaño real del archivo
        content_type=file.content_type
    )

    # URL accesible
    return f"{BASE_URL}/{MINIO_BUCKET}/{file_key}"