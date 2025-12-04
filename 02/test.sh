#!/bin/sh

set -e

zig test 02/main.zig

zig run "./02/main.zig" < "./02/sample" | diff "./02/expected_sample" -
zig run "./02/main.zig" < "./02/input" | diff "./02/expected" -
