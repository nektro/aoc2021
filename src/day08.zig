const std = @import("std");
const string = []const u8;

const input = @embedFile("../input/day08.txt");

const constraints = struct {
    pub const zer: [7]u1 = .{ 1, 1, 1, 0, 1, 1, 1 }; // 0
    pub const one: [7]u1 = .{ 0, 0, 1, 0, 0, 1, 0 }; // 1
    pub const two: [7]u1 = .{ 1, 0, 1, 1, 1, 0, 1 }; // 2
    pub const thr: [7]u1 = .{ 1, 0, 1, 1, 0, 1, 1 }; // 3
    pub const fou: [7]u1 = .{ 0, 1, 1, 1, 0, 1, 0 }; // 4
    pub const fiv: [7]u1 = .{ 1, 1, 0, 1, 0, 1, 1 }; // 5
    pub const six: [7]u1 = .{ 1, 1, 0, 1, 1, 1, 1 }; // 6
    pub const sev: [7]u1 = .{ 1, 0, 1, 0, 0, 1, 0 }; // 7
    pub const eit: [7]u1 = .{ 1, 1, 1, 1, 1, 1, 1 }; // 8
    pub const nin: [7]u1 = .{ 1, 1, 1, 1, 0, 1, 1 }; // 9

    pub const _all = [_][7]u1{ zer, one, two, thr, fou, fiv, six, sev, eit, nin };
};

pub fn main() !void {
    //

    // part 1
    {
        var iter = std.mem.split(u8, input, "\n");

        var count: u32 = 0;

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            const bar_index = std.mem.indexOf(u8, line, " | ").?;
            // const input = line[0..bar_index];
            const output = line[bar_index + 3 ..];

            var out_iter = std.mem.split(u8, output, " ");
            while (out_iter.next()) |jtem| {
                if (jtem.len == 2) count += 1; // 1
                if (jtem.len == 4) count += 1; // 4
                if (jtem.len == 3) count += 1; // 7
                if (jtem.len == 7) count += 1; // 8
            }
        }

        std.debug.print("{d}\n", .{count});
    }

    // part 2
    {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = &arena.allocator;

        var iter = std.mem.split(u8, input, "\n");

        var sum: u32 = 0;

        while (iter.next()) |line| {
            if (line.len == 0) continue;

            const bar_index = std.mem.indexOf(u8, line, " | ").?;
            const in = try splitAlloc(alloc, line[0..bar_index], " ");
            const out = try splitAlloc(alloc, line[bar_index + 3 ..], " ");

            // make a list for each letter of the possible positions it might be, start with all true
            var positions = PosPossibilities{
                .letters = .{
                    [_]u1{1} ** 7,
                    [_]u1{1} ** 7,
                    [_]u1{1} ** 7,
                    [_]u1{1} ** 7,
                    [_]u1{1} ** 7,
                    [_]u1{1} ** 7,
                    [_]u1{1} ** 7,
                },
                .numbers = std.StringHashMap(std.ArrayList(u32)).init(alloc),
            };

            // read input numbers and slowly remove positions from each list based on constraints
            for (in) |item| {
                try positions.numbers.put(item, std.ArrayList(u32).init(alloc));

                if (item.len == 2) positions.mustBe(item, constraints.one, 1);
                if (item.len == 4) positions.mustBe(item, constraints.fou, 4);
                if (item.len == 3) positions.mustBe(item, constraints.sev, 7);
                if (item.len == 7) positions.mustBe(item, constraints.eit, 8);

                if (item.len == 5) {
                    try positions.numbers.getEntry(item).?.value_ptr.*.appendSlice(&[_]u32{ 2, 3, 5 });
                }
                if (item.len == 6) {
                    try positions.numbers.getEntry(item).?.value_ptr.*.appendSlice(&[_]u32{ 0, 6, 9 });
                }
            }

            // for dab - ab to top position
            const diff_7_1 = try difference(alloc, positions.seqByNum(1, 1)[0], positions.seqByNum(1, 7)[0]);
            const spot_a = diff_7_1[0];
            positions.set(spot_a, 'a');

            // for ef set all to 0 except bd
            const diff_1_4 = try difference(alloc, positions.seqByNum(1, 1)[0], positions.seqByNum(1, 4)[0]);
            positions.setMulti(diff_1_4, "bd");

            // put f in the middle from the intersection of 4, 2, 3, 5
            // (gcdfa fbcad cdfbe ef) f
            const poses_2 = positions.seqByNum(3, 2);
            const diff_4235 = try intersection(alloc, &[_]string{ diff_1_4, poses_2[0], poses_2[1], poses_2[2] });
            const spot_d = diff_4235[0];
            positions.set(spot_d, 'd');

            /////// intersection of 2, 3, 5 thats not in spot_d is in spot_b
            // (gcdfa fbcad cdfbe) - d = e
            const spot_b = std.mem.trim(u8, diff_1_4, diff_4235)[0];
            positions.set(spot_b, 'b');

            // intersection of 2, 3, 5 thats not spot_a or spot_d is in spot_g (c)
            const diff_235 = try intersection(alloc, &poses_2);
            const spot_g = (try trim(alloc, diff_235, &[_]u8{ spot_a, diff_4235[0] }))[0];
            positions.set(spot_g, 'g');

            // we found 5
            for (poses_2) |item| {
                const list = positions.numbers.getEntry(item).?.value_ptr;
                if (std.mem.indexOfScalar(u8, item, spot_b)) |_| {
                    list.items[0] = 5;
                    list.shrinkRetainingCapacity(1);
                } else {
                    _ = list.orderedRemove(indexOf(list.items, 5));
                }
            }

            // dealing with 2 and 3
            {
                // gcdfa fbcad
                // ga ba
                // b { 0, 0, 1, 0, 0, 1, 0 }
                // g { 0, 0, 1, 0, 1, 1, 0 }
                const poses_2_new = positions.seqByNum(2, 2);
                const to_check = try difference(alloc, poses_2_new[0], poses_2_new[1]);
                const x = positions.letters[to_check[0] - 'a'];
                const y = positions.letters[to_check[1] - 'a'];

                for (x) |item, i| {
                    if (item != y[i]) {
                        if (item == 1) {
                            positions.set(to_check[0], @intCast(u8, i) + 'a');
                        }
                        if (y[i] == 1) {
                            positions.set(to_check[1], @intCast(u8, i) + 'a');
                        }
                    }
                }
            }

            // final spot, spot_f
            const diff_1_5 = try intersection(alloc, &[_]string{ positions.seqByNum(1, 1)[0], positions.seqByNum(1, 5)[0] });
            positions.set(diff_1_5[0], 'f');

            // remap output numbers
            const real = positions.fixed();

            // deafgbc -> cdfeb
            var num_s: [4]u8 = undefined;
            for (out) |item, i| {
                var temp = std.mem.zeroes([7]u1);

                for (item) |c| {
                    temp[std.mem.indexOfScalar(u8, &real, c).?] = 1;
                }
                for (constraints._all) |jtem, j| {
                    if (std.mem.eql(u1, &temp, &jtem)) {
                        num_s[i] = @intCast(u8, j) + '0';
                    }
                }
            }

            // add to running sum
            const num = try std.fmt.parseUnsigned(u32, &num_s, 10);
            sum += num;
        }
        std.debug.print("{d}\n", .{sum});
    }
}

const PosPossibilities = struct {
    letters: [7][7]u1,
    numbers: std.StringHashMap(std.ArrayList(u32)),

    pub fn mustBe(self: *PosPossibilities, sequence: string, constraint: [7]u1, number: u32) void {
        for (sequence) |c| {
            for (constraint) |o, j| {
                self.letters[c - 'a'][j] &= o;
            }
        }
        self.numbers.getEntry(sequence).?.value_ptr.*.append(number) catch @panic("");
    }

    pub fn seqByNum(self: PosPossibilities, comptime N: usize, number: u32) [N]string {
        var iter = self.numbers.iterator();
        var result: [N]string = undefined;
        var i: usize = 0;
        while (iter.next()) |entry| {
            if (std.mem.indexOfScalar(u32, entry.value_ptr.*.items, number)) |_| {
                result[i] = entry.key_ptr.*;
                i += 1;
            }
        }
        return result;
    }

    pub fn set(self: *PosPossibilities, x: u8, y: u8) void {
        for (self.letters) |_, i| self.letters[x - 'a'][i] = 0;
        for (self.letters) |_, i| self.letters[i][y - 'a'] = 0;
        self.letters[x - 'a'][y - 'a'] = 1;
    }

    pub fn setMulti(self: *PosPossibilities, diff: []const u8, valid: []const u8) void {
        for (diff) |c| {
            for (self.letters) |_, i| self.letters[c - 'a'][i] = 0;
            for (valid) |v| self.letters[c - 'a'][v - 'a'] = 1;
        }
    }

    pub fn fixed(self: PosPossibilities) [7]u8 {
        var res: [7]u8 = undefined;

        for (self.letters) |item, i| {
            for (item) |jtem, j| {
                if (jtem == 1) {
                    res[j] = @intCast(u8, i) + 'a';
                }
            }
        }
        return res;
    }
};

fn splitAlloc(alloc: *std.mem.Allocator, in: string, delim: string) ![]const string {
    var list = std.ArrayList(string).init(alloc);
    var iter = std.mem.split(u8, in, delim);

    while (iter.next()) |item| {
        try list.append(item);
    }
    return list.toOwnedSlice();
}

fn difference(alloc: *std.mem.Allocator, a: string, b: string) !string {
    if (a.len > b.len) {
        return try trim(alloc, a, b);
    }
    if (b.len > a.len) {
        return try trim(alloc, b, a);
    }
    var list = std.ArrayList(u8).init(alloc);
    defer list.deinit();
    try list.writer().writeAll(try trim(alloc, a, b));
    try list.writer().writeAll(try trim(alloc, b, a));
    return list.toOwnedSlice();
}

fn trim(alloc: *std.mem.Allocator, in: string, values_to_strip: []const u8) !string {
    var list = std.ArrayList(u8).init(alloc);
    defer list.deinit();

    for (in) |c| {
        if (std.mem.indexOfScalar(u8, values_to_strip, c)) |_| {} else {
            try list.append(c);
        }
    }
    return list.toOwnedSlice();
}

// put the smallest first
fn intersection(alloc: *std.mem.Allocator, xs: []const string) !string {
    var list = std.ArrayList(u8).init(alloc);
    defer list.deinit();

    for (xs[0]) |c| {
        var bad = false;
        for (xs) |x| {
            if (std.mem.indexOfScalar(u8, x, c)) |_| {} else {
                bad = true;
                break;
            }
        }
        if (!bad) {
            try list.append(c);
        }
    }

    return list.toOwnedSlice();
}

fn indexOf(haystack: []const u32, needle: u32) usize {
    for (haystack) |item, i| {
        if (item == needle) {
            return i;
        }
    }
    @panic("it really should be there...");
}
