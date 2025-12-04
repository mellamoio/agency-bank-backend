from pydantic import BaseModel
from typing import Optional

class AgencyBase(BaseModel):
    name: str
    province: Optional[str] = None
    district: Optional[str] = None
    address: Optional[str] = None
    id_state: int
    part_schedule: Optional[str] = None
    weekend_schedule: Optional[str] = None
    emb: Optional[str] = None


class AgencyCreate(AgencyBase):
    pass


class AgencyUpdate(BaseModel):
    name: Optional[str] = None
    province: Optional[str] = None
    district: Optional[str] = None
    address: Optional[str] = None
    id_state: Optional[int] = None
    part_schedule: Optional[str] = None
    weekend_schedule: Optional[str] = None
    emb: Optional[str] = None


class AgencyResponse(AgencyBase):
    id: int

    model_config = {
        "from_attributes": True
    }
