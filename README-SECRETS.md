# Secrets Management (SOPS + age + Gitleaks)

## age keys

* Windows: .\\scripts\\ps1\\secrets\\gen_age_keys.ps1
* Bash: ./scripts/bash/secrets/gen_age_keys.sh
  Ajouter la cle publique dans .sops.yaml. Exporter SOPS_AGE_KEY_FILE vers la cle privee pour decrypter.

## Chiffrer / Dechiffrer

* Encrypt: .\\scripts\\ps1\\secrets\\sops_encrypt.ps1 -In secrets/plain.yaml -Out secrets/app.enc.yaml -AgePub age1...
* Decrypt: $env:SOPS_AGE_KEY_FILE=keys/age/agekey.txt ; .\\scripts\\ps1\\secrets\\sops_decrypt.ps1 -In secrets/app.enc.yaml -Out secrets/app.dec.yaml

## Rotation JWT (dev)

* .\\scripts\\ps1\\secrets\\rotate_jwt_secret.ps1 -EnvFile .env.dev
* Staging/Prod: mettre a jour le secret dans GitHub Secrets ou un store et redeployer.

## CI scan

* Workflow scan-secrets Gitleaks bloque les fuites accidentelles.

Tests:

* OK: .\\scripts\\ps1\\secrets\\test_roundtrip_ok.ps1 (si sops + age installes)
* KO: .\\scripts\\ps1\\secrets\\test_decrypt_ko.ps1
