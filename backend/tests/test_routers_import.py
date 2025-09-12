import importlib
import pkgutil

import app


def test_routers_import() -> None:
    imported = []
    for mod in pkgutil.walk_packages(app.__path__, prefix="app."):
        if "routers" in mod.name or "routes" in mod.name:
            importlib.import_module(mod.name)
            imported.append(mod.name)
    assert imported
