const std = @import("std");
const string = []const u8;

const input = @embedFile("../input/day02.txt");

const Direction = enum {
    forward,
    down,
    up,
};

pub fn main() !void {

    // part 1
    {
        var iter = std.mem.split(u8, input, "\n");

        var horizontal: u32 = 0;
        var depth: u32 = 0;

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            const space = std.mem.indexOfScalar(u8, line, ' ').?;
            const direction = std.meta.stringToEnum(Direction, line[0..space]).?;
            const amount = try std.fmt.parseUnsigned(u32, line[space + 1 ..], 10);

            switch (direction) {
                .forward => horizontal += amount,
                .down => depth += amount,
                .up => depth -= amount,
            }
        }

        std.debug.print("{d}\n", .{horizontal * depth});
    }

    // part 2
    {
        var iter = std.mem.split(u8, input, "\n");

        var horizontal: u32 = 0;
        var depth: u32 = 0;
        var aim: u32 = 0;

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            const space = std.mem.indexOfScalar(u8, line, ' ').?;
            const direction = std.meta.stringToEnum(Direction, line[0..space]).?;
            const amount = try std.fmt.parseUnsigned(u32, line[space + 1 ..], 10);

            switch (direction) {
                .forward => {
                    horizontal += amount;
                    depth += aim * amount;
                },
                .down => aim += amount,
                .up => aim -= amount,
            }
        }

        std.debug.print("{d}\n", .{horizontal * depth});
    }
}
