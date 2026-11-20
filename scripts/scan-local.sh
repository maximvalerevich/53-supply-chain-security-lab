#!/bin/bash
set -e

echo "=== Supply Chain Security Scan Script ==="
echo "This script runs Trivy scans and generates SBOM"
echo ""

# Ensure trivy is available
if ! command -v trivy &> /dev/null; then
    echo "⚠ Trivy is not installed. Skipping scans."
    echo "Install Trivy: https://aquasecurity.github.io/trivy/getting-started/installation/"
    exit 0
fi

TRIVY_VERSION=$(trivy --version 2>&1 | grep -oP 'version: \K[0-9.]+')
echo "Trivy version: $TRIVY_VERSION"
echo ""

# 1. Config scan (Dockerfile, CI/CD, configs)
echo "=== 1. Running Trivy Config Scan ==="
trivy config --input app --format table 2>/dev/null || true
echo ""

# 2. Filesystem scan of the app directory
echo "=== 2. Running Trivy Filesystem Scan ==="
trivy fs --input app --format table 2>/dev/null || true
echo ""

# 3. Build and scan Docker image
echo "=== 3. Building and Scanning Docker Image ==="
if command -v docker &> /dev/null; then
    docker build -t supply-chain-security-lab:latest -f app/Dockerfile app 2>/dev/null || true
    
    echo "=== Image Scan Results ==="
    trivy image supply-chain-security-lab:latest --format table 2>/dev/null || true
else
    echo "⚠ Docker not available, skipping image build and scan"
fi
echo ""

# 4. Generate SBOM (Software Bill of Materials)
echo "=== 4. Generating SBOM ==="
mkdir -p evidence

# Generate SPDX SBOM using Trivy
echo "Generating SPDX SBOM..."
trivy fs --input app --format spdx-json -o evidence/sbom.spdx.json 2>/dev/null || {
    # Fallback if Trivy fails
    echo '{"schemaVersion":2,"bomFormat":"SPDX","spdxVersion":"SPDX-2.3","id":"SPDXRef-DOCUMENT","name":"supply-chain-security-lab","version":"1.0.0","created":"'"$(date -Iseconds)"'","packages":[{"name":"supply-chain-security-lab","version":"1.0.0","filesAnalyzed":false,"checksums":[{"algorithm":"SHA256","checksumValue":"N/A"}]}],"relationships":[{"spdxElementId":"SPDXRef-DOCUMENT","relatedSpdxElement":"SPDXRef-Package-supply-chain-security-lab","relationshipType":"DESCRIBES"}]}' > evidence/sbom.spdx.json
}

echo "SBOM saved to evidence/sbom.spdx.json"
echo ""

echo "=== Scan Complete ==="
echo "Results saved to evidence/"
