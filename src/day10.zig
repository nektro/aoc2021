const std = @import("std");
const string = []const u8;

const input = @embedFile("../input/day10.txt");

pub fn main() !void {

    // part 1
    {
        var iter = std.mem.split(u8, input, "\n");

        var sum: u32 = 0;

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            Parser.parseOnly(line) catch |err| switch (err) {
                error.IllegalParen => sum += 3,
                error.IllegalSquarBracket => sum += 57,
                error.IllegalCurlyBracket => sum += 1197,
                error.IllegalAngleBracket => sum += 25137,
            };
        }

        std.debug.print("{d}\n", .{sum});
    }

    // part 2
    {
        var iter = std.mem.split(u8, input, "\n");

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var all_scores = std.ArrayList(u64).init(alloc);
        defer all_scores.deinit();

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            const completion = Parser.parse(alloc, line) catch |err| switch (err) {
                error.IllegalParen => "",
                error.IllegalSquarBracket => "",
                error.IllegalCurlyBracket => "",
                error.IllegalAngleBracket => "",
                error.OutOfMemory => return err,
            };
            if (completion.len == 0) {
                continue;
            }

            var score: u64 = 0;

            for (completion) |c| {
                score *= 5;
                score += switch (c) {
                    ')' => @as(u8, 1),
                    ']' => @as(u8, 2),
                    '}' => @as(u8, 3),
                    '>' => @as(u8, 4),
                    else => unreachable,
                };
            }

            try all_scores.append(score);
        }

        var the_scores = all_scores.toOwnedSlice();

        const asc = comptime std.sort.asc(u64);
        std.sort.sort(u64, the_scores, {}, asc);

        const middle_score = the_scores[(the_scores.len - 1) / 2];

        std.debug.print("{d}\n", .{middle_score});
    }
}

const Parser = struct {
    buf: string,
    index: usize,
    alloc: *std.mem.Allocator,
    tryBail: bool,
    bail: bool,

    const Error = error{
        IllegalParen,
        IllegalSquarBracket,
        IllegalCurlyBracket,
        IllegalAngleBracket,
    };

    const FullError = std.mem.Allocator.Error || Error;

    pub fn parseOnly(src: string) Error!void {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var p = Parser{
            .buf = src,
            .index = 0,
            .alloc = alloc,
            .tryBail = false,
            .bail = false,
        };
        _ = p.do(null) catch |err| switch (err) {
            error.OutOfMemory => unreachable,
            else => |es| return es,
        };
        return;
    }

    pub fn parse(alloc: *std.mem.Allocator, src: string) FullError!string {
        var p = Parser{
            .buf = src,
            .index = 0,
            .alloc = alloc,
            .tryBail = true,
            .bail = false,
        };
        return try p.do(null);
    }

    fn do(self: *Parser, start: ?u8) FullError!string {
        const tok = start orelse self.eat();
        var completion = try switch (tok) {
            '(' => self.doChunk(')'),
            '[' => self.doChunk(']'),
            '{' => self.doChunk('}'),
            '<' => self.doChunk('>'),
            else => @panic(""),
        };
        if (self.tryBail) {
            if (self.bail) {
                return try std.mem.concat(self.alloc, u8, &[_]string{ completion, &[_]u8{closers[std.mem.indexOfScalar(u8, openers, tok).?]} });
            }
        }
        return completion;
    }

    fn doChunk(self: *Parser, end: u8) FullError!string {
        while (true) {
            if (self.index == self.buf.len) {
                // incomplete sequence
                self.bail = true;
                return "";
            }

            const next = self.eat();
            if (next == end) return "";

            if (std.mem.indexOfScalar(u8, openers, next)) |_| {
                const comp = try self.do(next);
                if (self.bail) return comp;
                continue;
            }
            if (std.mem.indexOfScalar(u8, closers, next)) |_| {
                return switch (next) {
                    ')' => error.IllegalParen,
                    ']' => error.IllegalSquarBracket,
                    '}' => error.IllegalCurlyBracket,
                    '>' => error.IllegalAngleBracket,
                    else => unreachable,
                };
            }
            @panic("");
        }
        return "";
    }

    const openers = "([{<";
    const closers = ")]}>";

    fn peek(self: Parser) u8 {
        return self.buf[self.index];
    }

    fn eat(self: *Parser) u8 {
        const r = self.peek();
        self.index += 1;
        return r;
    }
};
