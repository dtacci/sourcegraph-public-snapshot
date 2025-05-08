#!/bin/bash

# This script sets up the entire development environment

set -e

# Print section header
section() {
  echo ""
  echo "=================================================="
  echo "  $1"
  echo "=================================================="
  echo ""
}

# Check if backend is running
check_backend() {
  if curl -s -I http://localhost:7081 >/dev/null; then
    echo "✓ Backend is running at http://localhost:7081"
    return 0
  else
    echo "✗ Backend is not running at http://localhost:7081"
    return 1
  fi
}

section "Setting up Sourcegraph development environment"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
  echo "✗ Docker is not running. Please start Docker first."
  exit 1
fi

echo "✓ Docker is running"

# Check if Redis and PostgreSQL are running
if ! docker ps | grep -q "dev-redis" || ! docker ps | grep -q "dev-postgresql"; then
  section "Starting Redis and PostgreSQL"
  echo "Starting Redis and PostgreSQL containers..."
  docker-compose -f dev/redis-postgres.yml up -d
else
  echo "✓ Redis and PostgreSQL containers are already running"
fi

# Check if backend is running, if not start it
if ! check_backend; then
  section "Starting Sourcegraph backend"
  echo "Starting Sourcegraph backend server..."
  echo "This will be available at http://localhost:7081"
  echo "This will run in the background. Use 'docker ps' to check its status."
  
  # Start the server in the background
  docker run --rm --name sourcegraph-server --publish 7081:7080 \
    -v ~/.sourcegraph/config:/etc/sourcegraph \
    -v ~/.sourcegraph/data:/var/opt/sourcegraph \
    sourcegraph/server:insiders -d
  
  # Wait for it to start
  echo "Waiting for backend to start..."
  attempt=0
  while ! check_backend && [ $attempt -lt 30 ]; do
    echo "Waiting for backend to become available... ($attempt/30)"
    sleep 2
    attempt=$((attempt+1))
  done
  
  if [ $attempt -eq 30 ]; then
    echo "✗ Backend did not start within the expected time"
    exit 1
  fi
fi

section "Setting up frontend UI access"

# Instead of dealing with the frontend setup directly, provide instructions
echo "The Sourcegraph backend is now running at:"
echo "  http://localhost:7081"
echo ""
echo "You can access and use it directly through your browser."
echo ""
echo "For development:"
echo "1. API changes: Modify the backend code and rebuild"
echo "2. UI testing: Use the browser directly on http://localhost:7081"
echo ""
echo "Backend logs can be viewed with:"
echo "  docker logs -f sourcegraph-server"

echo ""
echo "Setup complete! Happy coding!"