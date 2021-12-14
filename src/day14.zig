const std = @import("std");
const string = []const u8;
const range = @import("range").range;

const input = @embedFile("../input/day14.txt");

const Rule = struct {
    left: string,
    right: u8,
};

const CountMap = std.AutoHashMap(u8, u64);

const MemoMap = std.AutoHashMap([2]u8, []?CountMap);

pub fn main() !void {
    //

    // part 1
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var all_rules = std.ArrayList(Rule).init(alloc);
        defer all_rules.deinit();

        // ingest input
        var polymer = std.ArrayList(u8).init(alloc);
        defer polymer.deinit();

        try polymer.appendSlice(iter.next().?);
        std.debug.assert(iter.next().?.len == 0);

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            try all_rules.append(Rule{
                .left = line[0..2],
                .right = line[6],
            });
        }

        // run program
        const steps = 10;

        for (range(steps)) |_| {
            var i: usize = 0;
            blk: while (true) {
                for (all_rules.items) |item| {
                    if (i >= polymer.items.len - 1) {
                        break :blk;
                    }
                    if (std.mem.eql(u8, polymer.items[i..][0..2], item.left)) {
                        try polymer.insert(i + 1, item.right);
                        i += 2;
                    }
                }
            }
        }

        // count the character occurences
        var counts = CountMap.init(alloc);
        defer counts.deinit();

        for (polymer.items) |c| {
            const result = try counts.getOrPut(c);
            if (result.found_existing) {
                result.value_ptr.* += 1;
            } else {
                result.value_ptr.* = 0;
            }
        }

        // find the max and min
        var max: u64 = 0;
        var min: u64 = std.math.maxInt(u64);

        var iter2 = counts.iterator();
        while (iter2.next()) |entry| {
            const value = entry.value_ptr.*;
            if (value > max) max = value;
            if (value < min) min = value;
        }

        // find the difference
        std.debug.print("{d}\n", .{max - min});
    }

    // part 2
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        // ingest input
        var all_rules = std.ArrayList(Rule).init(alloc);
        defer all_rules.deinit();

        const start_string = iter.next().?;
        std.debug.assert(iter.next().?.len == 0);

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            try all_rules.append(Rule{
                .left = line[0..2],
                .right = line[6],
            });
        }

        // setup counts map
        var counts = CountMap.init(alloc);
        defer counts.deinit();

        for (all_rules.items) |item| {
            try counts.put(item.left[0], 0);
            try counts.put(item.left[1], 0);
            try counts.put(item.right, 0);
        }
        for (start_string) |c| {
            const result = counts.getEntry(c);
            result.?.value_ptr.* += 1;
        }

        // setup memoization
        var memo = MemoMap.init(alloc);
        defer memo.deinit();

        const steps = 40;

        // setup memoization
        {
            var kiter1 = counts.keyIterator();
            while (kiter1.next()) |c1| {
                var kiter2 = counts.keyIterator();
                while (kiter2.next()) |c2| {
                    var list = std.ArrayList(?CountMap).init(alloc);
                    defer list.deinit();
                    for (range(steps)) |_| {
                        try list.append(null);
                    }
                    try memo.put(.{ c1.*, c2.* }, list.toOwnedSlice());
                }
            }
        }

        // run program
        for (range(start_string.len - 1)) |_, i| {
            try mergeMaps(&counts, try findCounts(&memo, alloc, all_rules.items, start_string[i..][0..2], steps));
        }

        // find the max and min
        var max: u64 = 0;
        var min: u64 = std.math.maxInt(u64);

        var iter2 = counts.iterator();
        while (iter2.next()) |entry| {
            const value = entry.value_ptr.* - 1;
            if (value > max) max = value;
            if (value < min) min = value;
        }

        // find the difference
        std.debug.print("{d}\n", .{max - min});
    }
}

fn findCounts(memo: *MemoMap, alloc: *std.mem.Allocator, rules: []const Rule, slice: string, max_depth: u64) std.mem.Allocator.Error!CountMap {
    const memo_list = memo.getEntry(slice[0..2].*).?.value_ptr;

    if (memo_list.*[max_depth - 1]) |val| {
        return val;
    }
    if (max_depth == 0) {
        return CountMap.init(undefined);
    }

    for (rules) |item| {
        if (std.mem.eql(u8, slice, item.left)) {
            var counts = CountMap.init(alloc);
            try counts.put(item.right, 1);
            try mergeMaps(&counts, try findCounts(memo, alloc, rules, &[_]u8{ slice[0], item.right }, max_depth - 1));
            try mergeMaps(&counts, try findCounts(memo, alloc, rules, &[_]u8{ item.right, slice[1] }, max_depth - 1));
            memo_list.*[max_depth - 1] = counts;
            return counts;
        }
    }
    unreachable;
}

fn mergeMaps(a: *CountMap, b: CountMap) !void {
    var iter = b.iterator();
    while (iter.next()) |entry| {
        const k = entry.key_ptr.*;
        const v = entry.value_ptr.*;

        const result = try a.getOrPut(k);
        if (result.found_existing) {
            result.value_ptr.* += v;
        } else {
            result.value_ptr.* = v;
        }
    }
    return;
}
