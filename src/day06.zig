const std = @import("std");
const string = []const u8;
const range = @import("range").range;

const input = @embedFile("../input/day06.txt");

pub fn main() !void {

    // part 1
    {
        var iter = std.mem.split(u8, std.mem.trim(u8, input, "\n"), ",");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var list = std.ArrayList(u32).init(alloc);
        defer list.deinit();

        while (iter.next()) |num_s| {
            try list.append(std.fmt.parseUnsigned(u32, num_s, 10) catch @panic(""));
        }

        const days = 80;

        for (range(days)) |_| {
            for (list.items) |*x| {
                if (x.* == 0) {
                    x.* = 6;
                    try list.append(8);
                } else {
                    x.* -= 1;
                }
            }
        }

        std.debug.print("{d}\n", .{list.items.len});
    }

    // part 2
    {
        var iter = std.mem.split(u8, std.mem.trim(u8, input, "\n"), ",");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var list = std.ArrayList(u32).init(alloc);
        defer list.deinit();
        try list.append(0);

        const days = 256;
        var fish_count: [days]usize = undefined;

        for (range(days)) |_, i| {
            for (list.items) |*x| {
                if (x.* == 0) {
                    x.* = 6;
                    try list.append(8);
                } else {
                    x.* -= 1;
                }
            }
            fish_count[i] = list.items.len;
        }

        var total: usize = 0;
        while (iter.next()) |num_s| {
            const num = std.fmt.parseUnsigned(u32, num_s, 10) catch @panic("");
            total += fish_count[days - num - 1];
        }

        std.debug.print("{d}\n", .{total});
    }
}
