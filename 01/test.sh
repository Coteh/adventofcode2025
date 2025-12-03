#!/bin/sh

set -e

zig test 01/main.zig

zig run "./01/main.zig" < "./01/sample" | diff "./01/expected_sample" -
zig run "./01/main.zig" < "./01/input" | diff "./01/expected" -
