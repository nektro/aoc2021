const std = @import("std");
const string = []const u8;

const input = @embedFile("../input/day03.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // part 1
    {
        var arena = std.heap.ArenaAllocator.init(&gpa.allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var iter = std.mem.split(u8, input, "\n");

        var line = iter.next().?;
        const len = line.len;

        // amount of 0s and 1s per digit
        var list = std.ArrayList([2]u32).init(alloc);
        try list.ensureTotalCapacity(line.len);

        for (line) |_| {
            try list.append([_]u32{ 0, 0 });
        }

        // count 0s and 1s in each place
        while (true) {
            for (line) |c, i| {
                switch (c) {
                    '0' => list.items[i][0] += 1,
                    '1' => list.items[i][1] += 1,
                    else => @panic("non-binary digit"), // trans rights
                }
            }
            if (iter.next()) |ll| {
                line = ll;
                continue;
            }
            break;
        }

        // create string based on whichever digit occured more
        var buf = try std.ArrayList(u8).initCapacity(alloc, len);

        for (list.toOwnedSlice()) |digits, i| {
            if (digits[0] > digits[1]) {
                try buf.append('0');
            }
            if (digits[0] < digits[1]) {
                try buf.append('1');
            }
            if (digits[0] == digits[1]) {
                @panic(try std.fmt.allocPrint(alloc, "same amount of 0s and 1s in {d}th place", .{i}));
            }
        }

        const gamma = try std.fmt.parseUnsigned(u32, buf.toOwnedSlice(), 2);
        const epsilon = ~gamma & (std.math.pow(u32, 2, @intCast(u32, len)) - 1);

        std.debug.print("{d}\n", .{gamma * epsilon});
    }

    // part 2
    {
        var arena = std.heap.ArenaAllocator.init(&gpa.allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var iter = std.mem.split(u8, input, "\n");
        var allnumbers = std.ArrayList(string).init(alloc);

        while (iter.next()) |line| {
            if (line.len == 0) continue;
            try allnumbers.append(line);
        }

        const oxygen_generator = blk: {
            var running = std.ArrayList(string).init(alloc);
            try running.appendSlice(allnumbers.items);

            // go over all digit places
            for (range(running.items.len)) |_, i| {
                var zeroes: u32 = 0;
                var ones: u32 = 0;

                // find which digit appears most often
                for (running.items) |item| {
                    switch (item[i]) {
                        '0' => zeroes += 1,
                        '1' => ones += 1,
                        else => @panic("non-binary digit"),
                    }
                }

                // remove lower frequency items
                var j: usize = 0;
                while (j < running.items.len) {
                    if (zeroes < ones and running.items[j][i] == '0') {
                        _ = running.orderedRemove(j);
                        continue;
                    }
                    if (ones < zeroes and running.items[j][i] == '1') {
                        _ = running.orderedRemove(j);
                        continue;
                    }
                    // oxygen preference for 1
                    if (zeroes == ones and running.items[j][i] == '0') {
                        _ = running.orderedRemove(j);
                        continue;
                    }
                    j += 1;
                }

                if (running.items.len == 1) {
                    break :blk try std.fmt.parseUnsigned(u32, running.items[0], 2);
                }
            }
            @panic("");
        };

        const c02_scrubber = blk: {
            var running = std.ArrayList(string).init(alloc);
            try running.appendSlice(allnumbers.items);

            // go over all digit places
            for (range(running.items.len)) |_, i| {
                var zeroes: u32 = 0;
                var ones: u32 = 0;

                // find which digit appears most often
                for (running.items) |item| {
                    switch (item[i]) {
                        '0' => zeroes += 1,
                        '1' => ones += 1,
                        else => @panic("non-binary digit"),
                    }
                }

                // remove higher frequency items
                var j: usize = 0;
                while (j < running.items.len) {
                    if (zeroes < ones and running.items[j][i] == '1') {
                        _ = running.orderedRemove(j);
                        continue;
                    }
                    if (ones < zeroes and running.items[j][i] == '0') {
                        _ = running.orderedRemove(j);
                        continue;
                    }
                    // C02 preference for 1
                    if (zeroes == ones and running.items[j][i] == '1') {
                        _ = running.orderedRemove(j);
                        continue;
                    }
                    j += 1;
                }

                if (running.items.len == 1) {
                    break :blk try std.fmt.parseUnsigned(u32, running.items[0], 2);
                }
            }
            @panic("");
        };

        std.debug.print("{d}\n", .{oxygen_generator * c02_scrubber});
    }
}

pub fn range(len: usize) []const u0 {
    return @as([*]u0, undefined)[0..len];
}
