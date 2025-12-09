const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

fn processInput() !u32 {
    var stdin_buffer: [512]u8 = undefined;
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: *std.Io.Reader = &stdin_reader_wrapper.interface;

    const MAX_PAPER: usize = 140;
    var paperRollRows: [MAX_PAPER][MAX_PAPER]u8 = undefined;
    @memset(&paperRollRows, undefined);

    var i: usize = 0;
    while (i < MAX_PAPER) {
        @memset(&paperRollRows[i], 0);
        i += 1;
    }

    i = 0;
    var j: usize = 0;
    var lineLen: usize = 0;
    while (try reader.takeDelimiter('\n')) |line| {
        //print("the line read is {s} {any}\n", .{line, line});
        j = 0;
        while (j < line.len) {
            paperRollRows[i][j] = line[j];
            j += 1;
        }
        i += 1;
        lineLen = line.len;
    }

    //i = 0;
    //while (i < paperRollRows.len) {
    //    print("This line is {any}\n", .{paperRollRows[i]});
    //    i += 1;
    //}

    //print("the len is {any}x{any}\n", .{paperRollRows.len, paperRollRows[0].len});

    var totalCount: u32 = 0;
    i = 0;
    while (i < paperRollRows.len) {
        j = 0;
        while (j < MAX_PAPER) {
            if (paperRollRows[i][j] != '@' and paperRollRows[i][j] != 'x') {
                j += 1;
                continue;
            }
            var foundCount: u8 = 0;
            if (i > 0) {
                if (j > 0) {
                    if (paperRollRows[i - 1][j - 1] == '@' or paperRollRows[i - 1][j - 1] == 'x') {
                        foundCount += 1;
                    }
                }
                if (paperRollRows[i - 1][j] == '@' or paperRollRows[i - 1][j] == 'x') {
                    foundCount += 1;
                }
                if (j < MAX_PAPER - 1) {
                    if (paperRollRows[i - 1][j + 1] == '@' or paperRollRows[i - 1][j + 1] == 'x') {
                        foundCount += 1;
                    }
                }
            }
            if (j > 0) {
                if (paperRollRows[i][j - 1] == '@' or paperRollRows[i][j - 1] == 'x') {
                    foundCount += 1;
                }
            }
            if (j < MAX_PAPER - 1) {
                if (paperRollRows[i][j + 1] == '@' or paperRollRows[i][j + 1] == 'x') {
                    foundCount += 1;
                }
            }
            if (i < MAX_PAPER - 1) {
                if (j > 0) {
                    if (paperRollRows[i + 1][j - 1] == '@' or paperRollRows[i + 1][j - 1] == 'x') {
                        foundCount += 1;
                    }
                }
                if (paperRollRows[i + 1][j] == '@' or paperRollRows[i + 1][j] == 'x') {
                    foundCount += 1;
                }
                if (j < MAX_PAPER - 1) {
                    if (paperRollRows[i + 1][j + 1] == '@' or paperRollRows[i + 1][j + 1] == 'x') {
                        foundCount += 1;
                    }
                }
            }
            if (foundCount < 4) {
                paperRollRows[i][j] = 'x';
                totalCount += 1;
            }
            j += 1;
        }
        i += 1;
    }

    i = 0;
    while (i < paperRollRows.len) {
        //print("This line is {any}\n", .{paperRollRows[i]});
        i += 1;
    }

    return totalCount;
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
