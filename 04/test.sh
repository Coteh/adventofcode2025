#!/bin/sh

set -e

DATA_DIR="./data/2025"

echo "Running unit tests..."

zig test 04/main.zig

echo "Running real tests..."

zig run "./04/main.zig" < "${DATA_DIR}/04/sample" | diff "${DATA_DIR}/04/expected_sample" -
zig run "./04/main.zig" < "${DATA_DIR}/04/input" | diff "${DATA_DIR}/04/expected" -
