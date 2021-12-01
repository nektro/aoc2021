const std = @import("std");
const string = []const u8;

const input = @embedFile("../input/day01.txt");

pub fn main() !void {

    // part 1
    {
        var iter = std.mem.split(u8, input, "\n");
        var number: u32 = try std.fmt.parseUnsigned(u32, iter.next().?, 10);
        var increases: u32 = 0;

        while (iter.next()) |item| {
            if (item.len == 0) continue;
            var num = try std.fmt.parseUnsigned(u32, item, 10);
            if (num > number) increases += 1;
            number = num;
        }

        std.debug.print("{d}\n", .{increases});
    }

    // part 2
    {
        var iter = std.mem.split(u8, input, "\n");
        var buf = [_]u32{
            (try next(&iter)).?,
            (try next(&iter)).?,
            (try next(&iter)).?,
        };
        var start: usize = 0;
        var sum = buf[0] + buf[1] + buf[2];
        var increases: u32 = 0;

        while (try next(&iter)) |num| {
            buf[start] = num;
            start += 1;
            start %= buf.len;
            const newsum =
                buf[(start + 0) % buf.len] +
                buf[(start + 1) % buf.len] +
                buf[(start + 2) % buf.len];
            if (newsum > sum) increases += 1;
            sum = newsum;
        }

        std.debug.print("{d}\n", .{increases});
    }
}

fn next(iter: *std.mem.SplitIterator(u8)) !?u32 {
    const n = iter.next();
    if (n == null) return null;
    if (n.?.len == 0) return null;
    return try std.fmt.parseUnsigned(u32, n.?, 10);
}
