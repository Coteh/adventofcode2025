#!/bin/sh

set -e

DATA_DIR="./data/2025"

echo "Running unit tests..."

zig test 03/main.zig

echo "Running real tests..."

zig run "./03/main.zig" < "${DATA_DIR}/03/sample" | diff "${DATA_DIR}/03/expected_sample" -
zig run "./03/main.zig" < "${DATA_DIR}/03/input" | diff "${DATA_DIR}/03/expected" -
