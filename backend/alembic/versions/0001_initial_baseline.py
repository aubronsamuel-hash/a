"""baseline no-op"""
from __future__ import annotations

from alembic import op  # noqa: F401

# Revision identifiers, used by Alembic.
revision = "0001_initial"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Baseline sans modifications; utiliser autogenerate pour schema actuel.
    pass


def downgrade() -> None:
    # Rien a annuler pour la baseline.
    pass
