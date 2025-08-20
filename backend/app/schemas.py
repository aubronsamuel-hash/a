from __future__ import annotations

from pydantic import BaseModel, Field


class UserOut(BaseModel):
    id: int
    username: str
    role: str

    class Config:
        from_attributes = True


class UserCreateIn(BaseModel):
    username: str = Field(min_length=2, max_length=64)
    password: str = Field(min_length=6, max_length=128)


class ChangePasswordIn(BaseModel):
    old_password: str = Field(min_length=1)
    new_password: str = Field(min_length=6, max_length=128)
