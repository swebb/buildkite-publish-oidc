#!/bin/bash
set -euo pipefail

ORG="steve-playground"
REGISTRY="oidc-example"
API_BASE="https://api.buildkite.com/v2/packages/organizations/${ORG}/registries/${REGISTRY}"

# Get OIDC token for authentication
TOKEN=$(buildkite-agent oidc request-token \
  --audience "https://packages.buildkite.com/${ORG}/${REGISTRY}" \
  --lifetime 300)

# List all packages and extract their IDs
echo "Fetching packages from ${ORG}/${REGISTRY}..."
PACKAGES=$(curl -sS -H "Authorization: Bearer ${TOKEN}" \
  -X GET "${API_BASE}/packages" | jq -r '.items[].id')

if [ -z "$PACKAGES" ]; then
  echo "No packages found in registry."
  exit 0
fi

# Delete each package
for PACKAGE_ID in $PACKAGES; do
  echo "Deleting package: ${PACKAGE_ID}"
  curl -sS -H "Authorization: Bearer ${TOKEN}" \
    -X DELETE "${API_BASE}/packages/${PACKAGE_ID}"
done

echo "Done. All packages deleted."
