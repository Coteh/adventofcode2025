#!/bin/sh

set -e

DATA_DIR="./data/2025"

echo "Running unit tests..."

zig test 02/main.zig

echo "Running real tests..."

zig run "./02/main.zig" < "${DATA_DIR}/02/sample" | diff "${DATA_DIR}/02/expected_sample" -
zig run "./02/main.zig" < "${DATA_DIR}/02/input" | diff "${DATA_DIR}/02/expected" -
