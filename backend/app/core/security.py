from typing import Any, Dict, List

import jwt
from jwt import InvalidTokenError
from fastapi import HTTPException, status


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
