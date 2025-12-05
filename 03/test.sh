#!/bin/sh

set -e

echo "Running unit tests..."

zig test 03/main.zig

echo "Running real tests..."

zig run "./03/main.zig" < "./03/sample" | diff "./03/expected_sample" -
zig run "./03/main.zig" < "./03/input" | diff "./03/expected" -
