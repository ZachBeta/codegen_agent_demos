#!/bin/bash

# Benchmark runner with configurable iterations
ITERATIONS=${1:-3}
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_ROOT=$(realpath "$SCRIPT_DIR/../../..")
RESULTS_DIR="$PROJECT_ROOT/ruby_codegen_app/test_harness/results"
SUMMARY_FILE="$RESULTS_DIR/summary_$(date +%Y%m%d_%H%M%S).txt"

# Create results directory
mkdir -p "$RESULTS_DIR"

echo "=== Starting Benchmark Run ==="
echo "Iterations: $ITERATIONS"
echo "Results Dir: $RESULTS_DIR"
echo "Timestamp: $(date)"
echo ""

for ((i=1; i<=$ITERATIONS; i++)); do
  echo "--- Iteration $i ---"
  ITERATION_FILE="$RESULTS_DIR/benchmark_${i}_$(date +%Y%m%d_%H%M%S).json"
  
  # Run test and capture output
  "$SCRIPT_DIR/scripts/test_prime_factors.sh" | tee -a "$SUMMARY_FILE"
  
  # Move benchmark file if created
  if [ -f "$PROJECT_ROOT/prime_factors_benchmark.json" ]; then
    mv "$PROJECT_ROOT/prime_factors_benchmark.json" "$ITERATION_FILE"
    echo "Results saved to $ITERATION_FILE"
  fi
  
  echo ""
done

# Generate final summary
echo "=== Benchmark Complete ===" >> "$SUMMARY_FILE"
echo "Total iterations: $ITERATIONS" >> "$SUMMARY_FILE"
grep -h "Benchmark summary:" "$RESULTS_DIR"/benchmark_*.json >> "$SUMMARY_FILE" 2>/dev/null

echo ""
echo "=== Final Summary ==="
cat "$SUMMARY_FILE"