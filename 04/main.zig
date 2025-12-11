const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

const MAX_PAPER: usize = 140;

fn isRollOfPaper(tile: u8) bool {
    return tile == '@' or tile == 'd';
}

fn processPaperRolls(paperRollRows: *[MAX_PAPER][MAX_PAPER]u8, numLines: usize, lineLen: usize) !u32 {
    var totalCount: u32 = 0;
    var i: usize = 0;
    //print("the len when inside is {any}x{any}\n", .{paperRollRows.len, paperRollRows[0].len});
    //print("the len passed in is {any}x{any}\n", .{numLines, lineLen});
    while (i < numLines) {
        var j: usize = 0;
        while (j < lineLen) {
            //print("checking tile {c} at {any},{any}\n", .{paperRollRows[i][j], i, j});
            if (!isRollOfPaper(paperRollRows[i][j])) {
                j += 1;
                continue;
            }
            var foundCount: u8 = 0;
            if (i > 0) {
                if (j > 0) {
                    if (isRollOfPaper(paperRollRows[i - 1][j - 1])) {
                        foundCount += 1;
                    }
                }
                if (isRollOfPaper(paperRollRows[i - 1][j])) {
                    foundCount += 1;
                }
                if (j < MAX_PAPER - 1) {
                    if (isRollOfPaper(paperRollRows[i - 1][j + 1])) {
                        foundCount += 1;
                    }
                }
            }
            if (j > 0) {
                if (isRollOfPaper(paperRollRows[i][j - 1])) {
                    foundCount += 1;
                }
            }
            if (j < MAX_PAPER - 1) {
                if (isRollOfPaper(paperRollRows[i][j + 1])) {
                    foundCount += 1;
                }
            }
            if (i < MAX_PAPER - 1) {
                if (j > 0) {
                    if (isRollOfPaper(paperRollRows[i + 1][j - 1])) {
                        foundCount += 1;
                    }
                }
                if (isRollOfPaper(paperRollRows[i + 1][j])) {
                    foundCount += 1;
                }
                if (j < MAX_PAPER - 1) {
                    if (isRollOfPaper(paperRollRows[i + 1][j + 1])) {
                        foundCount += 1;
                    }
                }
            }
            //print("found count for {any},{any} is {any}\n", .{i, j, foundCount});
            if (foundCount < 4) {
                paperRollRows[i][j] = 'd';
                totalCount += 1;
            }
            j += 1;
        }
        i += 1;
    }
    i = 0;
    while (i < numLines) {
        var j: usize = 0;
        while (j < lineLen) {
            //print("looking at tile {c} at {any},{any}\n", .{paperRollRows[i][j], i, j});
            if (paperRollRows[i][j] == 'd') {
                //print("removing paper roll {c} at {any},{any}\n", .{paperRollRows[i][j], i, j});
                paperRollRows[i][j] = 'x';
            }
            j += 1;
        }
        i += 1;
    }
    //print("{any} rolls of paper removed\n", .{totalCount});
    return totalCount;
}

fn processInput() !struct{u32, u32} {
    var stdin_buffer: [512]u8 = undefined;
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: *std.Io.Reader = &stdin_reader_wrapper.interface;

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
    var numLines: usize = 0;
    while (try reader.takeDelimiter('\n')) |line| {
        //print("the line read is {s} {any}\n", .{line, line});
        j = 0;
        while (j < line.len) {
            paperRollRows[i][j] = line[j];
            j += 1;
        }
        i += 1;
        lineLen = line.len;
        numLines += 1;
    }

    //i = 0;
    //while (i < paperRollRows.len) {
    //    print("This line is {any}\n", .{paperRollRows[i]});
    //    i += 1;
    //}

    //print("the len is {any}x{any}\n", .{paperRollRows.len, paperRollRows[0].len});

    // part 1 answer
    var initialRemovalCount: u32 = 0;
    // part 2 answer
    var totalCount: u32 = 0;
    var firstRun: bool = false;
    while (true) {
        const count = try processPaperRolls(&paperRollRows, numLines, lineLen);
        if (count == 0) {
            break;
        }
        if (!firstRun) {
            initialRemovalCount = count;
            firstRun = true;
        }
        totalCount += count;
    }

    //print("-----\n", .{});

    //i = 0;
    //while (i < paperRollRows.len) {
    //    print("This line is {any}\n", .{paperRollRows[i]});
    //    i += 1;
    //}

    return .{initialRemovalCount, totalCount};
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
