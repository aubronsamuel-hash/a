# OAuth2 Google (OIDC)

1. Renseigner .env:

* GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI
* OAUTH_GOOGLE_TEST_MODE=1 pour tester sans Google
* JWT_SECRET defini

2. Demarrer l API et tester:

* GET /auth/google/start -> redirection vers Google (307)
* POST /auth/google/test-callback {email,sub} -> token applicatif (DEV/TEST)

3. Production:

* Desactiver OAUTH_GOOGLE_TEST_MODE
* Implementer l echange code -> tokens via Google (prochaine etape)
