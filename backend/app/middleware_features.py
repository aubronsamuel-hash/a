from __future__ import annotations

import os
from starlette.types import ASGIApp, Receive, Scope, Send

from .features import enabled_names


class FeaturesHeaderMiddleware:
    def __init__(self, app: ASGIApp) -> None:
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope.get("type") != "http":
            await self.app(scope, receive, send)
            return

        async def send_wrapper(message):
            if message["type"] == "http.response.start":
                feats = enabled_names(os.getenv("FEATURES_ENABLED"))
                header_val = ",".join(feats) if feats else ""
                headers = message.get("headers", [])
                headers.append((b"x-features", header_val.encode("utf-8")))
                message["headers"] = headers
            await send(message)

        await self.app(scope, receive, send_wrapper)
