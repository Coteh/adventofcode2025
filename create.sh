#!/bin/sh

DAY="$1"

if [ "$DAY" == "" ]; then
    >&2 echo "Please provide the day"
    exit 1
fi

mkdir "$DAY"
if [ "$?" != "0" ]; then
    exit 1
fi

cat << EOF > "$DAY/main.zig"
const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

fn processInput() !u32 {
    var stdin_buffer: [512]u8 = undefined;
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: *std.Io.Reader = &stdin_reader_wrapper.interface;

    while (try reader.takeDelimiter('\n')) |line| {
        print("the line read is {s} {any}\n", .{line, line});
    }

    return 0;
}

pub fn main() !void {
    const result = processInput() catch |err| {
        print("Error processing input {any}\n", .{err});
        return err;
    };

    var stdout_buffer: [512]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.Io.Writer = &stdout_writer.interface;
    try stdout.print("{any}\n", .{result});
    try stdout.flush();
}
EOF

cat << EOF > "$DAY/test.sh"
#!/bin/sh

set -e

DATA_DIR="./data/2025"

echo "Running unit tests..."

zig test $DAY/main.zig

echo "Running real tests..."

zig run "./$DAY/main.zig" < "${DATA_DIR}/$DAY/sample" | diff "${DATA_DIR}/$DAY/expected_sample" -
zig run "./$DAY/main.zig" < "${DATA_DIR}/$DAY/input" | diff "${DATA_DIR}/$DAY/expected" -
EOF

chmod +x "$DAY/test.sh"
git add "$DAY/main.zig" "$DAY/test.sh"
git update-index --chmod=+x "$DAY/test.sh"
