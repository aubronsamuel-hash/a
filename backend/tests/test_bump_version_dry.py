from __future__ import annotations

import pathlib
import subprocess


def _read_version_py() -> str:
    g: dict[str, str] = {}
    exec(pathlib.Path('backend/app/version.py').read_text(encoding='utf-8'), g)
    return g['version']


def _read_pyproject() -> str:
    txt = pathlib.Path('backend/pyproject.toml').read_text(encoding='utf-8')
    for line in txt.splitlines():
        if line.startswith('version = '):
            return line.split('=',1)[1].strip().strip('"')
    raise AssertionError('Version introuvable dans pyproject')


def test_bump_version_patch_dry_run(monkeypatch, tmp_path):
    # Copie de travail
    files = [
        'backend/app/version.py',
        'backend/pyproject.toml',
        'CHANGELOG.md',
        'scripts/bash/bump_version.sh',
    ]
    for p in files:
        src = pathlib.Path(p)
        dst = tmp_path / p
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(src.read_text(encoding='utf-8'), encoding='utf-8')
    # Simuler git (eviter vrai commit)
    (tmp_path/'.git').mkdir()
    monkeypatch.chdir(tmp_path)
    # patch: executer le script mais remplacer git commit par echo
    # on modifie temporairement le script pour echo (minimal, pas de side effects externes)
    sh = tmp_path/'scripts/bash/bump_version.sh'
    content = sh.read_text(encoding='utf-8')
    content = content.replace('git commit -m', 'echo git commit -m')
    content = content.replace('git tag', 'echo git tag')
    sh.write_text(content, encoding='utf-8')

    v0 = _read_version_py()
    subprocess.check_output(['bash','scripts/bash/bump_version.sh','patch'])
    v1 = _read_version_py()
    assert v1 != v0
    assert _read_pyproject() == v1
