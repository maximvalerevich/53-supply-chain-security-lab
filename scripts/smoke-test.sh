#!/bin/bash
set -e

echo "=== Smoke Testing Container ==="

# Cleanup function
cleanup() {
    echo "=== Cleaning up container ==="
    docker stop supply-chain-lab 2>/dev/null || true
    docker rm supply-chain-lab 2>/dev/null || true
}

# Set trap for cleanup on exit
trap cleanup EXIT

# Build image if needed
if ! docker images supply-chain-security-lab:latest --format '{{.Repository}}:{{.Tag}}' | grep -q "supply-chain-security-lab:latest"; then
    echo "Building image..."
    docker build -t supply-chain-security-lab:latest -f app/Dockerfile app
fi

# Run container
echo "Starting container..."
docker run -d --name supply-chain-lab -p 8080:8080 supply-chain-security-lab:latest

# Wait for container to be healthy
echo "Waiting for container to start..."
for i in {1..30}; do
    if docker ps | grep -q "supply-chain-lab"; then
        echo "Container is running"
        break
    fi
    sleep 1
done

# Test /healthz endpoint
echo "=== Testing /healthz endpoint ==="
HEALTHZ_RESPONSE=$(curl -sf http://localhost:8080/healthz 2>/dev/null)
if [ -n "$HEALTHZ_RESPONSE" ]; then
    echo "✓ /healthz response: $HEALTHZ_RESPONSE"
else
    echo "✗ /healthz endpoint failed"
    exit 1
fi

# Test / endpoint
echo "=== Testing / endpoint ==="
ROOT_RESPONSE=$(curl -sf http://localhost:8080/ 2>/dev/null)
if [ -n "$ROOT_RESPONSE" ]; then
    echo "✓ / response: $ROOT_RESPONSE"
else
    echo "✗ / endpoint failed"
    exit 1
fi

# Verify JSON structure
echo "=== Verifying JSON responses ==="
if echo "$HEALTHZ_RESPONSE" | grep -q '"status"' && echo "$HEALTHZ_RESPONSE" | grep -q '"healthy"'; then
    echo "✓ /healthz contains expected fields"
else
    echo "✗ /healthz response missing expected fields"
    exit 1
fi

if echo "$ROOT_RESPONSE" | grep -q '"name"'; then
    echo "✓ / response contains expected fields"
else
    echo "✗ / response missing expected fields"
    exit 1
fi

echo ""
echo "=== All smoke tests passed ==="

# Keep container running for manual inspection
echo ""
echo "Container is still running on port 8080"
echo "Press Ctrl+C to stop and cleanup..."
trap - EXIT
read -t 60 -p "Waiting 60 seconds for inspection..." || true

# Explicit cleanup
cleanup
