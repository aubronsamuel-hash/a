import pathlib

def test_backend_healthcheck_uses_python():
    compose = pathlib.Path(__file__).resolve().parents[2] / "docker-compose.observability.yml"
    text = compose.read_text()
    assert "python - <<'PY'" in text
