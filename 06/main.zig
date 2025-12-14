const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

const MAX_NUM_ROW_SIZE = 1000;
const MAX_NUM_COL_SIZE = 4;

fn getLineTotal(numArr: [MAX_NUM_ROW_SIZE][MAX_NUM_COL_SIZE]u64, numIndex: usize, lineIndex: usize, mathOp: u8) u64 {
    var lineTotal: u64 = numArr[numIndex][0];
    var i: usize = 1;
    //print("line total is starting at {any}\n", .{lineTotal});
    //print("iterating to {any}\n", .{lineIndex});
    while (i < lineIndex) {
        const num: u64 = numArr[numIndex][i];
        //print("currently on number: {d} (x:{d},y:{d})\n", .{num, i, numIndex});
        lineTotal = switch (mathOp) {
            '*' => lineTotal * num,
            else => lineTotal + num, // '+'
        };
        i += 1;
    }
    //print("line total is {any}\n", .{lineTotal});
    return lineTotal;
}

fn processInput() !u64 {
    var stdin_buffer: [4000]u8 = undefined;
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: *std.Io.Reader = &stdin_reader_wrapper.interface;

    var numbers: [MAX_NUM_ROW_SIZE][MAX_NUM_COL_SIZE]u64 = undefined;
    @memset(&numbers, undefined);

    var k: usize = 0;
    while (k < MAX_NUM_ROW_SIZE) {
        @memset(&numbers[k], 0);
        k += 1;
    }

    var total: u64 = 0;
    var readMode: u8 = 0;
    var lineIndex: usize = 0;
    while (try reader.takeDelimiter('\n')) |line| {
        //print("the line read is {s} {any}\n", .{line, line});
        var startingIndex: usize = 0;
        var endingIndex: usize = 0;
        var numIndex: usize = 0;
        for (line, 0..) |chr,i| {
            if (chr == ' ') {
                const firstChr: u8 = line[startingIndex];
                if (readMode == 0 and firstChr != ' ') {
                    if (firstChr == '*' or firstChr == '+') {
                        //print("just a math symbol: {c}\n", .{firstChr});
                        total += getLineTotal(numbers, numIndex, lineIndex, firstChr);
                    } else {
                        const str: []u8 = line[startingIndex..endingIndex + 1];
                        //print("parsing the following string of characters: {s} ({any})\n", .{str,str});
                        const parsedNum: u64 = try parseInt(u64, str, 10);
                        //print("parsed number: {d}\n", .{parsedNum});
                        numbers[numIndex][lineIndex] = parsedNum;
                    }
                    numIndex += 1;
                }
                readMode = 1;
            } else {
                if (readMode == 1) {
                    startingIndex = i;
                }
                readMode = 0;
                endingIndex = i;
            }
        }
        if (readMode == 0) {
            //print("reached the end, but still need to process the last value\n", .{});
            const firstChr: u8 = line[startingIndex];
            if (firstChr == '*' or firstChr == '+' or firstChr == '/' or firstChr == '-') {
                //print("just a math symbol: {c}\n", .{firstChr});
                total += getLineTotal(numbers, numIndex, lineIndex, firstChr);
            } else {
                const parsedNum: u64 = try parseInt(u64, line[startingIndex..endingIndex + 1], 10);
                //print("parsed number: {d}\n", .{parsedNum});
                numbers[numIndex][lineIndex] = parsedNum;
            }
        }
        lineIndex += 1;
    }

    //k = 0;
    //while (k < MAX_NUM_ROW_SIZE) {
    //    print("num array: {any}\n", .{numbers[k]});
    //    k += 1;
    //}

    return total;
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
