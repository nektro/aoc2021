const std = @import("std");
const string = []const u8;
const range = @import("range").range;

const input = @embedFile("../input/day15.txt");

const Point = struct {
    x: usize,
    y: usize,

    fn neighbors(self: Point, s: usize) [4]?Point {
        return .{
            if (self.y == 0) null else .{ .x = self.x, .y = self.y - 1 },
            if (self.y == s - 1) null else .{ .x = self.x, .y = self.y + 1 },
            if (self.x == 0) null else .{ .x = self.x - 1, .y = self.y },
            if (self.x == s - 1) null else .{ .x = self.x + 1, .y = self.y },
        };
    }

    fn toPlus(self: Point, cost: u32) PointPlus {
        return .{ .x = self.x, .y = self.y, .cost = cost };
    }
};

const PointPlus = struct {
    x: usize,
    y: usize,
    cost: u32,

    fn toPoint(self: PointPlus) Point {
        return .{ .x = self.x, .y = self.y };
    }
};

pub fn main() !void {
    //

    // part 1
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var grid = std.ArrayList([]u32).init(alloc);
        defer grid.deinit();

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            var list = std.ArrayList(u32).init(alloc);
            defer list.deinit();
            for (line) |_, i| {
                try list.append(try std.fmt.parseUnsigned(u32, line[i..][0..1], 10));
            }
            try grid.append(list.toOwnedSlice());
        }

        const graph = grid.toOwnedSlice();
        const shortest = try shortestPath(alloc, graph);

        std.debug.print("{d}\n", .{shortest});
    }

    // part 2
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var grid = std.ArrayList([]u32).init(alloc);
        defer grid.deinit();

        var col_i: usize = 0;
        while (iter.next()) |line| {
            if (line.len == 0) continue;

            var list = std.ArrayList(u32).init(alloc);
            defer list.deinit();
            var row_i: usize = 0;
            for (line) |_| {
                try list.append(try std.fmt.parseUnsigned(u32, line[row_i..][0..1], 10));
                row_i += 1;
            }
            const l = list.items.len;

            for (range(4)) |_| {
                for (range(l)) |_| {
                    try list.append(list.items[row_i - l] % 9 + 1);
                    row_i += 1;
                }
            }

            try grid.append(list.toOwnedSlice());
            col_i += 1;
        }
        {
            const l = grid.items.len;

            for (range(4)) |_| {
                for (range(l)) |_| {
                    const next = try alloc.dupe(u32, grid.items[col_i - l]);
                    for (next) |*n| {
                        n.* = n.* % 9 + 1;
                    }
                    try grid.append(next);
                    col_i += 1;
                }
            }
        }

        const graph = grid.toOwnedSlice();
        const shortest = try shortestPath(alloc, graph);

        std.debug.print("{d}\n", .{shortest});
    }
}

// Modified https://en.wikipedia.org/wiki/Dijkstra's_algorithm
fn shortestPath(alloc: *std.mem.Allocator, grid: []const []const u32) !u32 {
    const l = grid.len;

    var dists = std.AutoHashMap(Point, u32).init(alloc);
    defer dists.deinit();

    var q = std.PriorityQueue(PointPlus, compareFn).init(alloc);
    defer q.deinit();

    for (range(l)) |_, y| {
        for (range(l)) |_, x| {
            try dists.put(Point{ .x = x, .y = y }, std.math.maxInt(u32));
        }
    }
    dists.getEntry(Point{ .x = 0, .y = 0 }).?.value_ptr.* = 0;
    try q.add(PointPlus{ .x = 0, .y = 0, .cost = 0 });

    while (q.len > 0) {
        const u = q.remove();

        if (u.cost != dists.get(u.toPoint())) {
            continue;
        }
        if (u.x == l - 1 and u.y == l - 1) {
            break;
        }
        for (u.toPoint().neighbors(l)) |vop| {
            if (vop == null) continue;
            const v = vop.?;

            const alt = dists.get(u.toPoint()).? + grid[v.y][v.x];
            if (alt < dists.get(v).?) {
                dists.getEntry(v).?.value_ptr.* = alt;
                try q.add(v.toPlus(alt));
            }
        }
    }

    var shortest = dists.get(Point{ .x = l - 1, .y = l - 1 }).?;
    shortest -= dists.get(Point{ .x = 0, .y = 0 }).?;
    return shortest;
}

fn compareFn(a: PointPlus, b: PointPlus) std.math.Order {
    if (a.cost < b.cost) return .lt;
    if (a.cost == b.cost) return .eq;
    if (a.cost > b.cost) return .gt;
    unreachable;
}
