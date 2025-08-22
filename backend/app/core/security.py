from typing import Any, Dict, List

import jwt
from fastapi import HTTPException, status
from jwt import InvalidTokenError


def decode_jwt(token: str, secret: str, algorithms: List[str]) -> Dict[str, Any]:
    try:
        payload = jwt.decode(token, secret, algorithms=algorithms)
        if not isinstance(payload, dict):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Token invalide"
            )
        return payload
    except InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Token invalide"
        )
