from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.User import User
from app.schemas.auth_schema import RegisterSchema, LoginSchema, TokenResponse
from app.auth.hash_handler import hash_password, verify_password
from app.auth.jwt_handler import create_access_token
from app.utils.storage import upload_file
import os

router = APIRouter(prefix="/auth", tags=["Auth"])

PLACEHOLDER = os.getenv("AWS_DEFAULT_PLACEHOLDER")

# ------- REGISTER -------
@router.post("/register", response_model=dict)
def register(
    name: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    cargo: str = Form(None),
    photo: UploadFile = File(None),
    db: Session = Depends(get_db)
):
    # Verificar si el email ya está registrado
    if db.query(User).filter(User.email == email).first():
        raise HTTPException(status_code=400, detail="El email ya está registrado")

    # Manejo de foto
    if photo:
        photo_url = upload_file(photo)
    else:
        photo_url = PLACEHOLDER

    # Crear usuario con state_id por defecto = 1
    new_user = User(
        name=name,
        email=email,
        password=hash_password(password),
        cargo=cargo,
        state_id=1,
        photo=photo_url
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # Crear token
    token = create_access_token({"sub": new_user.id})

    # Respuesta estándar
    return {
        "message": "Usuario registrado correctamente",
        "code": 201,
        "access_token": token
    }




# ------- LOGIN -------
@router.post("/login", response_model=TokenResponse)
def login(data: LoginSchema, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()

    if not user or not verify_password(data.password, user.password):
        raise HTTPException(status_code=400, detail="Credenciales inválidas")

    token = create_access_token({"sub": user.id})

    return TokenResponse(access_token=token)
