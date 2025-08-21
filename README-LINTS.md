# Lints Python (ruff + mypy)

## Local (Windows)

* Ruff: `.\scripts\ps1\lint\run_ruff.ps1`
* MyPy: `.\scripts\ps1\lint\run_mypy.ps1`
* Tests:

  * OK: `.\scripts\ps1\lint\test_ok.ps1`
  * KO: `.\scripts\ps1\lint\test_ko.ps1`

## CI

Workflow `.github/workflows/lint-python.yml`:

* Install ruff/mypy
* `ruff check .`
* `mypy backend`

## Notes

* `ignore_missing_imports=true` pour eviter le bruit (FastAPI, PyJWT, etc.) dans cette phase.
* On pourra durcir progressivement (disallow_untyped_defs=true) plus tard.

## .env.example (rappel)

# Aucun changement requis pour lints
