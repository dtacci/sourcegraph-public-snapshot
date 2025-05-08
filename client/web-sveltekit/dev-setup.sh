#!/bin/bash

# This script sets up the development environment for the SvelteKit UI

set -e

# Make sure we're in the right directory
cd "$(dirname "$0")"

# Create necessary directories with proper permissions
mkdir -p static
chmod 777 static

# Set environment variables for proper path resolution
export NODE_OPTIONS="--no-warnings --max-old-space-size=8192"
export SOURCEGRAPH_API_URL="http://localhost:7081"
export SOURCEGRAPH_PATH="$(pwd)/.."
export SK_HOST="localhost"
export SK_PORT="5173"

# Make sure GraphQL operations are generated
cd ../shared
pnpm run generate:graphql-operations
cd ../web-sveltekit

# Try different approach - use standalone proxy mode instead of direct development
echo "Starting SvelteKit in standalone mode..."
echo "API URL: $SOURCEGRAPH_API_URL"
echo "Using Node.js $(node -v)"

# Try to run the web-standalone-http command from the root
cd ../../
if pnpm list | grep -q "@sourcegraph/web"; then
  echo "Using web standalone mode"
  cd client/web
  SOURCEGRAPH_API_URL="http://localhost:7081" pnpm serve:dev
else
  echo "Falling back to SvelteKit dev mode"
  cd client/web-sveltekit
  pnpm dev
fi