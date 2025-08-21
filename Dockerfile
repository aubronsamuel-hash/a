# syntax=docker/dockerfile:1

# Etape Builder
FROM python:3.11-slim AS builder
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# deps build minimales (si besoin pour wheels)
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*

# Copier uniquement le backend pour installer la lib
COPY backend/ ./backend/

# Installer en mode paquet (PAS editable) pour generer console_scripts dans /usr/local/bin
RUN python -m pip install --upgrade pip && \
    python -m pip install --no-cache-dir ./backend

# Etape Runtime
FROM python:3.11-slim AS runtime
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/usr/local/bin:${PATH}"

# Copier uniquement ce qui est necessaire a l exec (paquet deja dans layer base)
COPY --from=builder /usr/local /usr/local

# Source app (pour assets/public si besoin et import runtime)
COPY backend/ ./backend/

# Front (si present) pour servir via FRONT_DIST_DIR
COPY web/dist/ ./public/

# Defaults (overridables)
ENV APP_HOST=0.0.0.0 \
    APP_PORT=8001 \
    FRONT_DIST_DIR=/app/public
EXPOSE 8001

# CMD par defaut (overridable par `docker run image ccadmin ...`)
CMD ["python","-m","uvicorn","app.main:app","--app-dir","backend","--host","0.0.0.0","--port","8001"]
