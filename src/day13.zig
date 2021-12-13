const std = @import("std");
const string = []const u8;
const range = @import("range").range;

const input = @embedFile("../input/day13.txt");

const Point = struct {
    x: u32,
    y: u32,
};

const Fold = struct {
    axis: Axis,
    cardinal: u32,

    const Axis = enum { x, y };
};

const Grid = [][]u1;

pub fn main() !void {
    //

    // part 1
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var all_points = std.ArrayList(Point).init(alloc);
        defer all_points.deinit();

        var all_folds = std.ArrayList(Fold).init(alloc);
        defer all_folds.deinit();

        // parse input to collect all points and folds
        while (iter.next()) |line| {
            if (line.len == 0) continue;

            if (std.mem.startsWith(u8, line, "fold along")) {
                const axis = std.meta.stringToEnum(Fold.Axis, line[11..][0..1]).?;
                const cardinal = try std.fmt.parseUnsigned(u32, line[13..], 10);
                try all_folds.append(Fold{ .axis = axis, .cardinal = cardinal });
                continue;
            }

            const index = std.mem.indexOfScalar(u8, line, ',').?;
            const x = try std.fmt.parseUnsigned(u32, line[0..index], 10);
            const y = try std.fmt.parseUnsigned(u32, line[index + 1 ..], 10);
            try all_points.append(Point{ .x = x, .y = y });
        }

        // setup initial grid
        var max_x: u32 = 0;
        var max_y: u32 = 0;

        for (all_points.items) |item| {
            if (item.x > max_x) max_x = item.x;
            if (item.y > max_y) max_y = item.y;
        }

        var grid = try makeGrid(alloc, max_x + 1, max_y + 1);

        // set our points
        for (all_points.items) |item| {
            grid[item.y][item.x] = 1;
        }

        // perform first fold
        grid = try doFold(alloc, grid, all_folds.items[0]);

        // find visible dots
        const count = dotCount(grid);

        std.debug.print("{d}\n", .{count});
    }

    // part 2
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var all_points = std.ArrayList(Point).init(alloc);
        defer all_points.deinit();

        var all_folds = std.ArrayList(Fold).init(alloc);
        defer all_folds.deinit();

        // parse input to collect all points and folds
        while (iter.next()) |line| {
            if (line.len == 0) continue;

            if (std.mem.startsWith(u8, line, "fold along")) {
                const axis = std.meta.stringToEnum(Fold.Axis, line[11..][0..1]).?;
                const cardinal = try std.fmt.parseUnsigned(u32, line[13..], 10);
                try all_folds.append(Fold{ .axis = axis, .cardinal = cardinal });
                continue;
            }

            const index = std.mem.indexOfScalar(u8, line, ',').?;
            const x = try std.fmt.parseUnsigned(u32, line[0..index], 10);
            const y = try std.fmt.parseUnsigned(u32, line[index + 1 ..], 10);
            try all_points.append(Point{ .x = x, .y = y });
        }

        // setup initial grid
        var max_x: u32 = 0;
        var max_y: u32 = 0;

        for (all_points.items) |item| {
            if (item.x > max_x) max_x = item.x;
            if (item.y > max_y) max_y = item.y;
        }

        var grid = try makeGrid(alloc, max_x + 1, max_y + 1);

        // set our points
        for (all_points.items) |item| {
            grid[item.y][item.x] = 1;
        }

        // do all folds
        for (all_folds.items) |item| {
            grid = try doFold(alloc, grid, item);
        }

        // captcha of letters
        printGrid(grid);
    }
}

fn makeGrid(alloc: *std.mem.Allocator, width: usize, depth: usize) !Grid {
    var list1 = std.ArrayList([]u1).init(alloc);
    defer list1.deinit();

    for (range(depth)) |_| {
        var list2 = std.ArrayList(u1).init(alloc);
        defer list2.deinit();

        for (range(width)) |_| {
            try list2.append(0);
        }
        try list1.append(list2.toOwnedSlice());
    }
    return list1.toOwnedSlice();
}

fn doFold(alloc: *std.mem.Allocator, grid: Grid, fold: Fold) !Grid {
    switch (fold.axis) {
        .x => {
            const w = fold.cardinal;
            const h = grid.len;
            var new_grid = try makeGrid(alloc, w, h);

            // copy elements left of fold
            for (range(h)) |_, y| {
                for (range(w)) |_, x| {
                    new_grid[y][x] = grid[y][x];
                }
            }

            // copy elements right of fold
            for (range(h)) |_, y| {
                for (range(grid[0].len - fold.cardinal)) |_, x| {
                    if (x == 0) continue;
                    new_grid[y][fold.cardinal - x] |= grid[y][fold.cardinal + x];
                }
            }
            return new_grid;
        },
        .y => {
            const w = grid[0].len;
            const h = fold.cardinal;
            var new_grid = try makeGrid(alloc, w, h);

            // copy elements above fold
            for (range(h)) |_, y| {
                for (range(w)) |_, x| {
                    new_grid[y][x] = grid[y][x];
                }
            }

            // copy elements below fold
            for (range(grid.len - fold.cardinal)) |_, y| {
                if (y == 0) continue;
                for (range(w)) |_, x| {
                    new_grid[fold.cardinal - y][x] |= grid[fold.cardinal + y][x];
                }
            }

            return new_grid;
        },
    }
}

fn dotCount(grid: Grid) u32 {
    var count: u32 = 0;

    for (grid) |_, y| {
        for (grid[y]) |_, x| {
            count += grid[y][x];
        }
    }
    return count;
}

fn printGrid(grid: Grid) void {
    for (range(grid.len)) |_, y| {
        for (range(grid[0].len)) |_, x| {
            const char: u8 = if (grid[y][x] == 1) '#' else '.';
            std.debug.print("{c}", .{char});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}
