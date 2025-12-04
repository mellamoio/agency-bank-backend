from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.Agency import Agency
from app.models.User import User
from app.auth.dependencies import get_current_user
from app.schemas.agency_schema import (
    AgencyCreate,
    AgencyUpdate,
    AgencyResponse
)

router = APIRouter(prefix="/agencies", tags=["Agencies"])


# -------- CREATE --------
@router.post("/", response_model=dict)
def create_agency(
    data: AgencyCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    existing = db.query(Agency).filter(Agency.name == data.name).first()
    if existing:
        raise HTTPException(status_code=400, detail="Ya existe una agencia con ese nombre")

    agency = Agency(**data.dict())

    db.add(agency)
    db.commit()
    db.refresh(agency)

    return {
        "message": "Agencia creada correctamente",
        "code": 201,
        "data": AgencyResponse.model_validate(agency)
    }


# -------- LIST ALL --------
@router.get("/", response_model=dict)
def get_agencies(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    agencies = db.query(Agency).all()

    return {
        "message": "Listado de agencias",
        "code": 200,
        "data": [AgencyResponse.model_validate(a) for a in agencies]
    }


# --------- LIST PUBLIC ---------
@router.get("/public", response_model=list[dict], tags=["Public"])
def get_agencies_public(db: Session = Depends(get_db)):
    agencies = db.query(Agency).all()

    result = []

    for a in agencies:
        result.append({
            "Nom": a.name,
            "Dep": a.province,
            "Dis": a.district,
            "Dir": a.address,
            "Est": a.state.name if a.state else "",   # ← Estado real
            "Hor": a.part_schedule,
            "Sab": a.weekend_schedule,
            "Emb": a.emb
        })

    return result


# -------- GET ONE --------
@router.get("/{agency_id}", response_model=dict)
def get_agency(
    agency_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    agency = db.query(Agency).filter(Agency.id == agency_id).first()

    if not agency:
        raise HTTPException(status_code=404, detail="Agencia no encontrada")

    return {
        "message": "Agencia encontrada",
        "code": 200,
        "data": AgencyResponse.model_validate(agency)
    }


# -------- UPDATE --------
@router.put("/{agency_id}", response_model=dict)
def update_agency(
    agency_id: int,
    data: AgencyUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    agency = db.query(Agency).filter(Agency.id == agency_id).first()

    if not agency:
        raise HTTPException(status_code=404, detail="Agencia no encontrada")

    for key, value in data.dict(exclude_unset=True).items():
        setattr(agency, key, value)

    db.commit()
    db.refresh(agency)

    return {
        "message": "Agencia actualizada correctamente",
        "code": 200,
        "data": AgencyResponse.model_validate(agency)
    }


# -------- DELETE --------
@router.delete("/{agency_id}", response_model=dict)
def delete_agency(
    agency_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):

    agency = db.query(Agency).filter(Agency.id == agency_id).first()

    if not agency:
        raise HTTPException(status_code=404, detail="Agencia no encontrada")

    db.delete(agency)
    db.commit()

    return {
        "message": "Agencia eliminada correctamente",
        "code": 200
    }
