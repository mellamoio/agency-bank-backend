from fastapi import FastAPI
from app.routers import state_router, auth_router, user_router, agency_router
from app.database import Base, engine

app = FastAPI()


@app.on_event("startup")
def startup_event():
    print("⚙️ Creando tablas en la base de datos si no existen…")
    Base.metadata.create_all(bind=engine)

app.include_router(auth_router.router)
app.include_router(state_router.router)
app.include_router(user_router.router)
app.include_router(agency_router.router)

@app.get("/")
def root():
    return {"message": "API funcionando correctamente"}

@app.get("/health")
def health():
    return {"status": "ok"}