from pydantic import BaseModel

class StateBase(BaseModel):
    name: str

class StateSchema(StateBase):
    id: int
    
    model_config = {
        "from_attributes": True
    }