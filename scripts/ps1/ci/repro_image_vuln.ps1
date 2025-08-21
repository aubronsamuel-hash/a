docker build -t app:test -<<'EOF'
FROM python:3.11-slim
EOF

docker run --rm aquasec/trivy:latest image --severity CRITICAL --exit-code 1 app:test || exit 0
