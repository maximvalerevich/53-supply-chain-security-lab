#!/bin/bash
set -e

echo "=== Running validation checks ==="

# Validate Dockerfile syntax
if command -v docker &> /dev/null; then
    echo "✓ Docker is available"
    # Basic syntax validation - check for common issues
    if grep -q "FROM" app/Dockerfile && grep -q "EXPOSE" app/Dockerfile; then
        echo "✓ Dockerfile contains required instructions (FROM, EXPOSE)"
    else
        echo "✗ Dockerfile missing required instructions"
        exit 1
    fi
else
    echo "⚠ Docker not available, skipping Dockerfile validation"
fi

# Validate package.json syntax
if command -v node &> /dev/null; then
    echo "✓ Node.js is available"
    if node -e "JSON.parse(require('fs').readFileSync('app/package.json'))" 2>/dev/null; then
        echo "✓ package.json is valid JSON"
    else
        echo "✗ package.json has invalid JSON syntax"
        exit 1
    fi
else
    echo "⚠ Node.js not available, skipping package.json validation"
fi

# Validate JavaScript syntax
if command -v node &> /dev/null; then
    echo "✓ Validating server.js syntax"
    if node --check app/server.js 2>/dev/null; then
        echo "✓ server.js syntax is valid"
    else
        echo "✗ server.js has syntax errors"
        exit 1
    fi
fi

echo "=== All validations passed ==="
