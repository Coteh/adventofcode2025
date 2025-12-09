#!/bin/sh

set -e

echo "Running unit tests..."

zig test 04/main.zig

echo "Running real tests..."

zig run "./04/main.zig" < "./04/sample" | diff "./04/expected_sample" -
zig run "./04/main.zig" < "./04/input" | diff "./04/expected" -
