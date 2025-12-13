const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

const NumberRange = struct{ start: u64, end: u64 };

fn processInput() !struct{u32, u128} {
    var stdin_buffer: [512]u8 = undefined;
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: *std.Io.Reader = &stdin_reader_wrapper.interface;

    var numRanges: [180]NumberRange = undefined;
    @memset(&numRanges, undefined);

    var read_mode: u8 = 0;
    var numRangesRead: usize = 0;
    var freshCount: u32 = 0;
    while (try reader.takeDelimiter('\n')) |line| {
        //print("the line read is {s} {any}\n", .{line, line});
        if (read_mode == 0) {
            if (line.len == 0) {
                //print("Go to next mode? Number ranges: {any}\n", .{numRanges});
                read_mode = 1;
                continue;
            }
            var i: usize = 0;
            while (i < line.len and line[i] != '-') {
                i += 1;
            }
            //print("need to split at index {any}\n", .{i});
            const startRange: u64 = try parseInt(u64, line[0..i], 10);
            const endRange: u64 = try parseInt(u64, line[i + 1..], 10);
            //print("start range is {any} and end range is {any}\n", .{startRange, endRange});
            numRanges[numRangesRead] = NumberRange{
                .start = startRange, 
                .end = endRange
            };
            numRangesRead += 1;
        } else {
            const numToEvaluate: u64 = try parseInt(u64, line[0..line.len], 10);
            var i: usize = 0;
            var isFresh: bool = false;
            while (i < numRangesRead) {
                const numRange: NumberRange = numRanges[i];
                //print("{any} evaulating num {any} against range {any}\n", .{i, numToEvaluate, numRange});
                if (numToEvaluate >= numRange.start and numToEvaluate <= numRange.end) {
                    //print("is fresh!\n", .{});
                    isFresh = true;
                    break;
                }
                i += 1;
            }
            if (isFresh) {
                freshCount += 1;
            }
        }
    }

    // TODO: Find a better solution to part 2. This is too slow.
    //var numFresh: u128 = 0;
    //var i: usize = 0;
    //while (i < numRangesRead) {
    //    const numRange: NumberRange = numRanges[i];
    //
    //    var j: u64 = numRange.start;
    //    while (j <= numRange.end) {
    //        var k: usize = 0;
    //
    //        var isInOtherRanges: bool = false;
    //        while (k < i) {
    //            const otherRange: NumberRange = numRanges[k];
    //
    //            if (j >= otherRange.start and j <= otherRange.end) {
    //                //print("number {any} is also in range {any}-{any}\n", .{j, otherRange.start, otherRange.end});
    //                isInOtherRanges = true;
    //                break;
    //            }
    //
    //            k += 1;
    //        }
    //        if (!isInOtherRanges) {
    //            numFresh += 1;
    //        }
    //
    //        j += 1;
    //    }
    //
    //    i += 1;
    //}

    return .{freshCount, 0}; // numFresh};
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
    //try stdout.print("{any}\n", .{result[1]});
    try stdout.flush();
}
