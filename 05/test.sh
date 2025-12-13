#!/bin/sh

set -e

DATA_DIR="./data/2025"

echo "Running unit tests..."

zig test 05/main.zig

echo "Running real tests..."

zig run "./05/main.zig" < "${DATA_DIR}/05/sample" | diff "${DATA_DIR}/05/expected_sample" -
zig run "./05/main.zig" < "${DATA_DIR}/05/input" | diff "${DATA_DIR}/05/expected" -
