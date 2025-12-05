const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

fn findSecondNumber(subline: []u8, startingIndex: usize) !struct{u8, usize} {
    //print("finding second num for subline {s}\n", .{subline});
    var highestSecondNum: u8 = 0;
    var highestSecondIndex: usize = 0;
    for (subline, 0..) |_,i| {
        const num: u8 = try parseInt(u8, subline[i..i+1], 10);
        //print("{c} {any} {d}\n", .{chr, num, i});
        if (num > highestSecondNum) {
            highestSecondNum = num;
            highestSecondIndex = i;
        }
    }
    return .{highestSecondNum, startingIndex + highestSecondIndex + 1};
}

fn processInput() !u32 {
    var stdin_buffer: [512]u8 = undefined;
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: *std.Io.Reader = &stdin_reader_wrapper.interface;

    var total: u32 = 0;
    while (try reader.takeDelimiter('\n')) |line| {
        //print("line read: {s}\n", .{line});
        var highestFirstNum: u8 = 0;
        var highestFirstIndex: usize = 0;
        var highestSecondNum: u8 = 0;
        var highestSecondIndex: usize = 0;
        for (line, 0..) |_,i| {
            const num: u8 = try parseInt(u8, line[i..i+1], 10);
            //print("{c} {any} {d}\n", .{chr, num, i});
            if (num > highestFirstNum) {
                const result = try findSecondNumber(line[i + 1..], i);
                if (result[0] > 0 and result[1] > 0) {
                    highestFirstNum = num;
                    highestFirstIndex = i;
                    highestSecondNum = result[0];
                    highestSecondIndex = result[1];
                }
            }
        }
        //print("{any} and {any}\n", .{highestFirstNum, highestSecondNum});
        const joltage: u32 = (highestFirstNum * 10) + highestSecondNum;
        //print("{any}\n", .{joltage});
        total += joltage;
    }

    return total;
}

pub fn main() !void {
    const result = processInput() catch |err| {
        //print("Error processing input {any}\n", .{err});
        return err;
    };

    var stdout_buffer: [512]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.Io.Writer = &stdout_writer.interface;
    try stdout.print("{any}\n", .{result});
    try stdout.flush();
}