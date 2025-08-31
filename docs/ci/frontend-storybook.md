# CI Frontend: Storybook (monorepo)

## Contrainte
Le lockfile est sous `frontend/package-lock.json`.
Le cache integre de `actions/setup-node@v4` (`cache: npm`) peut echouer avec:
> Some specified paths were not resolved, unable to cache dependencies.

## Solution robuste
- Utiliser `actions/cache@v4` sur `~/.npm` avec une cle basee sur `frontend/package-lock.json`.
- Forcer `NPM_CONFIG_CACHE=~/.npm` pendant `npm ci`.

Extrait:

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'

- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('frontend/package-lock.json') }}

- run: npm ci --no-audit --no-fund
  env:
    NPM_CONFIG_CACHE: ~/.npm
```

Smoke
Servir storybook-static et curl sur 6006 pour un 200.

