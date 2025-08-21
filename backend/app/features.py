from __future__ import annotations

from typing import Dict, List, Set

# Catalogue des features reconnues. Ajouter ici pour documenter/valider.

KNOWN_FEATURES: Set[str] = {
    "observability",
    "rate-limit",
    "openapi-export",
    "redis-cache",
    "alembic",
    "cli-docker",
    "security-headers",
    "k6-smoke",
}


def parse_features(env_value: str | None) -> Dict[str, bool]:
    """
    Parse la liste CSV issue de FEATURES_ENABLED.
    - Inconnues ignorees.
    - Espaces ignores.
    - Valeurs vides -> dict vide.
    """
    active: Set[str] = set()
    if env_value:
        for raw in env_value.split(","):
            name = raw.strip()
            if name and name in KNOWN_FEATURES:
                active.add(name)
    return {name: (name in active) for name in sorted(KNOWN_FEATURES)}


def enabled_names(env_value: str | None) -> List[str]:
    d = parse_features(env_value)
    return [k for k, v in d.items() if v]
