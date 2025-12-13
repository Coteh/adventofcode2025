#!/bin/sh

set -e

DATA_DIR="./data/2025"

echo "Running unit tests..."

zig test 01/main.zig

echo "Running real tests..."

zig run "./01/main.zig" < "${DATA_DIR}/01/sample" | diff "${DATA_DIR}/01/expected_sample" -
zig run "./01/main.zig" < "${DATA_DIR}/01/input" | diff "${DATA_DIR}/01/expected" -
