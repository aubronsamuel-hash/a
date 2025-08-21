Frontend (Vite React)
=====================

## Setup

### Windows

```powershell
.\PS1\web_setup.ps1
.\PS1\web_run.ps1  # http://localhost:5173
```

### Linux/mac

```bash
bash scripts/bash/web_setup.sh
VITE_API_BASE_URL=http://localhost:8001 npm --prefix web run dev
```

## Tests

```powershell
.\PS1\web_test.ps1
```

```bash
bash scripts/bash/web_test.sh
```

## Admin Users

- Visible si `me().role == "admin"`
- Tri/pagination, cache ETag (If-None-Match), indicateur "from cache"

