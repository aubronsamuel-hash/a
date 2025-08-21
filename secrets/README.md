# Secrets chiffres (SOPS + age)

* Tous les secrets doivent etre places dans ce dossier et chiffres: *.enc.yaml / *.enc.json / *.enc.toml
* Le repo ne doit PAS contenir de cle privee. Stocker la cle age privee en dehors du repo (ex: keys/age/agekey.txt) et non committe.
* Decrypt: export SOPS_AGE_KEY_FILE=chemin_vers_cle_privee

Exemples de fichiers:

* secrets/app.enc.yaml (chiffre SOPS)

NE PAS COMMITTER des .env reelles.
