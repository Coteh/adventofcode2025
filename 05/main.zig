const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

const NumberRange = struct{ start: u64, end: u64 };

const WorkingRange = struct{ start: u64, end: u64, invalid: bool };

fn isFresh(numRanges: []NumberRange, numToEvaluate: u64) bool {
    var result: bool = false;
    var i: usize = 0;
    while (i < numRanges.len) {
        const numRange: NumberRange = numRanges[i];
        //print("{any} evaulating num {any} against range {any}\n", .{i, numToEvaluate, numRange});
        if (numToEvaluate >= numRange.start and numToEvaluate <= numRange.end) {
            //print("is fresh!\n", .{});
            result = true;
            break;
        }
        i += 1;
    }
    return result;
}

// Returns the total count of fresh ingredients in numRange that are also not in the otherRanges
fn findNonOverlapCountBetweenRanges(numRange: NumberRange, otherRanges: []NumberRange) u128 {
    // working ranges consist of non-overlapped sections of the number range
    var workingRanges: [100]WorkingRange = undefined;
    @memset(&workingRanges, undefined);

    // the entire range being checked starts off as non-overlapped
    workingRanges[0] = WorkingRange{
        .start = numRange.start,
        .end = numRange.end,
        .invalid = false,
    };
    var maxWorkingRanges: usize = 1;

    //print("finding non-overlapped count for range {any}\n", .{numRange});

    // loop through all the ranges that have been passed in to check which areas of them overlap
    // with the working ranges
    var i: usize = 0;
    while (i < otherRanges.len) {
        const otherRange: NumberRange = otherRanges[i];
        var j: usize = 0;
        // compare this range against all valid working ranges
        while (j < maxWorkingRanges) {
            const workingRange: WorkingRange = workingRanges[j];

            //print("using this working range at index {d}: {any}\n", .{j, workingRange});

            // if there was an overlap detected in this range (ie. this working range is invalid),
            // then skip it
            if (workingRange.invalid) {
                j += 1;
                continue;
            }

            // if this range fully encompasses the working range, then early return 0
            if (workingRange.start >= otherRange.start and workingRange.end <= otherRange.end) {
                //print("special case: the entire range {any} is contained within range: {any}\n", .{workingRange, otherRange});
                return 0;
            }

            var overlapFound: bool = false;
            // if this range is fully within this working range
            if (otherRange.start >= workingRange.start and otherRange.end <= workingRange.end) {
                //print("fully within detected\n", .{});
                // create two new working ranges where there is no overlap
                const newWorkingRange1: WorkingRange = WorkingRange{
                    .start = workingRange.start,
                    .end = otherRange.start - 1,
                    .invalid = false,
                };
                const newWorkingRange2: WorkingRange = WorkingRange{
                    .start = otherRange.end + 1,
                    .end = workingRange.end,
                    .invalid = false,
                };

                // if either of these new working ranges have a start that's greater than the end,
                // then the other ranges are on the edge of this working range; do not include the new working range
                if (newWorkingRange1.start <= newWorkingRange1.end) {
                    workingRanges[maxWorkingRanges] = newWorkingRange1;
                    maxWorkingRanges += 1;
                }
                if (newWorkingRange2.start <= newWorkingRange2.end) {
                    workingRanges[maxWorkingRanges] = newWorkingRange2;
                    maxWorkingRanges += 1;
                }

                overlapFound = true;
            // if this range overlaps with working range from the right
            } else if (otherRange.start >= workingRange.start and otherRange.start <= workingRange.end) {
                //print("left side detected\n", .{});
                // create one new working range to represent the range on the left that is not overlapped
                const newWorkingRange: WorkingRange = WorkingRange{
                    .start = workingRange.start,
                    .end = otherRange.start - 1,
                    .invalid = false,
                };

                workingRanges[maxWorkingRanges] = newWorkingRange;
                maxWorkingRanges += 1;

                overlapFound = true;
            // if this range overlaps with working range from the left
            } else if (otherRange.end <= workingRange.end and otherRange.end >= workingRange.start) {
                //print("right side detected\n", .{});
                // create one new working range to represent the range on the right that is not overlapped
                const newWorkingRange: WorkingRange = WorkingRange{
                    .start = otherRange.end + 1,
                    .end = workingRange.end,
                    .invalid = false,
                };

                workingRanges[maxWorkingRanges] = newWorkingRange;
                maxWorkingRanges += 1;

                overlapFound = true;
            }

            // if there was an overlap, mark the working range as invalid so it doesn't get checked again
            if (overlapFound) {
                workingRanges[j].invalid = true;
            }

            j += 1;
        }
        
        i += 1;
    }

    // the final non-overlapped range count will be the total of all active non-overlapped areas
    var totalNonOverlappedCount: u128 = 0;
    i = 0;
    while (i < maxWorkingRanges) {
        const workingRange = workingRanges[i];
        if (!workingRange.invalid) {
            totalNonOverlappedCount += workingRange.end - workingRange.start + 1;
        }
        i += 1;
    }

    //print("totalNonOverlappedCount: {any}\n", .{totalNonOverlappedCount});

    return totalNonOverlappedCount;
}

test "findNonOverlapCountBetweenRanges should return 2 for range 5-8 compared to 3-6 (right side case #1)" {
    var ranges: [2]NumberRange = [_]NumberRange{
        NumberRange{
            .start = 3,
            .end = 6,
        },
        NumberRange{
            .start = 5,
            .end = 8,
        },
    };
    const count = findNonOverlapCountBetweenRanges(ranges[1], ranges[0..1]);
    try expect(count == 2);
}

test "findNonOverlapCountBetweenRanges should return 10 for ranges 10-30 compared to 5-20 (right side case #2)" {
    var ranges: [2]NumberRange = [_]NumberRange{
        NumberRange{
            .start = 5,
            .end = 20,
        },
        NumberRange{
            .start = 10,
            .end = 30,
        },
    };
    const count = findNonOverlapCountBetweenRanges(ranges[1], ranges[0..1]);
    try expect(count == 10);
}

test "findNonOverlapCountBetweenRanges should return 5 for ranges 5-20 compared to 10-30 (left side case)" {
    var ranges: [2]NumberRange = [_]NumberRange{
        NumberRange{
            .start = 10,
            .end = 30,
        },
        NumberRange{
            .start = 5,
            .end = 20,
        },
    };
    const count = findNonOverlapCountBetweenRanges(ranges[1], ranges[0..1]);
    try expect(count == 5);
}

test "findNonOverlapCountBetweenRanges should return 2 for ranges 1-6 compared to 2-5 (all-encompassing case #1)" {
    var ranges: [2]NumberRange = [_]NumberRange{
        NumberRange{
            .start = 2,
            .end = 5,
        },
        NumberRange{
            .start = 1,
            .end = 6,
        },
    };
    const count = findNonOverlapCountBetweenRanges(ranges[1], ranges[0..1]);
    try expect(count == 2);
}

// https://www.reddit.com/r/adventofcode/comments/1prm5lk/comment/nv2x11m/
// This comment from u/SpecificMachine1 helped me realize all-encompassing cases #2 and #3
// The edge case they mentioned was:
//     120-130
//     130-130
// I already knew how to handle combined ranges from all-encompassing case #1, but if the range
// that was combined was on the edge, I needed to make sure an extra working range wasn't created for that side.
test "findNonOverlapCountBetweenRanges should return 9 if comparing 1-10 to 10-10 (all-encompassing case #2)" {
    var ranges: [2]NumberRange = [_]NumberRange{
        NumberRange{
            .start = 10,
            .end = 10,
        },
        NumberRange{
            .start = 1,
            .end = 10,
        },
    };
    const count = findNonOverlapCountBetweenRanges(ranges[1], ranges[0..1]);
    try expect(count == 9);
}

test "findNonOverlapCountBetweenRanges should return 8 if comparing 1-10 to 1-2 (all-encompassing case #3)" {
    var ranges: [2]NumberRange = [_]NumberRange{
        NumberRange{
            .start = 1,
            .end = 2,
        },
        NumberRange{
            .start = 1,
            .end = 10,
        },
    };
    const count = findNonOverlapCountBetweenRanges(ranges[1], ranges[0..1]);
    try expect(count == 8);
}

test "findNonOverlapCountBetweenRanges should return 4 for ranges 2-10 compared to 1-5 and 10-12 (double overlap case)" {
    var ranges: [3]NumberRange = [_]NumberRange{
        NumberRange{
            .start = 1,
            .end = 5,
        },
        NumberRange{
            .start = 10,
            .end = 12,
        },
        NumberRange{
            .start = 2,
            .end = 10,
        },
    };
    const count = findNonOverlapCountBetweenRanges(ranges[2], ranges[0..2]);
    try expect(count == 4);
}

test "findNonOverlapCountBetweenRanges should return 0 for ranges 3-4 compared to 2-5 (entirely within case)" {
    var ranges: [2]NumberRange = [_]NumberRange{
        NumberRange{
            .start = 2,
            .end = 5,
        },
        NumberRange{
            .start = 3,
            .end = 4,
        },
    };
    const count = findNonOverlapCountBetweenRanges(ranges[1], ranges[0..1]);
    try expect(count == 0);
}

test "findNonOverlapCountBetweenRanges should return the full range if there are no ranges to compare to" {
    var ranges: [1]NumberRange = [_]NumberRange{
        NumberRange{
            .start = 2,
            .end = 5,
        },
    };
    const count = findNonOverlapCountBetweenRanges(ranges[0], ranges[0..0]);
    try expect(count == 4);
}

test "findNonOverlapCountBetweenRanges should return 1 if comparing 1-1 to 2-2, 3-3, 4-4, and 5-5" {
    var ranges: [5]NumberRange = [_]NumberRange{
        NumberRange{
            .start = 2,
            .end = 2,
        },
        NumberRange{
            .start = 3,
            .end = 3,
        },
        NumberRange{
            .start = 4,
            .end = 4,
        },
        NumberRange{
            .start = 5,
            .end = 5,
        },
        NumberRange{
            .start = 1,
            .end = 1,
        },
    };
    const count = findNonOverlapCountBetweenRanges(ranges[4], ranges[0..4]);
    try expect(count == 1);
}

test "findNonOverlapCountBetweenRanges should return 9 if comparing 1-10 to 4-4 (working range should split)" {
    var ranges: [2]NumberRange = [_]NumberRange{
        NumberRange{
            .start = 4,
            .end = 4,
        },
        NumberRange{
            .start = 1,
            .end = 10,
        },
    };
    const count = findNonOverlapCountBetweenRanges(ranges[1], ranges[0..1]);
    try expect(count == 9);
}

test "findNonOverlapCountBetweenRanges should return 0 for ranges 2-5 compared to 2-5 (it's the same range)" {
    var ranges: [2]NumberRange = [_]NumberRange{
        NumberRange{
            .start = 2,
            .end = 5,
        },
        NumberRange{
            .start = 2,
            .end = 5,
        },
    };
    const count = findNonOverlapCountBetweenRanges(ranges[1], ranges[0..1]);
    try expect(count == 0);
}

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
            if (isFresh(numRanges[0..numRangesRead], numToEvaluate)) {
                freshCount += 1;
            }
        }
    }

    var totalNumFresh: u128 = 0;
    var i: usize = 0;
    while (i < numRangesRead) {
        const numRange: NumberRange = numRanges[i];

        //print("Finding total non-overlapped count of freshness for range {any}\n", .{numRange});

        const nonOverlappedCount: u128 = findNonOverlapCountBetweenRanges(numRange, numRanges[0..i]);

        //print("non-overlapped fresh count for this range is {any}\n", .{nonOverlappedCount});

        totalNumFresh += nonOverlappedCount;

        //print("totalNumFresh so far: {any}\n", .{totalNumFresh});
    
        i += 1;
    }

    return .{freshCount, totalNumFresh};
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
