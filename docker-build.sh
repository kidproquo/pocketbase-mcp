#!/bin/bash

# Docker build script for PocketBase MCP Server
# Builds and tags the image with format: ghcr.io/kidproquo/pocketbase-mcp:YYMMDDHHmm

set -e

# Generate version tag in format YYMMDDHHmm
VERSION=$(date +%y%m%d%H%M)
IMAGE_NAME="ghcr.io/kidproquo/pocketbase-mcp"
FULL_TAG="${IMAGE_NAME}:${VERSION}"
LATEST_TAG="${IMAGE_NAME}:latest"

echo "Building Docker image..."
echo "Version: ${VERSION}"
echo "Image tag: ${FULL_TAG}"

# Build the Docker image
docker build -t "${FULL_TAG}" -t "${LATEST_TAG}" .

echo ""
echo "Build complete!"
echo "Tagged as:"
echo "  - ${FULL_TAG}"
echo "  - ${LATEST_TAG}"
echo ""
echo "To push to registry, run:"
echo "  docker push ${FULL_TAG}"
echo "  docker push ${LATEST_TAG}"
