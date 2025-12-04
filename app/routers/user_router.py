from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.User import User
from app.schemas.user_schema import UserResponse
from app.auth.dependencies import get_current_user
from app.auth.hash_handler import hash_password
from app.utils.aws_s3 import upload_file_to_s3
import os

router = APIRouter(prefix="/users", tags=["Users"])

PLACEHOLDER = os.getenv("AWS_DEFAULT_PLACEHOLDER")


# ---------- LISTAR TODOS ----------
@router.get("/", response_model=list[UserResponse])
def get_users(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return db.query(User).all()


# ---------- OBTENER POR ID ----------
@router.get("/{user_id}", response_model=UserResponse)
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return UserResponse.model_validate(user)


# ---------- CREAR USUARIO ----------
@router.post("/", response_model=dict)
def create_user(
    name: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    cargo: str = Form(None),
    state_id: int = Form(...),
    photo: UploadFile = File(None),
    db: Session = Depends(get_db)
):

    if db.query(User).filter(User.email == email).first():
        raise HTTPException(status_code=400, detail="El email ya está registrado")

    # Manejo de foto
    if photo:
        photo_url = upload_file_to_s3(photo)
    else:
        photo_url = PLACEHOLDER

    new_user = User(
        name=name,
        email=email,
        password=hash_password(password),
        cargo=cargo,
        state_id=state_id,
        photo=photo_url
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {
        "message": "Usuario creado correctamente",
        "code": 201,
        "data": UserResponse.model_validate(new_user)
    }


# ---------- ACTUALIZAR USUARIO ----------
@router.put("/{user_id}", response_model=dict)
def update_user(
    user_id: int,
    name: str = Form(None),
    cargo: str = Form(None),
    state_id: int = Form(None),
    photo: UploadFile = File(None),
    db: Session = Depends(get_db)
):

    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    # Si viene foto → subir
    if photo:
        user.photo = upload_file_to_s3(photo)

    if name:
        user.name = name
    if cargo:
        user.cargo = cargo
    if state_id:
        user.state_id = state_id

    db.commit()
    db.refresh(user)

    return {
        "message": "Usuario actualizado correctamente",
        "code": 200,
        "data": UserResponse.model_validate(user)
    }


# ---------- ELIMINAR USUARIO RUTA ----------
@router.delete("/{user_id}", response_model=dict)
def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    db.delete(user)
    db.commit()

    return {
        "message": "Usuario eliminado correctamente",
        "code": 200
    }
