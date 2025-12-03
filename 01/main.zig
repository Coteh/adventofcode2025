const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

const Dial = struct {
    currPosition: i32,
    numClicks: u32,

    pub fn rotate(self: *Dial, val: i32) void {
        const translated: i32 = self.currPosition + val;
        self.resolveClicks(val, translated);
        self.currPosition = @mod(translated, 100);
    }

    fn resolveClicks(self: *Dial, val: i32, translated: i32) void {
        var currTranslated: i32 = translated;
        if (val > 0) {
            var numIterated: u32 = 0;
            while (currTranslated >= 100) {
                self.numClicks += 1;
                currTranslated -= 100;
                numIterated += 1;
            }
            if (currTranslated != translated and self.currPosition != 0 and numIterated == 0) {
                self.numClicks += 1;
            }
        } else {
            while (currTranslated <= -100) {
                self.numClicks += 1;
                currTranslated += 100;
            }
            if (currTranslated <= 0 and self.currPosition != 0) {
                self.numClicks += 1;
            }
        }
    }
};

test "expect dial rotates to the left" {
    var dial = Dial{
        .currPosition = 3,
        .numClicks = 0,
    };

    dial.rotate(-1);

    try expect(dial.currPosition == 2);
}

test "expect dial rotates to the right" {
    var dial = Dial{
        .currPosition = 3,
        .numClicks = 0,
    };

    dial.rotate(1);

    try expect(dial.currPosition == 4);
}

test "expect dial to wrap around" {
    var dial = Dial{
        .currPosition = 0,
        .numClicks = 0,
    };

    dial.rotate(-1);

    try expect(dial.currPosition == 99);

    dial.rotate(1);

    try expect(dial.currPosition == 0);
}

test "expect dial to report number of clicks when rotating" {
    var dial = Dial{
        .currPosition = 50,
        .numClicks = 0,
    };

    dial.rotate(-60);

    try expect(dial.numClicks == 1);

    dial.rotate(150);

    try expect(dial.numClicks == 3);
}

test "expect a click when it goes from the leftmost side to rightmost" {
    var dial = Dial{
        .currPosition = 1,
        .numClicks = 0,
    };

    dial.rotate(-2);

    try expect(dial.currPosition == 99);
    try expect(dial.numClicks == 1);
}

test "expect a click when it goes from the rightmost side to leftmost" {
    var dial = Dial{
        .currPosition = 99,
        .numClicks = 0,
    };

    dial.rotate(2);

    try expect(dial.currPosition == 1);
    try expect(dial.numClicks == 1);
}

test "expect a click when it lands on 0 from the left" {
    var dial = Dial{
        .currPosition = 55,
        .numClicks = 0,
    };

    dial.rotate(-55);

    try expect(dial.currPosition == 0);
    try expect(dial.numClicks == 1);
}

test "expect a click when it lands on 0 from the right" {
    var dial = Dial{
        .currPosition = 55,
        .numClicks = 0,
    };

    dial.rotate(45);

    try expect(dial.currPosition == 0);
    try expect(dial.numClicks == 1);
}

test "expect no click if starting from 0 and rotating to the left" {
    var dial = Dial{
        .currPosition = 0,
        .numClicks = 0,
    };

    dial.rotate(-5);

    try expect(dial.currPosition == 95);
    try expect(dial.numClicks == 0);
}

test "expect no click if starting from 0 and rotating to the right" {
    var dial = Dial{
        .currPosition = 0,
        .numClicks = 0,
    };

    dial.rotate(5);

    try expect(dial.currPosition == 5);
    try expect(dial.numClicks == 0);
}

test "expect only one click counted if starting from 0 and doing a full wrap around to the left" {
    var dial = Dial{
        .currPosition = 0,
        .numClicks = 0,
    };

    dial.rotate(-105);

    try expect(dial.currPosition == 95);
    try expect(dial.numClicks == 1);
}

test "expect only one click counted if starting from 0 and doing a full wrap around to the right" {
    var dial = Dial{
        .currPosition = 0,
        .numClicks = 0,
    };

    dial.rotate(105);

    try expect(dial.currPosition == 5);
    try expect(dial.numClicks == 1);
}

test "expect a click when it lands on 1 from the right" {
    var dial = Dial{
        .currPosition = 55,
        .numClicks = 0,
    };

    dial.rotate(46);

    try expect(dial.currPosition == 1);
    try expect(dial.numClicks == 1);
}

test "expect a click when it lands on 98 from the left" {
    var dial = Dial{
        .currPosition = 55,
        .numClicks = 0,
    };

    dial.rotate(-57);

    try expect(dial.currPosition == 98);
    try expect(dial.numClicks == 1);
}

test "expect one click when starting from 0 and rotating exactly 100 to the left" {
    var dial = Dial{
        .currPosition = 0,
        .numClicks = 0,
    };

    dial.rotate(-100);

    try expect(dial.currPosition == 0);
    try expect(dial.numClicks == 1);
}

test "expect one click when starting from 0 and rotating exactly 100 to the right" {
    var dial = Dial{
        .currPosition = 0,
        .numClicks = 0,
    };

    dial.rotate(100);

    try expect(dial.currPosition == 0);
    try expect(dial.numClicks == 1);
}

test "expect only two clicks when starting from 0 and rotating exactly 200 to the left" {
    var dial = Dial{
        .currPosition = 0,
        .numClicks = 0,
    };

    dial.rotate(-200);

    try expect(dial.currPosition == 0);
    try expect(dial.numClicks == 2);
}

test "expect only two clicks when starting from 0 and rotating exactly 200 to the right" {
    var dial = Dial{
        .currPosition = 0,
        .numClicks = 0,
    };

    dial.rotate(200);

    try expect(dial.currPosition == 0);
    try expect(dial.numClicks == 2);
}

test "expect only one click when starting from 0 and rotating exactly 150 to the left" {
    var dial = Dial{
        .currPosition = 0,
        .numClicks = 0,
    };

    dial.rotate(-150);

    try expect(dial.currPosition == 50);
    try expect(dial.numClicks == 1);
}

test "expect only one click when starting from 0 and rotating exactly 150 to the right" {
    var dial = Dial{
        .currPosition = 0,
        .numClicks = 0,
    };

    dial.rotate(150);

    try expect(dial.currPosition == 50);
    try expect(dial.numClicks == 1);
}

test "expect two clicks when starting from 50 and rotating 160 to the right" {
    var dial = Dial{
        .currPosition = 50,
        .numClicks = 0,
    };

    dial.rotate(160);

    try expect(dial.currPosition == 10);
    try expect(dial.numClicks == 2);
}

test "expect no clicks when starting from 50 and rotating 1 to the right" {
    var dial = Dial{
        .currPosition = 50,
        .numClicks = 0,
    };

    dial.rotate(1);

    try expect(dial.currPosition == 51);
    try expect(dial.numClicks == 0);
}

test "expect no clicks when starting from 50 and rotating 1 to the left" {
    var dial = Dial{
        .currPosition = 50,
        .numClicks = 0,
    };

    dial.rotate(-1);

    try expect(dial.currPosition == 49);
    try expect(dial.numClicks == 0);
}

fn processInput(dial: *Dial) !i32 {
    var stdin_buffer: [512]u8 = undefined;
    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: *std.Io.Reader = &stdin_reader_wrapper.interface;

    //var stdout_buffer: [512]u8 = undefined;
    //var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    //const stdout: *std.Io.Writer = &stdout_writer.interface;

    var num_times_zero: i32 = 0;

    while (try reader.takeDelimiter('\n')) |line| {
        const direction: u8 = line[0];
        var lineVal: []u8 = line[1..];
        if (lineVal[lineVal.len - 1] == 13) {
            //print("Damn Windows\n", .{});
            lineVal = lineVal[0..lineVal.len - 1];
        }
        var value: i32 = try parseInt(i32, lineVal, 10);
        value = switch (direction) {
            'L' => -value,
            else => value,
        };
        //try stdout.print("{c} {d}", .{direction, value});
        //try stdout.writeAll("\n");
        //try stdout.flush();
        dial.rotate(value);
        //print("curr position: {}\n", .{dial.currPosition});
        if (dial.currPosition == 0) {
            num_times_zero += 1;
        }
    }

    return num_times_zero;
}

pub fn main() !void {
    var dial = Dial{
        .currPosition = 50,
        .numClicks = 0,
    };

    //print("{}\n", dial);

    const result = processInput(&dial);

    var stdout_buffer: [512]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.Io.Writer = &stdout_writer.interface;
    try stdout.print("{any}\n", .{result});
    try stdout.print("{any}\n", .{dial.numClicks});
    try stdout.flush();

    //print("{}", dial);
}
