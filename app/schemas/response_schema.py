from pydantic import BaseModel
from typing import Optional, Any

class ResponseModel(BaseModel):
    status_code: int
    message: str
    data: Optional[Any] = None
