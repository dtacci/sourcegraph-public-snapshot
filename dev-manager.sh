#!/bin/bash

# This script manages the development environment for Sourcegraph
# It can start both the backend and frontend, and manage feature branches

set -e

# Function to start the backend server
start_backend() {
  echo "Starting Sourcegraph backend server on port 7081..."
  docker run --rm --publish 7081:7080 -v ~/.sourcegraph/config:/etc/sourcegraph -v ~/.sourcegraph/data:/var/opt/sourcegraph sourcegraph/server:insiders &
  BACKEND_PID=$!
  echo "Backend server started with PID $BACKEND_PID"
}

# Function to start the frontend server
start_frontend() {
  echo "Starting SvelteKit frontend server..."
  # First ensure we're using the right Node.js version
  if command -v nvm &> /dev/null; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm use 20.8.0 || nvm install 20.8.0
    echo "Using Node.js $(node -v)"
  else
    echo "Warning: nvm not found, using system Node.js"
  fi
  
  cd client/web-sveltekit
  ./dev-setup.sh &
  FRONTEND_PID=$!
  echo "Frontend server started with PID $FRONTEND_PID"
  cd ../..
  
  # Give it a moment to start up
  sleep 3
  echo "Frontend should be available at http://localhost:5173"
}

# Function to create a new feature branch
create_branch() {
  BRANCH_NAME=$1
  BRANCH_TYPE=$2

  if [ -z "$BRANCH_NAME" ]; then
    echo "Error: Branch name is required"
    echo "Usage: $0 create-branch <branch-name> [ui|api|full]"
    return 1
  fi

  if [ -z "$BRANCH_TYPE" ]; then
    BRANCH_TYPE="full"
  fi

  # Make sure we're on the main branch first
  git checkout main

  # Create a new branch for the feature
  git checkout -b "$BRANCH_NAME"
  echo "Created branch: $BRANCH_NAME"
  
  # Add a note about what type of changes this branch will contain
  if [ "$BRANCH_TYPE" = "ui" ]; then
    echo "Branch '$BRANCH_NAME' created for UI changes"
  elif [ "$BRANCH_TYPE" = "api" ]; then
    echo "Branch '$BRANCH_NAME' created for API changes"
  else
    echo "Branch '$BRANCH_NAME' created for full-stack changes"
  fi
}

# Function to stop all servers
stop_servers() {
  echo "Stopping all servers..."
  
  if [ ! -z "$FRONTEND_PID" ]; then
    kill $FRONTEND_PID 2>/dev/null || true
    echo "Frontend server stopped"
  fi
  
  if [ ! -z "$BACKEND_PID" ]; then
    kill $BACKEND_PID 2>/dev/null || true
    echo "Backend server stopped"
  fi
}

# Main command handler
case "$1" in
  start-backend)
    start_backend
    ;;
  start-frontend)
    start_frontend
    ;;
  start-all)
    start_backend
    start_frontend
    ;;
  create-branch)
    create_branch "$2" "$3"
    ;;
  stop)
    stop_servers
    ;;
  *)
    echo "Usage: $0 {start-backend|start-frontend|start-all|create-branch|stop}"
    echo ""
    echo "Commands:"
    echo "  start-backend       Start the Sourcegraph backend server"
    echo "  start-frontend      Start the SvelteKit frontend server"
    echo "  start-all           Start both backend and frontend servers"
    echo "  create-branch NAME  Create a new feature branch"
    echo "    Optional branch types: ui, api, full (default)"
    echo "  stop                Stop all running servers"
    exit 1
    ;;
esac

# Setup trap to clean up on exit
trap stop_servers EXIT

# If servers are started, wait for Ctrl+C
if [ ! -z "$BACKEND_PID" ] || [ ! -z "$FRONTEND_PID" ]; then
  echo ""
  echo "Servers are running. Press Ctrl+C to stop."
  # Wait indefinitely
  while true; do sleep 1; done
fi