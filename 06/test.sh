#!/bin/sh

set -e

DATA_DIR="./data/2025"

echo "Running unit tests..."

zig test 06/main.zig

echo "Running real tests..."

zig run "./06/main.zig" < "${DATA_DIR}/06/sample" | diff "${DATA_DIR}/06/expected_sample" -
zig run "./06/main.zig" < "${DATA_DIR}/06/input" | diff "${DATA_DIR}/06/expected" -
