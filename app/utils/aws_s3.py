import boto3
import uuid
from botocore.exceptions import NoCredentialsError
import os

AWS_BUCKET = os.getenv("AWS_S3_BUCKET_NAME")
AWS_REGION = os.getenv("AWS_REGION")


def upload_file_to_s3(file, folder="users"):
    """
    Sube un archivo a S3 y devuelve la URL pública.
    """
    try:
        s3 = boto3.client(
            "s3",
            aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
            aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
            region_name=AWS_REGION
        )

        file_extension = file.filename.split(".")[-1]
        file_key = f"{folder}/{uuid.uuid4()}.{file_extension}"

        s3.upload_fileobj(
            file.file,
            AWS_BUCKET,
            file_key,
            ExtraArgs={"ContentType": file.content_type}
        )

        return f"https://{AWS_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{file_key}"

    except NoCredentialsError:
        print("Error: No AWS credentials found")
        return None
