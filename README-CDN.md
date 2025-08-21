# CDN / Cache HTTP

* Headers added: Cache-Control (1 year + immutable), ETag, Content-Encoding (gzip/br).
* Test Windows:
  .\scripts\ps1\cdn\test_headers.ps1 -Url http://localhost/app.js
* Test Bash:
  ./scripts/bash/cdn/test_headers.sh http://localhost/app.js
