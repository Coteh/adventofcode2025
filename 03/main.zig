const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const pow = std.math.pow;
const log10 = std.math.log10;
const floor = std.math.floor;

fn findJoltages(line: []const u8, numDigitsRemaining: u64, numDigitsObtained: u64, numDigitsMax: u64) !u64 {
    //print("finding joltages for line {s} with {any} digits remaining, {any} digits obtained, and {any} digits in total\n", .{line, numDigitsRemaining, numDigitsObtained, numDigitsMax});

    if (line.len == numDigitsRemaining) {
        //print("base case #1 - return all numbers\n", .{});

        var result: u64 = 0;
        var i: usize = 0;
        while (i < line.len) {
            const digit: u64 = try parseInt(u64, line[i..i+1], 10);
            result += digit * pow(u64, 10, numDigitsRemaining - i - 1);
            //print("adding {any} * 10^{any} -> {any}\n", .{digit, numDigitsRemaining - i - 1, result});
            i += 1;
        }

        //print("returning subjoltage value {any}\n", .{result});

        return result;
    }

    var highestDigit: u8 = 0;
    var highestDigitIndex: usize = 0;
    var i: usize = 0;
    while (i < line.len - numDigitsRemaining + 1) {
        const digit: u8 = try parseInt(u8, line[i..i+1], 10);
        //print("comparing {any} with current highest digit {any}\n", .{digit, highestDigit});
        if (highestDigit == 0 or digit > highestDigit) {
            highestDigit = digit;
            highestDigitIndex = i;
        }
        i += 1;
    }

    //print("highest digit is {any} at {any} for line {s} with {any} digits remaining\n", .{highestDigit, highestDigitIndex, line, numDigitsRemaining});

    var highestSubjoltage: u64 = 0;
    if (numDigitsRemaining - 1 > 0) {
        highestSubjoltage = try findJoltages(line[highestDigitIndex + 1..line.len], numDigitsRemaining - 1, numDigitsObtained + 1, numDigitsMax);
    } else {
        if (numDigitsObtained + 1 == numDigitsMax) {
            //print("no more digits needed after {any}, returning...\n", .{highestDigit});
            return highestDigit;
        }
        //print("Skipping subjoltages since there's no more digits to retrieve\n", .{});
    }

    const result: u64 = highestDigit * pow(u64, 10, numDigitsRemaining - 1) + highestSubjoltage;
    //print("Now returning {any} * 10^{any} + {any} = {any}\n", .{highestDigit, numDigitsRemaining - 1, highestSubjoltage, result});
    return result;
}

test "expect both joltages to be selected if the bank is just 2 batteries" {
    const line = [_]u8{'1', '2'};
    const slice = line[0..];
    const result = try findJoltages(slice, 2, 0, 2);
    try expect(result == 12);
}

test "expect 2 and 3 to be selected if the bank is just 3 batteries 1,2,3" {
    const line = [_]u8{'1', '2', '3'};
    const slice = line[0..];
    const result = try findJoltages(slice, 2, 0, 2);
    try expect(result == 23);
}

test "expect three joltages to be selected if the bank is just 3 batteries" {
    const line = [_]u8{'1', '2', '3'};
    const slice = line[0..];
    const result = try findJoltages(slice, 3, 0, 3);
    try expect(result == 123);
}

test "expect top digits from the start of the line to remain selected" {
    const line = [_]u8{'9', '8', '1', '1'};
    const slice = line[0..];
    const result = try findJoltages(slice, 2, 0, 2);
    try expect(result == 98);
}

test "expect digits on opposite sides to be selected" {
    const line = [_]u8{'9', '1', '1', '8'};
    const slice = line[0..];
    const result = try findJoltages(slice, 2, 0, 2);
    try expect(result == 98);
}

test "expect higher digits to be found later on in the bank" {
    const line = [_]u8{'1', '1', '1', '9', '1', '8', '2', '1'};
    const slice = line[0..];
    const result = try findJoltages(slice, 3, 0, 3);
    try expect(result == 982);
}

test "expect part 1 sample case 1 to pass" {
    const line = [_]u8{'9','8','7','6','5','4','3','2','1','1','1','1','1','1','1'};
    const slice = line[0..];
    const result = try findJoltages(slice, 2, 0, 2);
    try expect(result == 98);
}

test "expect part 1 sample case 2 to pass" {
    const line = [_]u8{'8','1','1','1','1','1','1','1','1','1','1','1','1','1','9'};
    const slice = line[0..];
    const result = try findJoltages(slice, 2, 0, 2);
    try expect(result == 89);
}

test "expect part 1 sample case 3 to pass" {
    const line = [_]u8{'2','3','4','2','3','4','2','3','4','2','3','4','2','7','8'};
    const slice = line[0..];
    const result = try findJoltages(slice, 2, 0, 2);
    try expect(result == 78);
}

test "expect part 1 sample case 4 to pass" {
    const line = [_]u8{'8','1','8','1','8','1','9','1','1','1','1','2','1','1','1'};
    const slice = line[0..];
    const result = try findJoltages(slice, 2, 0, 2);
    try expect(result == 92);
}

test "expect part 2 sample case 1 to pass" {
    const line = [_]u8{'9','8','7','6','5','4','3','2','1','1','1','1','1','1','1'};
    const slice = line[0..];
    const result = try findJoltages(slice, 12, 0, 12);
    try expect(result == 987654321111);
}

test "expect part 2 sample case 2 to pass" {
    const line = [_]u8{'8','1','1','1','1','1','1','1','1','1','1','1','1','1','9'};
    const slice = line[0..];
    const result = try findJoltages(slice, 12, 0, 12);
    try expect(result == 811111111119);
}

test "expect part 2 sample case 3 to pass" {
    const line = [_]u8{'2','3','4','2','3','4','2','3','4','2','3','4','2','7','8'};
    const slice = line[0..];
    const result = try findJoltages(slice, 12, 0, 12);
    try expect(result == 434234234278);
}

test "expect part 2 sample case 4 to pass" {
    const line = [_]u8{'8','1','8','1','8','1','9','1','1','1','1','2','1','1','1'};
    const slice = line[0..];
    const result = try findJoltages(slice, 12, 0, 12);
    try expect(result == 888911112111);
}

fn processInput() !struct{u64,u64} {
    var stdin_buffer: [512]u8 = undefined;
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: *std.Io.Reader = &stdin_reader_wrapper.interface;

    var totalJoltageP1: u64 = 0;
    var totalJoltageP2: u64 = 0;
    while (try reader.takeDelimiter('\n')) |line| {
        const joltage1 = try findJoltages(line, 2, 0, 2);
        const joltage2 = try findJoltages(line, 12, 0, 12);
        totalJoltageP1 += joltage1;
        totalJoltageP2 += joltage2;
    }

    return .{totalJoltageP1, totalJoltageP2};
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