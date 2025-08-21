from __future__ import annotations

import os
import secrets

from starlette.types import ASGIApp, Receive, Scope, Send


def _env_bool(name: str, default: bool) -> bool:
    v = os.getenv(name)
    if v is None:
        return default
    return v.lower() == "true"


def _env(name: str, default: str) -> str:
    return os.getenv(name, default)


class SecurityHeadersMiddleware:
    def __init__(self, app: ASGIApp) -> None:
        self.app = app
        self.enabled = _env_bool("SEC_HEADERS_ENABLE", True)

        # CSP parts
        self.csp_default = _env("CSP_DEFAULT_SRC", "self")
        self.csp_script = _env("CSP_SCRIPT_SRC", "self")
        self.csp_style = _env("CSP_STYLE_SRC", "self")
        self.csp_img = _env("CSP_IMG_SRC", "self data:")
        self.csp_font = _env("CSP_FONT_SRC", "self data:")
        self.csp_connect = _env("CSP_CONNECT_SRC", "self")
        self.csp_frame = _env("CSP_FRAME_SRC", "none")
        self.csp_allow_unsafe_inline = _env_bool("CSP_ALLOW_UNSAFE_INLINE", False)

        # HSTS
        self.hsts_enable = _env_bool("HSTS_ENABLE", False)
        self.hsts_max_age = int(_env("HSTS_MAX_AGE", "15552000"))
        self.hsts_include_sub = _env_bool("HSTS_INCLUDE_SUBDOMAINS", True)
        self.hsts_preload = _env_bool("HSTS_PRELOAD", False)

        # Others
        self.referrer_policy = _env("REFERRER_POLICY", "strict-origin-when-cross-origin")
        self.x_frame_options = _env("X_FRAME_OPTIONS", "DENY")
        self.permissions_policy = _env(
            "PERMISSIONS_POLICY", "geolocation=(), microphone=(), camera=()"
        )

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http" or not self.enabled:
            await self.app(scope, receive, send)
            return

        # Nonce pour scripts inline
        nonce = secrets.token_urlsafe(16)
        scope.setdefault("state", {})
        scope["state"]["csp_nonce"] = nonce

        async def send_wrapper(message):
            if message["type"] == "http.response.start":
                headers = {k.decode().lower(): v.decode() for (k, v) in message.get("headers", [])}

                # CSP
                csp_parts: list[str] = []

                def _src(v: str) -> str:
                    return "'self'" if v.strip() == "self" else v.strip()

                csp_parts.append(f"default-src {_src(self.csp_default)}")

                script_src_val = _src(self.csp_script)
                nonce_part = f"'nonce-{nonce}'"
                if self.csp_allow_unsafe_inline:
                    script_src_val = f"{script_src_val} 'unsafe-inline'"
                script_src_val = f"{script_src_val} {nonce_part}"
                csp_parts.append(f"script-src {script_src_val}")

                csp_parts.append(f"style-src {_src(self.csp_style)}")
                csp_parts.append(f"img-src {_src(self.csp_img)}")
                csp_parts.append(f"font-src {_src(self.csp_font)}")
                csp_parts.append(f"connect-src {_src(self.csp_connect)}")
                csp_parts.append(f"frame-src {_src(self.csp_frame)}")

                headers["content-security-policy"] = "; ".join(csp_parts)

                # HSTS (uniquement pertinent en HTTPS)
                if self.hsts_enable:
                    hsts = f"max-age={self.hsts_max_age}"
                    if self.hsts_include_sub:
                        hsts += "; includeSubDomains"
                    if self.hsts_preload:
                        hsts += "; preload"
                    headers["strict-transport-security"] = hsts

                headers.setdefault("x-content-type-options", "nosniff")
                headers.setdefault("referrer-policy", self.referrer_policy)
                headers.setdefault("x-frame-options", self.x_frame_options)
                headers.setdefault("permissions-policy", self.permissions_policy)

                message["headers"] = [(k.encode(), v.encode()) for k, v in headers.items()]
            await send(message)

        await self.app(scope, receive, send_wrapper)

