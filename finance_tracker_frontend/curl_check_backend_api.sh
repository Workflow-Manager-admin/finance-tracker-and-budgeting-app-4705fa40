#!/bin/bash

# Test registration endpoint on backend (should reply 200/4xx, check for CORS/network failures)
echo "=== Checking backend REGISTRATION endpoint (cloud backend) ==="
curl -i -X POST "https://vscode-internal-4831-beta.beta01.cloud.kavia.ai:3001/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass"}'
echo

# Test backend root endpoint (Health check)
echo "=== Checking backend HEALTH endpoint (cloud backend) ==="
curl -i "https://vscode-internal-4831-beta.beta01.cloud.kavia.ai:3001/"
echo

# Test emulator default endpoint (should fail if backend not running there)
echo "=== Checking EMULATOR DEFAULT endpoint (10.0.2.2:8000) ==="
curl -m 9 -i "http://10.0.2.2:8000/"
echo

echo "=== Script complete. ==="
