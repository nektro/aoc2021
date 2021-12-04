const std = @import("std");
const string = []const u8;
const range = @import("range").range;

const input = @embedFile("../input/day04.txt");

const BingoBoard = [5][5]u32;

pub fn main() !void {

    // part 1
    blk: {
        var iter = std.mem.split(u8, input, "\n");

        const temp_numbers = iter.next().?;
        _ = iter.next().?;

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var all_boards = std.ArrayList(BingoBoard).init(alloc);
        defer all_boards.deinit();

        while (iter.next()) |line| {
            try all_boards.append(parseBoard(.{
                line,
                iter.next().?,
                iter.next().?,
                iter.next().?,
                iter.next().?,
            }));

            // absorb trailing newline
            _ = iter.next();
        }

        // get next called number
        var num_iter = std.mem.split(u8, temp_numbers, ",");
        while (num_iter.next()) |num_s| {
            const num = std.fmt.parseUnsigned(u32, num_s, 10) catch @panic("");

            // mark number in all boards
            for (all_boards.items) |*board| {
                for (range(5)) |_, y| {
                    for (range(5)) |_, x| {
                        if (board[y][x] == num) {
                            board[y][x] = 1000;
                        }
                    }
                }

                // // check if this board is the winner
                var has_winner = false;

                // check horizontals
                for (range(5)) |_, y| {
                    var sum: u32 = 0;
                    for (range(5)) |_, x| {
                        sum += board[y][x];
                    }
                    if (sum == 5000) has_winner = true;
                }

                // check verticals
                for (range(5)) |_, x| {
                    var sum: u32 = 0;
                    for (range(5)) |_, y| {
                        sum += board[y][x];
                    }
                    if (sum == 5000) has_winner = true;
                }

                if (has_winner) {
                    var unmarked_sum: u32 = 0;
                    for (range(5)) |_, y| {
                        for (range(5)) |_, x| {
                            var g = board[y][x];
                            if (g != 1000) unmarked_sum += g;
                        }
                    }

                    std.debug.print("{d}\n", .{unmarked_sum * num});
                    break :blk;
                }
            }
        }
    }

    // part 2
    blk1: {
        var iter = std.mem.split(u8, input, "\n");

        const temp_numbers = iter.next().?;
        _ = iter.next().?;

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var all_boards = std.ArrayList(BingoBoard).init(alloc);
        defer all_boards.deinit();

        while (iter.next()) |line| {
            try all_boards.append(parseBoard(.{
                line,
                iter.next().?,
                iter.next().?,
                iter.next().?,
                iter.next().?,
            }));

            // absorb trailing newline
            _ = iter.next();
        }

        // get next called number
        var num_iter = std.mem.split(u8, temp_numbers, ",");
        while (num_iter.next()) |num_s| {
            const num = std.fmt.parseUnsigned(u32, num_s, 10) catch @panic("");

            // mark number in all boards
            var i: usize = 0;
            while (i < all_boards.items.len) : (i += 1) {
                var board = &all_boards.items[i];
                markNumber(board, num);

                // // check if this board is the winner
                var has_winner = false;

                // check horizontals
                for (range(5)) |_, y| {
                    var sum: u32 = 0;
                    for (range(5)) |_, x| {
                        sum += board[y][x];
                    }
                    if (sum == 5000) has_winner = true;
                }

                // check verticals
                for (range(5)) |_, x| {
                    var sum: u32 = 0;
                    for (range(5)) |_, y| {
                        sum += board[y][x];
                    }
                    if (sum == 5000) has_winner = true;
                }

                if (has_winner) {
                    if (all_boards.items.len == 1) {
                        const unmarked_sum = unmarkedSum(board);
                        std.debug.print("{d}\n", .{unmarked_sum * num});
                        break :blk1;
                    } else {
                        _ = all_boards.orderedRemove(i);
                    }
                }
            }
        }
    }
}

fn parseBoard(lines: [5]string) BingoBoard {
    return .{
        parseLine(lines[0]),
        parseLine(lines[1]),
        parseLine(lines[2]),
        parseLine(lines[3]),
        parseLine(lines[4]),
    };
}

fn parseLine(line: string) [5]u32 {
    return .{
        std.fmt.parseUnsigned(u32, std.mem.trim(u8, line[0..2], " "), 10) catch @panic(""),
        std.fmt.parseUnsigned(u32, std.mem.trim(u8, line[3..5], " "), 10) catch @panic(""),
        std.fmt.parseUnsigned(u32, std.mem.trim(u8, line[6..8], " "), 10) catch @panic(""),
        std.fmt.parseUnsigned(u32, std.mem.trim(u8, line[9..11], " "), 10) catch @panic(""),
        std.fmt.parseUnsigned(u32, std.mem.trim(u8, line[12..14], " "), 10) catch @panic(""),
    };
}

fn markNumber(board: *BingoBoard, n: u32) void {
    for (range(5)) |_, y| {
        for (range(5)) |_, x| {
            if (board[y][x] == n) {
                board[y][x] = 1000;
            }
        }
    }
}

fn unmarkedSum(board: *BingoBoard) u32 {
    var sum: u32 = 0;
    for (range(5)) |_, y| {
        for (range(5)) |_, x| {
            var g = board[y][x];
            if (g != 1000) sum += g;
        }
    }
    return sum;
}
