param()

# Active venv si besoin
if (Test-Path ".venv/Scripts/Activate.ps1") { . ".venv/Scripts/Activate.ps1" }

# Applique env calcule
& $PSScriptRoot/set_env.ps1 | Out-Null

# Lance gunicorn
$env:PYTHONPATH = "backend"
python -m gunicorn -c backend/gunicorn_conf.py backend.app.main:app
