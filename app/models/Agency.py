from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class Agency(Base):
    __tablename__ = "agency"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(150), nullable=False)
    province = Column(String(120))
    district = Column(String(120))
    address = Column(String(255))
    id_state = Column(Integer, ForeignKey("state.id"))
    part_schedule = Column(String(255))
    weekend_schedule = Column(String(255))
    emb = Column(String(50))

    state = relationship("State", back_populates="agencies")