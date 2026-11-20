# Supply Chain Security Lab - Makefile
# Targets for validation, building, scanning, and deployment

.PHONY: validate build up scan sbom down

validate:
	@echo "=== Validating configuration files ==="
	./scripts/validate.sh

build:
	@echo "=== Building Docker image ==="
	docker build -t supply-chain-security-lab:latest -t supply-chain-security-lab:1.0.0 -f app/Dockerfile app

up:
	@echo "=== Starting container ==="
	docker run -d --name supply-chain-lab -p 8080:8080 supply-chain-security-lab:latest
	@echo "Container started on port 8080"
	@echo "Waiting for health check..."
	@sleep 5
	@curl -sf http://localhost:8080/healthz || (echo "Health check failed" && exit 1)
	@echo "Health check passed!"

scan:
	@echo "=== Running Trivy security scans ==="
	./scripts/scan-local.sh

sbom:
	@echo "=== Generating SBOM ==="
	# Generate SPDX SBOM using Trivy
	trivy fs --format spdx-json -o evidence/sbom.spdx.json app

down:
	@echo "=== Stopping and removing container ==="
	-docker stop supply-chain-lab
	-docker rm supply-chain-lab
