from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class State(Base):
    __tablename__ = "state"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)

    users = relationship("User", back_populates="state")
    agencies = relationship("Agency", back_populates="state")