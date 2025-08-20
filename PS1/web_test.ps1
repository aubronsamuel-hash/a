$ErrorActionPreference = "Stop"
Push-Location web
npm run lint
npm test
Pop-Location
