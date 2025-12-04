const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const pow = std.math.pow;

fn isValidNumber(n: u64) bool {
    var curr: u64 = n;
    var accRem: u64 = 0;
    var numDigits: u32 = 0;
    while (curr > 0) {
        const rem: u64 = @mod(curr, 10);
        accRem = accRem + pow(u64, 10, numDigits) * rem;
        curr = @divTrunc(curr, 10);
        if (accRem == curr and rem != 0) {
            return false;
        }
        numDigits = numDigits + 1;
    }
    return true;
}

test "expect the sample invalid numbers to return invalid" {
    try expect(!isValidNumber(11));
    try expect(!isValidNumber(22));
    try expect(!isValidNumber(99));
    try expect(!isValidNumber(1010));
    try expect(!isValidNumber(1188511885));
    try expect(!isValidNumber(222222));
    try expect(!isValidNumber(446446));
    try expect(!isValidNumber(38593859));
}

test "expect two digit numbers that don't repeat to be valid" {
    try expect(isValidNumber(13));
}

test "expect three digit numbers that don't repeat to be valid" {
    try expect(isValidNumber(105));
}

test "expect four digit numbers that don't repeat to be valid" {
    try expect(isValidNumber(1004));
}

test "expect a number with 0 in the middle but doesn't repeat twice to be valid" {
    try expect(isValidNumber(101));
}

fn countNumInvalidInRange(start: u64, end: u64) u64 {
    var n: u64 = start;
    var total: u64 = 0;
    while (n <= end) {
        if (!isValidNumber(n)) {
            //print("{any} is invalid!\n", .{n});
            total += n;
        }
        n += 1;
    }
    return total;
}

fn processInput() !u64 {
    var stdin_buffer: [512]u8 = undefined;
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: *std.Io.Reader = &stdin_reader_wrapper.interface;

    var total: u64 = 0;
    const maybe_line = reader.takeDelimiter('\n') catch |err| {
        print("Error reading line {any}\n", .{err});
        return err;
    };
    if (maybe_line) |line| {
        var first: []u8 = undefined;
        var second: []u8 = undefined;
        var startIndex: usize = 0;
        for (line, 0..) |chr,i| {
            if (chr == '-') {
                first = line[startIndex..i];
                startIndex = i + 1;
            } else if (chr == ',') {
                second = line[startIndex..i];
                startIndex = i + 1;

                const firstNum: u64 = try parseInt(u64, first, 10);
                const secondNum: u64 = try parseInt(u64, second, 10);
                total += countNumInvalidInRange(firstNum, secondNum);
                //print("total so far for {d}-{d}: {d}\n", .{firstNum, secondNum, total});
            }
        }
        second = line[startIndex..line.len];
        const firstNum: u64 = try parseInt(u64, first, 10);
        const secondNum: u64 = try parseInt(u64, second, 10);
        total += countNumInvalidInRange(firstNum, secondNum);
    } else {
        print("null line\n", .{});
    }

    return total;
}

pub fn main() !void {
    const result = processInput();

    var stdout_buffer: [512]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.Io.Writer = &stdout_writer.interface;
    try stdout.print("{any}\n", .{result});
    try stdout.flush();
}