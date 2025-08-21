# syntax=docker/dockerfile:1.7

# Stage 1: build front
FROM node:20-alpine AS webbuild
WORKDIR /web
COPY web/package*.json ./
RUN npm ci
COPY web/ .
RUN npm run build

# Stage 2: runtime python + app
FROM python:3.11-slim AS runtime
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*

# Backend source
COPY backend /app/backend

# Deps (runtime)
RUN python -m pip install --upgrade pip && pip install -e backend

# Front dist
COPY --from=webbuild /web/dist /app/public

# Default env (override via -e)
ENV FRONT_DIST_DIR=/app/public \
    APP_HOST=0.0.0.0 \
    APP_PORT=8001 \
    ADMIN_AUTOSEED=true \
    ADMIN_USERNAME=admin \
    ADMIN_PASSWORD=admin123
EXPOSE 8001
HEALTHCHECK --interval=10s --timeout=3s --retries=10 CMD curl -fsS http://localhost:8001/healthz || exit 1
CMD ["python","-m","uvicorn","app.main:app","--app-dir","backend","--host","0.0.0.0","--port","8001"]
