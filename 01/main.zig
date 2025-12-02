const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

const Dial = struct {
    currPosition: i32,

    pub fn rotate(self: *Dial, val: i32) void {
        self.currPosition = @mod(self.currPosition + val, 100);
    }
};

test "expect dial rotates to the left" {
    var dial = Dial{
        .currPosition = 3,
    };

    dial.rotate(-1);

    try expect(dial.currPosition == 2);
}

test "expect dial rotates to the right" {
    var dial = Dial{
        .currPosition = 3,
    };

    dial.rotate(1);

    try expect(dial.currPosition == 4);
}

test "expect dial to wrap around" {
    var dial = Dial{
        .currPosition = 0,
    };

    dial.rotate(-1);

    try expect(dial.currPosition == 99);

    dial.rotate(1);

    try expect(dial.currPosition == 0);
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
    };

    //print("{}\n", dial);

    const result = processInput(&dial);

    var stdout_buffer: [512]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.Io.Writer = &stdout_writer.interface;
    try stdout.print("{any}\n", .{result});
    try stdout.flush();

    //print("{}", dial);
}
