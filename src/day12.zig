const std = @import("std");
const string = []const u8;

const input = @embedFile("../input/day12.txt");
// const input =
//     \\start-A
//     \\start-b
//     \\A-c
//     \\A-b
//     \\b-d
//     \\A-end
//     \\b-end
// ;

const List = std.ArrayList(string);
const Map = std.StringHashMap(List);

pub fn main() !void {
    //

    // part 1
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var paths = Map.init(alloc);
        defer paths.deinit();

        while (iter.next()) |line| {
            if (line.len == 0) continue;
            const index = std.mem.indexOfScalar(u8, line, '-').?;
            const left = line[0..index];
            const right = line[index + 1 ..];

            try addPath(alloc, &paths, left, right);
            try addPath(alloc, &paths, right, left);
        }

        const count = try allPathsFrom(alloc, &paths, "start", null, null);
        std.debug.print("{d}\n", .{count});
    }

    // part 2
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var paths = Map.init(alloc);
        defer paths.deinit();

        while (iter.next()) |line| {
            if (line.len == 0) continue;
            const index = std.mem.indexOfScalar(u8, line, '-').?;
            const left = line[0..index];
            const right = line[index + 1 ..];

            try addPath(alloc, &paths, left, right);
            try addPath(alloc, &paths, right, left);
        }

        var small_caves = List.init(alloc);
        defer small_caves.deinit();

        var iter2 = paths.keyIterator();
        while (iter2.next()) |k| {
            if (std.ascii.isUpper(k.*[0])) continue; // skip big caves
            if (std.mem.eql(u8, k.*, "start")) continue;
            if (std.mem.eql(u8, k.*, "end")) continue;
            try small_caves.append(k.*);
        }

        var count: u32 = 0;
        count += try allPathsFrom(alloc, &paths, "start", null, null);

        for (small_caves.items) |item| {
            count += try allPathsFrom(alloc, &paths, "start", null, item);
        }

        std.debug.print("{d}\n", .{count});
    }
}

fn addPath(alloc: *std.mem.Allocator, paths: *Map, from: string, to: string) !void {
    if (paths.getEntry(from)) |entry| {
        try entry.value_ptr.append(to);
    } else {
        var list = try alloc.create(List);
        list.* = List.init(alloc);
        try list.append(to);
        try paths.put(from, list.*);
    }
}

fn allPathsFrom(alloc: *std.mem.Allocator, paths: *Map, start: string, visited: ?[]const string, can_visit_again: ?string) std.mem.Allocator.Error!u32 {
    if (visited) |_| {
        if (std.mem.eql(u8, start, "end")) {
            if (can_visit_again) |_| {
                return @boolToInt(itemCount(visited.?, can_visit_again.?) > 1);
            }
            return 1;
        }
        var count: u32 = 0;
        const available = paths.get(start).?;
        for (available.items) |new_node| {
            if (std.ascii.isLower(new_node[0])) { // small cave
                var allowed: u32 = 1;
                if (can_visit_again) |_| {
                    if (std.mem.eql(u8, new_node, can_visit_again.?)) {
                        allowed += 1;
                    }
                }
                if (itemCount(visited.?, new_node) >= allowed) { // visited before
                    continue; // skip
                }
            }
            var list = List.init(alloc);
            defer list.deinit();
            try list.appendSlice(visited.?);
            try list.append(new_node);
            count += try allPathsFrom(alloc, paths, new_node, list.items, can_visit_again);
        }
        return count;
    }

    return try allPathsFrom(alloc, paths, start, &[_]string{start}, can_visit_again);
}

fn itemCount(haystack: []const string, needle: string) u32 {
    var count: u32 = 0;
    for (haystack) |item| {
        if (std.mem.eql(u8, item, needle)) {
            count += 1;
        }
    }
    return count;
}
