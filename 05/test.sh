#!/bin/sh

set -e

echo "Running unit tests..."

zig test 05/main.zig

echo "Running real tests..."

zig run "./05/main.zig" < "./05/sample" | diff "./05/expected_sample" -
zig run "./05/main.zig" < "./05/input" | diff "./05/expected" -
