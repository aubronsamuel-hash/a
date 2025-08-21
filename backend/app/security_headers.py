from __future__ import annotations

from starlette.types import ASGIApp, Receive, Scope, Send


class SecurityHeadersMiddleware:
    def __init__(self, app: ASGIApp):
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send):
        async def send_wrapper(message):
            if message.get("type") == "http.response.start":
                headers = message.setdefault("headers", [])
                def add(h: str, v: str) -> None:
                    headers.append((h.encode("ascii"), v.encode("ascii")))
                add("x-content-type-options", "nosniff")
                add("x-frame-options", "DENY")
                add("referrer-policy", "no-referrer")
                add("strict-transport-security", "max-age=31536000; includeSubDomains")
                add(
                    "content-security-policy",
                    "default-src 'self'; img-src 'self' data:; "
                    "style-src 'self' 'unsafe-inline'; script-src 'self'",
                )
                add("permissions-policy", "geolocation=(), microphone=(), camera=()")
            await send(message)

        await self.app(scope, receive, send_wrapper)
