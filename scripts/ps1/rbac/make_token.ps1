param(
[string]$Sub = "u-local",
[string]$Roles = "user",
[string]$Secret = "change_me",
[string]$Algo = "HS256"
)

# Utilise Python pour generer un JWT (PyJWT doit etre installe)

$code = @'
import os, sys, json, jwt
sub, roles, secret, algo = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
roles_list = [r.strip() for r in roles.split(',') if r.strip()]
payload = {"sub": sub, "roles": roles_list}
print(jwt.encode(payload, secret, algorithm=algo))
'@
python - <<PY $Sub $Roles $Secret $Algo
$code
PY
