from app.version import version as app_version


def test_version_format_semver() -> None:
    parts = app_version.split(".")
    assert len(parts) == 3 and all(p.isdigit() for p in parts), "Version doit etre SemVer X.Y.Z"
