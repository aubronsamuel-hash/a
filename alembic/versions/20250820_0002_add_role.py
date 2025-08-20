from __future__ import annotations

from alembic import op
import sqlalchemy as sa

# revision identifiers

revision = "20250820_0002"
down_revision = "20250820_0001"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("role", sa.String(length=16), nullable=False, server_default="user"))
    op.execute("UPDATE users SET role='admin' WHERE username='admin'")


def downgrade() -> None:
    op.drop_column("users", "role")

