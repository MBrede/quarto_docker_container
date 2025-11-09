#!/bin/bash

set -e

IMAGE_NAME="your-dockerhub-username/quarto-render"
VERSION="1.0.0"

echo "Building Docker image..."
docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .

echo "Logging in to Docker Hub..."
docker login

echo "Pushing image to Docker Hub..."
docker push ${IMAGE_NAME}:${VERSION}
docker push ${IMAGE_NAME}:latest

echo "Done! Image pushed as:"
echo "  ${IMAGE_NAME}:${VERSION}"
echo "  ${IMAGE_NAME}:latest"
