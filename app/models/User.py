from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class User(Base):
    __tablename__ = "user"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(150), nullable=False)
    email = Column(String(150), nullable=False, unique=True)
    password = Column(String(255), nullable=False)
    photo = Column(String(255))
    cargo = Column(String(100))
    state_id = Column(Integer, ForeignKey("state.id"))

    state = relationship("State", back_populates="users")