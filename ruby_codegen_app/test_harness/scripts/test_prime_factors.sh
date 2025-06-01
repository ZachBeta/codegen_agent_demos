#!/bin/bash

# Get script directory for reliable path resolution
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_ROOT=$(realpath "$SCRIPT_DIR/../../..")

# Test the prime factors generation task
echo "=== Starting Prime Factors Test ==="
echo "Timestamp: $(date)"
echo "Project Root: $PROJECT_ROOT"

# Ensure Docker image is available
echo -n "Checking Docker image... "
docker inspect ruby:3.3-slim > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Pulling ruby:3.3-slim"
  docker pull ruby:3.3-slim || {
    echo "❌ Failed to pull Docker image"
    exit 1
  }
else
  echo "Found"
fi

# Execute test with timing
start_time=$(date +%s.%N)
docker compose -f "$PROJECT_ROOT/ruby_codegen_app/docker-compose.yml" run --rm codegen bundle exec rake codegen:prime_factors
exit_code=$?
end_time=$(date +%s.%N)

# Calculate and display timing
elapsed=$(echo "$end_time - $start_time" | bc)
echo "Test duration: ${elapsed}s"

# Check exit code
if [ $exit_code -eq 0 ]; then
  echo "✅ Prime factors test completed successfully"
else
  echo "❌ Prime factors test failed (exit code: $exit_code)"
  echo "=== Last 50 lines of container output ==="
  docker logs --tail 50 $(docker ps -lq)
  exit 1
fi