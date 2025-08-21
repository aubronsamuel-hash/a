from __future__ import annotations

import json
import os
from pathlib import Path


def main() -> int:
    # Permettre la configuration simple de la sortie
    out_dir = Path(os.getenv("EXPORT_OPENAPI_DIR", "docs")).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    out_file = out_dir / os.getenv("EXPORT_OPENAPI_FILE", "openapi.json")

    # Import paresseux pour eviter effets secondaires si non necessaire
    from app.main import create_app

    app = create_app()
    spec = app.openapi()
    # Versionner proprement
    # FastAPI ajoute deja info.version; on s assure d avoir title
    if "info" not in spec:
        spec["info"] = {"title": "API", "version": "0.0.0"}

    out_file.write_text(
        json.dumps(spec, ensure_ascii=True, separators=(",", ":")),
        encoding="utf-8",
    )
    print(str(out_file))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
