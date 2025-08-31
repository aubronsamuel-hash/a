# CI front: Storybook

- Contexte: monorepo, lockfile sous `frontend/package-lock.json`.
- Action: `actions/setup-node@v4` avec `cache: npm` DOIT pointer `cache-dependency-path: frontend/package-lock.json`.
- Jobs: build storybook, probe HTTP, bundle budget (size-limit).

## Commandes locales

pwsh -NoLogo -NoProfile -File PS1/repro_storybook_ci_lock.ps1

## Notes
- Ne pas deplacer le lockfile a la racine sans convertir le repo en workspace npm complet.
- Zero secret dans workflows.
