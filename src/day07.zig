const std = @import("std");
const string = []const u8;

const input = @embedFile("../input/day07.txt");

pub fn main() !void {
    //

    var iter = std.mem.split(u8, std.mem.trim(u8, input, "\n"), ",");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = &arena.allocator;

    var list = std.ArrayList(u32).init(alloc);
    defer list.deinit();

    while (iter.next()) |num_s| {
        const num = std.fmt.parseUnsigned(u32, num_s, 10) catch @panic("");
        try list.append(num);
    }

    const items = list.toOwnedSlice();

    const min = minL(items);
    const max = maxL(items);

    {
        var cheapest: u32 = std.math.maxInt(u32);
        var i = min;
        while (i <= max) : (i += 1) {
            cheapest = std.math.min(cheapest, fuelCost1(items, i));
        }

        std.debug.print("{d}\n", .{cheapest});
    }

    {
        var cheapest: u32 = std.math.maxInt(u32);
        var i = min;
        while (i <= max) : (i += 1) {
            cheapest = std.math.min(cheapest, fuelCost2(items, i));
        }

        std.debug.print("{d}\n", .{cheapest});
    }
}

fn minL(slice: []const u32) u32 {
    return minI(slice[0], slice[1..]);
}
fn minI(runner: u32, slice: []const u32) u32 {
    if (slice.len == 0) return runner;
    return minI(std.math.min(runner, slice[0]), slice[1..]);
}

fn maxL(slice: []const u32) u32 {
    return maxI(slice[0], slice[1..]);
}
fn maxI(runner: u32, slice: []const u32) u32 {
    if (slice.len == 0) return runner;
    return maxI(std.math.max(runner, slice[0]), slice[1..]);
}

fn fuelCost1(slice: []const u32, to: u32) u32 {
    var ret: u32 = 0;
    for (slice) |item| {
        ret += @intCast(u32, std.math.absInt(@intCast(i32, item) - @intCast(i32, to)) catch @panic(""));
    }
    return ret;
}

fn fuelCost2(slice: []const u32, to: u32) u32 {
    var ret: u32 = 0;
    for (slice) |item| {
        const dist = @intCast(u32, std.math.absInt(@intCast(i32, item) - @intCast(i32, to)) catch @panic(""));
        ret += (dist * (dist + 1)) / 2;
    }
    return ret;
}
