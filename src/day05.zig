const std = @import("std");
const string = []const u8;
const range = @import("range").range;

const input = @embedFile("../input/day05.txt");

pub fn main() !void {

    // part 1
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var point_list = std.ArrayList([2][2]u32).init(alloc);
        defer point_list.deinit();

        const W = 1000;

        var plot = std.mem.zeroes([W][W]u32);

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            var line_iter = std.mem.split(u8, line, ",");

            const x1 = std.fmt.parseUnsigned(u32, line_iter.next().?, 10) catch @panic("");

            line_iter.delimiter = " ";
            const y1 = std.fmt.parseUnsigned(u32, line_iter.next().?, 10) catch @panic("");

            line_iter.index = line_iter.index.? + 3;

            line_iter.delimiter = ",";
            const x2 = std.fmt.parseUnsigned(u32, line_iter.next().?, 10) catch @panic("");
            const y2 = std.fmt.parseUnsigned(u32, line_iter.next().?, 10) catch @panic("");

            // skip diagonals
            if (x1 != x2 and y1 != y2) continue;

            // // mark points in `plot`
            if (y1 == y2 and x2 > x1) {
                // line goes to right
                var i: usize = x1;
                while (i <= x2) : (i += 1) {
                    plot[y1][i] += 1;
                }
            }
            if (y1 == y2 and x1 > x2) {
                // line goes to the left
                var i: usize = x1;
                while (i >= x2) : (i -= 1) {
                    plot[y1][i] += 1;
                }
            }
            if (x1 == x2) {
                // line goes down
                if (y2 > y1) {
                    var i: usize = y1;
                    while (i <= y2) : (i += 1) {
                        plot[i][x1] += 1;
                    }
                }

                // line goes up
                if (y1 > y2) {
                    var i: usize = y1;
                    while (i >= y2) : (i -= 1) {
                        plot[i][x1] += 1;
                    }
                }
            }
        }

        // find points in `plot` where its been marked more than once
        var count: u32 = 0;
        for (range(W)) |_, col| {
            for (range(W)) |_, row| {
                if (plot[col][row] > 1) {
                    count += 1;
                }
            }
        }

        std.debug.print("{d}\n", .{count});
    }

    // part 2
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var point_list = std.ArrayList([2][2]u32).init(alloc);
        defer point_list.deinit();

        const W = 1000;

        var plot = std.mem.zeroes([W][W]u32);

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            var line_iter = std.mem.split(u8, line, ",");

            const x1 = std.fmt.parseUnsigned(u32, line_iter.next().?, 10) catch @panic("");

            line_iter.delimiter = " ";
            const y1 = std.fmt.parseUnsigned(u32, line_iter.next().?, 10) catch @panic("");

            line_iter.index = line_iter.index.? + 3;

            line_iter.delimiter = ",";
            const x2 = std.fmt.parseUnsigned(u32, line_iter.next().?, 10) catch @panic("");
            const y2 = std.fmt.parseUnsigned(u32, line_iter.next().?, 10) catch @panic("");

            // // mark points in `plot`

            // line goes horizontal to right
            if (y1 == y2 and x2 > x1) {
                var i: usize = x1;
                while (i <= x2) : (i += 1) plot[y1][i] += 1;
            }

            // line goes horizontal to the left
            if (y1 == y2 and x1 > x2) {
                var i: usize = x1;
                while (i >= x2) : (i -= 1) plot[y1][i] += 1;
            }

            // line goes vertical down
            if (x1 == x2 and y2 > y1) {
                var i: usize = y1;
                while (i <= y2) : (i += 1) plot[i][x1] += 1;
            }

            // line goes vertical up
            if (x1 == x2 and y1 > y2) {
                var i: usize = y1;
                while (i >= y2) : (i -= 1) plot[i][x1] += 1;
            }

            // line goes diag TLBR
            // 1,1 -> 3,3
            if (x2 > x1 and y2 > y1) {
                var i: usize = 0;
                while (i <= x2 - x1) : (i += 1) plot[y1 + i][x1 + i] += 1;
            }

            // line goes diag BRTL
            // 9,9 -> 0,0
            if (x1 > x2 and y1 > y2) {
                var i: usize = 0;
                while (i <= x1 - x2) : (i += 1) plot[y1 - i][x1 - i] += 1;
            }

            // line goes diag TRBL
            // 8,1 -> 1,8
            if (x1 > x2 and y2 > y1) {
                var i: usize = 0;
                while (i <= x1 - x2) : (i += 1) plot[i + y1][x1 - i] += 1;
            }

            // line goes diag BLTR
            // 5,5 -> 8,2
            if (x2 > x1 and y1 > y2) {
                var i: usize = 0;
                while (i <= x2 - x1) : (i += 1) plot[y1 - i][x1 + i] += 1;
            }
        }

        // find points in `plot` where its been marked more than once
        var count: u32 = 0;
        for (range(W)) |_, col| {
            for (range(W)) |_, row| {
                if (plot[col][row] > 1) {
                    count += 1;
                }
            }
        }

        std.debug.print("{d}\n", .{count});
    }
}
