from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv
import os

load_dotenv()

# Modo Docker usa DATABASE_URL, local arma string
if os.getenv("DATABASE_URL"):
    DATABASE_URL = os.getenv("DATABASE_URL")
else:
    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_HOST = os.getenv("DB_HOST", "localhost")
    DB_PORT = os.getenv("DB_PORT", "3306")
    DB_NAME = os.getenv("DB_NAME")

    DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

engine = create_engine(DATABASE_URL, pool_pre_ping=True)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

from app.models.User import User
from app.models.State import State
from app.models.Agency import Agency

print(f"📌 Conectado a Base de Datos en: {DATABASE_URL}")

# ==================== Funciones de inicialización ====================

def init_db():
    """Crea todas las tablas en la base de datos"""
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Tablas creadas exitosamente")
    except Exception as e:
        print(f"❌ Error al crear tablas: {e}")

def seed_states():
    """Inserta los estados iniciales (Activo/Inactivo)"""
    db = SessionLocal()
    try:
        # Verifica si ya existen estados
        existing_count = db.query(State).count()
        if existing_count > 0:
            print(f"⚠️  Ya existen {existing_count} estados en la BD, omitiendo seed")
            return
        
        # Inserta los 2 estados
        states = [
            State(id=1, name="Activo"),
            State(id=2, name="Inactivo")
        ]
        
        db.add_all(states)
        db.commit()
        print(f"✅ {len(states)} estados insertados correctamente")
        
    except Exception as e:
        print(f"❌ Error al insertar estados: {e}")
        db.rollback()
    finally:
        db.close()

def seed_all():
    """Ejecuta todos los seeds en orden"""
    print("🌱 Iniciando seed de datos...")
    seed_states()
    # Aquí puedes agregar más seeds si necesitas
    # seed_agencies()
    # seed_users()
    print("✅ Seed completado")