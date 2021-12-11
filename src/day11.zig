const std = @import("std");
const string = []const u8;
const range = @import("range").range;

const input = @embedFile("../input/day11.txt");
// const input =
//     \\5483143223
//     \\2745854711
//     \\5264556173
//     \\6141336146
//     \\6357385478
//     \\4167524645
//     \\2176841721
//     \\6882881134
//     \\4846848554
//     \\5283751526
// ;

const L = 10;

pub fn main() !void {
    //

    // part 1
    {
        var grid: [L][L]u32 = undefined;

        {
            var iter = std.mem.split(u8, input, "\n");
            var y: usize = 0;
            while (iter.next()) |line| : (y += 1) {
                for (line) |c, x| {
                    const num = try std.fmt.parseUnsigned(u32, &[_]u8{c}, 10);
                    grid[y][x] = num;
                }
            }
        }

        const steps = 100;
        var total_flash_count: u32 = 0;

        // commence steps
        for (range(steps)) |_| {

            // increment all spaces by 1
            for (grid) |_, y| {
                for (grid[y]) |_, x| {
                    grid[y][x] += 1;
                }
            }
            // print(grid);

            // check for flashes
            var inner: u32 = 0;
            while (true) {
                defer inner += 1;

                var flash_count: u32 = 0;

                for (range(L)) |_, y| {
                    for (range(L)) |_, x| {
                        const n = grid[y][x];
                        if (n > 9 and n != 100) {
                            // increment neighbors
                            if (y > 0) inc(&grid, y - 1, x, 1); //up
                            inc(&grid, y + 1, x, 1); //down
                            if (x > 0) inc(&grid, y, x - 1, 1); //left
                            inc(&grid, y, x + 1, 1); //right
                            if (x > 0) if (y > 0) inc(&grid, y - 1, x - 1, 1); //up left
                            if (y > 0) inc(&grid, y - 1, x + 1, 1); //up right
                            if (x > 0) inc(&grid, y + 1, x - 1, 1); //down left
                            inc(&grid, y + 1, x + 1, 1); //down right

                            // this flashed
                            grid[y][x] = 100;
                            flash_count += 1;
                            total_flash_count += 1;
                        }
                    }
                }
                if (flash_count == 0) {
                    break;
                }
            }

            // reset flashed elements to 0
            for (grid) |line, y| {
                for (line) |n, x| {
                    if (n == 100) {
                        grid[y][x] = 0;
                    }
                }
            }
        }

        std.debug.print("{d}\n", .{total_flash_count});
    }

    // part 2
    {
        var grid: [L][L]u32 = undefined;

        {
            var iter = std.mem.split(u8, input, "\n");
            var y: usize = 0;
            while (iter.next()) |line| : (y += 1) {
                for (line) |c, x| {
                    const num = try std.fmt.parseUnsigned(u32, &[_]u8{c}, 10);
                    grid[y][x] = num;
                }
            }
        }

        var step: usize = 0;
        var found: bool = false;

        // commence steps
        while (!found) {
            step += 1;

            // increment all spaces by 1
            for (grid) |_, y| {
                for (grid[y]) |_, x| {
                    grid[y][x] += 1;
                }
            }

            // check for flashes
            var inner: u32 = 0;
            var step_flashes: u32 = 0;
            while (true) {
                defer inner += 1;

                var flash_count: u32 = 0;

                for (range(L)) |_, y| {
                    for (range(L)) |_, x| {
                        const n = grid[y][x];
                        if (n > 9 and n != 100) {
                            // increment neighbors
                            if (y > 0) inc(&grid, y - 1, x, 1); //up
                            inc(&grid, y + 1, x, 1); //down
                            if (x > 0) inc(&grid, y, x - 1, 1); //left
                            inc(&grid, y, x + 1, 1); //right
                            if (x > 0) if (y > 0) inc(&grid, y - 1, x - 1, 1); //up left
                            if (y > 0) inc(&grid, y - 1, x + 1, 1); //up right
                            if (x > 0) inc(&grid, y + 1, x - 1, 1); //down left
                            inc(&grid, y + 1, x + 1, 1); //down right

                            // this flashed
                            grid[y][x] = 100;
                            flash_count += 1;
                            step_flashes += 1;
                        }
                    }
                }

                // std.log.debug("step {d}: inner {d}: flashes {d}", .{ step, inner, flash_count });

                if (flash_count == 0) {
                    break;
                }
                if (step_flashes == L * L) {
                    found = true;
                    break;
                }
            }

            // reset flashed elements to 0
            for (grid) |line, y| {
                for (line) |n, x| {
                    if (n == 100) {
                        grid[y][x] = 0;
                    }
                }
            }
        }

        std.debug.print("{d}\n", .{step});
    }
}

fn inc(grid: *[L][L]u32, y: usize, x: usize, n: u32) void {
    if (y < 0) return;
    if (x < 0) return;
    if (y >= grid.len) return;
    if (x >= grid[0].len) return;
    if (grid[y][x] == 100) return;
    grid[y][x] += n;
    // std.log.info("inc'd {d},{d}", .{ x, y });
}

fn print(grid: [L][L]u32) void {
    for (grid) |line| {
        for (line) |nn| {
            if (nn == 100) {
                std.debug.print(" *", .{});
                continue;
            }
            std.debug.print("{d:>2}", .{nn});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}
