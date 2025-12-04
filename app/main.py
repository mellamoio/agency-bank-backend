from fastapi import FastAPI
from app.routers import state_router, auth_router, user_router, agency_router

app = FastAPI()

app.include_router(auth_router.router)
app.include_router(state_router.router)
app.include_router(user_router.router)
app.include_router(agency_router.router)


@app.get("/")
def root():
    return {"message": "API funcionando correctamente"}