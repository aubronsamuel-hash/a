from __future__ import annotations

from pydantic import BaseModel, Field


class UserOut(BaseModel):
    id: int
    username: str
    role: str

    class Config:
        from_attributes = True


class UserCreateIn(BaseModel):
    username: str = Field(min_length=3, max_length=64)
    password: str = Field(min_length=6, max_length=128)


class ChangePasswordIn(BaseModel):
    old_password: str = Field(min_length=6)
    new_password: str = Field(min_length=6, max_length=128)


class PageMeta(BaseModel):
    total: int
    pages: int
    page: int
    page_size: int
    etag: str


class UsersListOut(BaseModel):
    meta: PageMeta
    data: list[UserOut]
