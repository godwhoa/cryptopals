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

    var i: usize = 0;
    while (i < input.len) : (i += 2) {
        const previous = try hex_lookup(input[i]);
        const current = try hex_lookup(input[i + 1]);
        try bytes.append((previous << 4) | current);
    }
    if (input.len % 2 != 0) try bytes.append(input[input.len - 1]);

    return bytes.toOwnedSlice();
}

pub fn encode(input: []const u8) ![]const u8 {
    const table = "0123456789abcdef";
    const allocator = std.heap.page_allocator;
    var encoded = try allocator.alloc(u8, input.len * 2);
    for (input, 0..) |value, index| {
        const first = table[value >> 4];
        const second = table[value & 0xF];
        encoded[index * 2] = first;
        encoded[index * 2 + 1] = second;
    }
    return encoded;
}
