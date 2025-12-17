const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const trim = std.mem.trim;

const MAX_NUM_ROW_SIZE = 1000;
const MAX_NUM_COL_SIZE = 4;
const MAX_LINE_BUFFER_SIZE = 4000;

const CHRS_TO_TRIM: [1]u8 = [_]u8{0};

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

fn processInput() !struct {u64,u64} {
    var stdin_buffer: [MAX_LINE_BUFFER_SIZE]u8 = undefined;
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: *std.Io.Reader = &stdin_reader_wrapper.interface;

    var numbers: [MAX_NUM_ROW_SIZE][MAX_NUM_COL_SIZE]u64 = undefined;
    @memset(&numbers, undefined);

    var i: usize = 0;
    while (i < MAX_NUM_ROW_SIZE) {
        @memset(&numbers[i], 0);
        i += 1;
    }

    var lines: [MAX_NUM_COL_SIZE + 1][MAX_LINE_BUFFER_SIZE]u8 = undefined;
    @memset(&lines, undefined);

    i = 0;
    while (i < MAX_NUM_COL_SIZE + 1) {
        @memset(&lines[i], 0);
        i += 1;
    }

    var p1Total: u64 = 0;
    var p2Total: u64 = 0;

    i = 0;
    var lineLen: usize = 0;
    var p1ReadMode: u8 = 0;
    while (try reader.takeDelimiter('\n')) |line| {
        //print("line is {s} {any}\n", .{line, line});
        const lineSlice: []u8 = lines[i][0..line.len];
        @memcpy(lineSlice, line);
        
        var startingIndex: usize = 0;
        var endingIndex: usize = 0;
        var numIndex: usize = 0;
        for (line, 0..) |chr,chrIndex| {
            if (chr == ' ') {
                const firstChr: u8 = line[startingIndex];
                if (p1ReadMode == 0 and firstChr != ' ') {
                    if (firstChr == '*' or firstChr == '+') {
                        //print("just a math symbol: {c}\n", .{firstChr});
                        p1Total += getLineTotal(numbers, numIndex, i, firstChr);
                    } else {
                        const str: []u8 = line[startingIndex..endingIndex + 1];
                        //print("parsing the following string of characters: {s} ({any})\n", .{str,str});
                        const parsedNum: u64 = try parseInt(u64, str, 10);
                        //print("parsed number: {d}\n", .{parsedNum});
                        numbers[numIndex][i] = parsedNum;
                    }
                    numIndex += 1;
                }
                p1ReadMode = 1;
            } else {
                if (p1ReadMode == 1) {
                    startingIndex = chrIndex;
                }
                p1ReadMode = 0;
                endingIndex = chrIndex;
            }
        }
        if (p1ReadMode == 0) {
            //print("reached the end, but still need to process the last value\n", .{});
            const firstChr: u8 = line[startingIndex];
            if (firstChr == '*' or firstChr == '+' or firstChr == '/' or firstChr == '-') {
                //print("just a math symbol: {c}\n", .{firstChr});
                p1Total += getLineTotal(numbers, numIndex, i, firstChr);
            } else {
                const parsedNum: u64 = try parseInt(u64, line[startingIndex..endingIndex + 1], 10);
                //print("parsed number: {d}\n", .{parsedNum});
                numbers[numIndex][i] = parsedNum;
            }
        }
        
        lineLen = line.len;
        i += 1;
    }

    const numLines: usize = i;

    var chrArrArr: [MAX_LINE_BUFFER_SIZE][MAX_NUM_COL_SIZE]u8 = undefined;
    i = 0;
    while (i < MAX_LINE_BUFFER_SIZE) {
        @memset(&chrArrArr[i], 0);
        i += 1;
    }

    var p2Nums: [MAX_LINE_BUFFER_SIZE]u64 = undefined;
    @memset(&p2Nums, 0);

    i = 0;
    var currChrIndex: usize = 0;
    // Iterate through all lines
    while (i < numLines) {
        const line: [MAX_LINE_BUFFER_SIZE]u8 = lines[i];
        //print("line is {s} {any}\n", .{line, line});
        // If on the last line (with the math operators)
        if (i == numLines - 1) {
            //print("this is the last line: {s}\n", .{line});
            var j: usize = 0;
            // Loop through the line
            while (j < line.len) {
                // If on math symbol, denote that as a starting point for a math operation
                if (line[j] == '+' or line[j] == '*') {
                    //print("found a math symbol at index {d}: {c}\n", .{j, line[j]});

                    var l: usize = j;
                    // Loop through all columns that are part of this operation (from start of this math symbol to the next one)
                    //print("line len: {d}\n", .{lineLen});
                    var opTotal: u64 = 0;
                    while (l < lineLen and (l == j or (line[l] != '+' and line[l] != '*'))) {
                        var k: usize = 0;
                        // Loop through all lines at this column (except the last line, with the math operators)
                        while (k < numLines - 1) {
                            const chr: u8 = lines[k][l];
                            //print("reading character {c}\n", .{chr});
                            if (chr != ' ') {
                                chrArrArr[currChrIndex][k] = chr;
                            }
                            k += 1;
                        }

                        //print("read the col as {s} - length {d}\n", .{chrArrArr[currChrIndex], chrArrArr[currChrIndex].len});
                        
                        const lineSlice: []u8 = chrArrArr[currChrIndex][0..];
                        const trimmed: []const u8 = trim(u8, lineSlice, &CHRS_TO_TRIM);

                        //print("trimmed string is {s}\n", .{trimmed});

                        if (trimmed.len > 0) {
                            const num: u64 = try parseInt(u64, trimmed[0..], 10);

                            //print("parsed number is {d}\n", .{num});

                            if (opTotal == 0) {
                                opTotal = num;
                            } else {
                                opTotal = switch (line[j]) {
                                    '*' => opTotal * num,
                                    else => opTotal + num, // '+'
                                };
                            }
                        }

                        currChrIndex += 1;
                        l += 1;
                    }
                    //print("Should end here\n", .{});
                    p2Total += opTotal;
                }
                j += 1;
            }
        }
        i += 1;
    }

    return .{p1Total, p2Total};
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
