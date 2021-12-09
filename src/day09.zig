const std = @import("std");
const string = []const u8;

const input = @embedFile("../input/day09.txt");

pub fn main() !void {

    // part 1
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var lines = std.ArrayList([]const u32).init(alloc);
        defer lines.deinit();

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            var list = std.ArrayList(u32).init(alloc);
            defer list.deinit();

            for (line) |c| {
                try list.append(try std.fmt.parseUnsigned(u32, &[_]u8{c}, 10));
            }
            try lines.append(list.toOwnedSlice());
        }

        const grid = lines.toOwnedSlice();

        var sum: u32 = 0;

        for (grid) |row, y| {
            for (row) |item, x| {
                if (isLowPoint(grid, y, x)) {
                    sum += item + 1;
                }
            }
        }

        std.debug.print("{d}\n", .{sum});
    }

    // part 2
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var lines = std.ArrayList([]const u32).init(alloc);
        defer lines.deinit();

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            var list = std.ArrayList(u32).init(alloc);
            defer list.deinit();

            for (line) |c| {
                try list.append(try std.fmt.parseUnsigned(u32, &[_]u8{c}, 10));
            }
            try lines.append(list.toOwnedSlice());
        }

        const grid = lines.toOwnedSlice();

        var first: u32 = 0;
        var second: u32 = 0;
        var third: u32 = 0;

        for (grid) |row, y| {
            for (row) |_, x| {
                if (isLowPoint(grid, y, x)) {

                    // make a duplicate of `grid` that is [][]u1
                    var basin = try createBasinGrid(alloc, grid);

                    // mark newgrid[y][x] = 1
                    basin[y][x] = 1;

                    // for all positions in newgrid=1 check if adjacent points in grid at !=9
                    //   if yes, mark newgrid pos = 1, repeat
                    // repeat until the size of the basin does not change
                    fillBasin(grid, basin);

                    // check size
                    const size = basinSize(basin);

                    // see if its in the top 3
                    if (size > first) {
                        third = second;
                        second = first;
                        first = size;
                    } else if (size > second) {
                        third = second;
                        second = size;
                    } else if (size > third) {
                        third = size;
                    }
                }
            }
        }

        std.debug.print("{d}\n", .{first * second * third});
    }
}

fn isLowPoint(grid: []const []const u32, y: usize, x: usize) bool {
    const n = grid[y][x];

    // is in the corner
    // TL
    if (y == 0 and x == 0) return (n < grid[y + 1][x] and n < grid[y][x + 1]);
    // TR
    if (y == 0 and x == grid[0].len - 1) return (n < grid[y + 1][x] and n < grid[y][x - 1]);
    // BL
    if (y == grid.len - 1 and x == 0) return (n < grid[y - 1][x] and n < grid[y][x + 1]);
    // BR
    if (y == grid.len - 1 and x == grid[0].len - 1) return (n < grid[y - 1][x] and n < grid[y][x - 1]);

    // is on the edge
    // left
    if (x == 0) return (n < grid[y + 1][x] and n < grid[y - 1][x] and n < grid[y][x + 1]);
    // top
    if (y == 0) return (n < grid[y + 1][x] and n < grid[y][x + 1] and n < grid[y][x - 1]);
    // right
    if (x == grid[0].len - 1) return (n < grid[y + 1][x] and n < grid[y - 1][x] and n < grid[y][x - 1]);
    // bottom
    if (y == grid.len - 1) return (n < grid[y - 1][x] and n < grid[y][x + 1] and n < grid[y][x - 1]);

    // is in the middle
    return (n < grid[y + 1][x] and n < grid[y - 1][x] and n < grid[y][x + 1] and n < grid[y][x - 1]);
}

// generate [][]u1 grid same size as input grid
fn createBasinGrid(alloc: *std.mem.Allocator, grid: []const []const u32) ![][]u1 {
    var list = std.ArrayList([]u1).init(alloc);
    defer list.deinit();
    for (grid) |row| {
        try list.append(try alloc.alloc(u1, row.len));
    }
    return list.toOwnedSlice();
}

// checking adjacent points in grid and marking newgrid accordingly
fn fillBasin(grid: []const []const u32, basin: [][]u1) void {
    const before_size = basinSize(basin);

    for (basin) |row, y| {
        for (row) |item, x| {
            if (item == 1) {
                if (y > 0 and checkNotEq(u32, grid, y - 1, x, 9)) basin[y - 1][x] = 1;
                if (checkNotEq(u32, grid, y + 1, x, 9)) basin[y + 1][x] = 1;
                if (x > 0 and checkNotEq(u32, grid, y, x - 1, 9)) basin[y][x - 1] = 1;
                if (checkNotEq(u32, grid, y, x + 1, 9)) basin[y][x + 1] = 1;
            }
        }
    }

    const after_size = basinSize(basin);
    if (after_size == before_size) return;
    fillBasin(grid, basin);
}

// sum pts[y][x]=1 to get basin size
fn basinSize(basin: []const []const u1) u32 {
    var sum: u32 = 0;
    for (basin) |row| {
        for (row) |item| {
            sum += item;
        }
    }
    return sum;
}

fn checkNotEq(comptime T: type, slice: []const []const T, y: usize, x: usize, value: T) bool {
    if (y < 0) return false;
    if (y >= slice.len) return false;

    if (x < 0) return false;
    if (x >= slice[0].len) return false;

    return slice[y][x] != value;
}
