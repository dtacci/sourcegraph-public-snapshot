#!/bin/bash

mkdir -p client/web-sveltekit/static
chmod -R 755 client/web-sveltekit/static
mkdir -p client/shared/src/graphql-operations
chmod -R 755 client/shared/src/graphql-operations

# Generate GraphQL operations
cd client/shared && pnpm run generate:graphql-operations

# Start the dev server
cd ../web-sveltekit && SOURCEGRAPH_API_URL=http://localhost:7081 pnpm dev