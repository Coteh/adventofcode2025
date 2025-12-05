const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const pow = std.math.pow;
const floor = std.math.floor;
const log10 = std.math.log10;

fn isValidNumber(n: u64) bool {
    var curr: u64 = n;
    var accRem: u64 = 0;
    var numDigits: u32 = 0;
    while (curr > 0) {
        const rem: u64 = @mod(curr, 10);
        accRem = accRem + pow(u64, 10, numDigits) * rem;
        curr = @divTrunc(curr, 10);
        if (accRem == curr and rem != 0) {
            //print("{any} = {any}\n", .{accRem, curr});
            return false;
        }
        numDigits = numDigits + 1;
    }
    return true;
}

test "part 1: expect the sample invalid numbers from part 1 to return invalid" {
    try expect(!isValidNumber(11));
    try expect(!isValidNumber(22));
    try expect(!isValidNumber(99));
    try expect(!isValidNumber(1010));
    try expect(!isValidNumber(1188511885));
    try expect(!isValidNumber(222222));
    try expect(!isValidNumber(446446));
    try expect(!isValidNumber(38593859));
}

test "part 1: expect two digit numbers that are not comprised of sequence of digits repeating twice to be valid" {
    try expect(isValidNumber(13));
}

test "part 1: expect three digit numbers that are not comprised of sequence of digits repeating twice to be valid" {
    try expect(isValidNumber(105));
}

test "part 1: expect four digit numbers that are not comprised of sequence of digits repeating twice to be valid" {
    try expect(isValidNumber(1004));
}

test "part 1: expect a number with 0 in the middle but not comprised of sequence of digits repeating twice to be valid" {
    try expect(isValidNumber(101));
}

// NOTE:
// My idea is to:
// - Take the digits off the number using remainder, like before
// - Pass the rest of the number into recursive call into itself
// - If the number is invalid, and the sequence of repeating digits matched the remainder I have so far,
// -- then it's invalid
// - The idea is that this would be recursive, it will keep feeding the digits into this function 
// -- recursively until it's able to figure out that there are repeating sequence of digits.
// - 0 is the base case, as the last digit will become 0 once divided by 10
fn isValidNumber2_internal(n: u64) struct { bool, u64 } {
    if (n == 0) {
        //print("base case\n", .{});
        return .{true, n};
    }
    var curr: u64 = n;
    var accRem: u64 = 0;
    var numDigits: u32 = 0;
    while (curr > 0) {
        const rem: u64 = @mod(curr, 10);
        accRem = accRem + pow(u64, 10, numDigits) * rem;
        curr = @divTrunc(curr, 10);
        //print("{any} vs. {any}\n", .{accRem, curr});
        // edge case: 0 was added on, skip to the next one
        if (accRem == rem and numDigits > 0) {
            numDigits = numDigits + 1;
            continue;
        }
        if (accRem == curr and rem != 0) {
            //print("{any} = {any}\n", .{accRem, curr});
            return .{false, accRem};
        } else {
            //print("going to make recursive call to determine validity of {any}\n", .{curr});
            const result = isValidNumber2_internal(curr);
            if (!result[0]) {
                //print("checking if {any} is repeated as {any}...\n", .{result[1], accRem});
                if (accRem == result[1]) {
                    const accRemFloat: f64 = @floatFromInt(accRem);
                    const numActualDigits: u32 = @intFromFloat(floor(log10(accRemFloat)));
                    //print("checking if num actual digits {any} matches num digits so far {any}\n", .{numActualDigits, numDigits});
                    if (numActualDigits == numDigits) {
                        //print("{any} is repeated\n", .{result[1]});
                        return .{false, accRem};
                    } else {
                        // edge case, there's 0s in front of the digit, not actually matching
                        //print("{any} actually has 0s in front\n", .{result[1]});
                        return .{true, accRem};
                    }
                } else {
                    return .{true, accRem};
                }
            }
        }
        numDigits = numDigits + 1;
    }

    return .{true, n};
}

fn isValidNumber2(n: u64) bool {
    //print("starting with {any}\n", .{n});
    const result = isValidNumber2_internal(n);
    if (!result[0]) {
        //print("{any} is invalid\n", .{n});
    }
    return result[0];
}

test "part 2: expect the sample invalid numbers from part 1 to return invalid" {
    try expect(!isValidNumber2(11));
    try expect(!isValidNumber2(22));
    try expect(!isValidNumber2(99));
    try expect(!isValidNumber2(1010));
    try expect(!isValidNumber2(1188511885));
    try expect(!isValidNumber2(222222));
    try expect(!isValidNumber2(446446));
    try expect(!isValidNumber2(38593859));
}

test "part 2: expect the sample invalid numbers from part 2 to return invalid" {
    try expect(!isValidNumber2(111));
    try expect(!isValidNumber2(999));
    try expect(!isValidNumber2(565656));
    try expect(!isValidNumber2(824824824));
    try expect(!isValidNumber2(2121212121));
}

test "part 2: expect a long sequence repeated three times to return invalid" {
    try expect(!isValidNumber2(123412341234));
}

test "part 2: expect a long sequence almost repeated three times to return valid" {
    try expect(isValidNumber2(123412341235));
}

test "part 2: expect two sets of 3 repeating digits not fully repeated to return invalid" {
    try expect(isValidNumber2(111222111));
}

test "part 2: expect single digit number to return valid" {
    try expect(isValidNumber2(1));
}

test "part 2: expect 0 to return valid" {
    try expect(isValidNumber2(0));
}

test "part 2: expect extra digit in the number to return valid" {
    try expect(isValidNumber2(1112221112222));
}

test "part 2: expect repeating digits with 0 in it to return invalid" {
    try expect(!isValidNumber2(100010001000));
}

test "part 2: expect digits not repeating to return valid" {
    try expect(isValidNumber2(492));
}

test "part 2: expect digits not fully repeated to return valid" {
    try expect(isValidNumber2(22112));
}

test "part 2: expect digits not fully repeated with 0 in the sequence to return valid" {
    try expect(isValidNumber2(22002));
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

fn countNumInvalidInRange2(start: u64, end: u64) u64 {
    var n: u64 = start;
    var total: u64 = 0;
    while (n <= end) {
        if (!isValidNumber2(n)) {
            //print("{any} is invalid!\n", .{n});
            total += n;
        }
        n += 1;
    }
    return total;
}

fn processInput() !struct{u64, u64} {
    var stdin_buffer: [512]u8 = undefined;
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: *std.Io.Reader = &stdin_reader_wrapper.interface;

    var total: u64 = 0;
    var total2: u64 = 0;
    const maybe_line = reader.takeDelimiter('\n') catch |err| {
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
                total2 += countNumInvalidInRange2(firstNum, secondNum);
                //print("total so far for {d}-{d}: {d}\n", .{firstNum, secondNum, total});
            }
        }
        second = line[startIndex..line.len];
        const firstNum: u64 = try parseInt(u64, first, 10);
        const secondNum: u64 = try parseInt(u64, second, 10);
        total += countNumInvalidInRange(firstNum, secondNum);
        total2 += countNumInvalidInRange2(firstNum, secondNum);
    } else {
        print("null line\n", .{});
    }

    return .{total, total2};
}

pub fn main() !void {
    const result = processInput() catch |err| {
        print("Error processing input {any}\n", .{err});
        return err;
    };

    var stdout_buffer: [512]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.Io.Writer = &stdout_writer.interface;
    try stdout.print("{any}\n", .{result[0]});
    try stdout.print("{any}\n", .{result[1]});
    try stdout.flush();
}