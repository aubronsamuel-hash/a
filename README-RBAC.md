# RBAC par routes (roles)

* Ajoute des dependances FastAPI:
  * get_current_principal: decode JWT (Bearer), 401 si manquant/invalide
  * require_roles([roles]): 403 si aucun des roles requis n est present
* Endpoints d exemple:
  * GET /me/ping -> auth requise (n importe quel role)
  * GET /admin/ping -> role "admin" requis

Tests:

* PYTHONPATH=backend pytest -q backend/tests/test_rbac.py
  Attendu: 4 passed

Scripts Windows/Bash:

* Generer un token admin et tester /admin/ping
  .\scripts\ps1\rbac\test_admin_ok.ps1 -BaseUrl http://localhost:8000 -Secret <votre_secret>
* Tester KO (403)
  .\scripts\ps1\rbac\test_admin_ko.ps1 -BaseUrl http://localhost:8000 -Secret <votre_secret>

Notes:

* Les roles sont verifies par intersection (OR logique). Pour exiger plusieurs roles simultanes, etendre la fonction require_roles selon besoin.
* Integration avec un modele User/DB et mappage des roles viendra dans une etape ulterieure.
