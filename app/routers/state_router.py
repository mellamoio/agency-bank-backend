from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.State import State
from app.schemas.state_schema import StateSchema
from app.auth.dependencies import get_current_user
from app.models.User import User

router = APIRouter(prefix="/states", tags=["States"])

@router.get("/", response_model=list[StateSchema])
def get_states(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)   # ← protección
):
    return db.query(State).all()
