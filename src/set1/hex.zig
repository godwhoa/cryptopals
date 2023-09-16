const std = @import("std");

fn hex_lookup(char: u8) !u8 {
    switch (char) {
        '0' => return 0x0,
        '1' => return 0x1,
        '2' => return 0x2,
        '3' => return 0x3,
        '4' => return 0x4,
        '5' => return 0x5,
        '6' => return 0x6,
        '7' => return 0x7,
        '8' => return 0x8,
        '9' => return 0x9,
        'a', 'A' => return 0xA,
        'b', 'B' => return 0xB,
        'c', 'C' => return 0xC,
        'd', 'D' => return 0xD,
        'e', 'E' => return 0xE,
        'f', 'F' => return 0xF,
        else => return error.InvalidCharacter,
    }
}

pub fn decode(input: []const u8) ![]const u8 {
    if (input.len == 0) return error.InvalidInput;

    var bytes = std.ArrayList(u8).init(std.heap.page_allocator);
    defer bytes.deinit();

    for (input, 0..) |char, index| {
        if (index % 2 != 0) {
            const previous = try hex_lookup(input[index - 1]);
            const current = try hex_lookup(char);
            try bytes.append((previous << 4) | current);
        }
    }
    if (input.len % 2 != 0) try bytes.append(input[input.len - 1]);

    return bytes.toOwnedSlice();
}
