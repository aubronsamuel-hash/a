from __future__ import annotations

from alembic import op
import sqlalchemy as sa

# revision identifiers
revision = "20250821_0003"
down_revision = "20250820_0002"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "users",
        sa.Column("updated_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
    )


def downgrade() -> None:
    op.drop_column("users", "updated_at")
