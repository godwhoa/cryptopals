const std = @import("std");

const table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

pub fn decode(input: []const u8) ![]const u8 {
    var reverse_table: [256]u8 = [_]u8{0xff} ** 256;
    for (table, 0..) |c, i| {
        reverse_table[c] = @as(u8, @intCast(i));
    }

    var decoded = std.ArrayList(u8).init(std.heap.page_allocator);
    defer decoded.deinit();

    var i: usize = 0;
    while (i < input.len) : (i += 4) {
        const first = reverse_table[input[i]];
        const second = reverse_table[input[i + 1]];
        const thrid = reverse_table[input[i + 2]];
        const fourth = reverse_table[input[i + 3]];

        // All six from first + first two from second
        try decoded.append(first << 2 | second >> 4); // always remember these only have six bits set, so >> 4 makes sense

        if (thrid != 64) {
            // Last four bits from second + first four bits from thrid
            const r = (second & 0b00001111) << 4 | (thrid >> 2);
            try decoded.append(r);
        }

        if (fourth != 64) {
            // Last two bits from thrid + all six from fourth
            try decoded.append((thrid & 0b00000011) << 6 | fourth);
        }
    }

    return decoded.toOwnedSlice();
}

pub fn encode(input: []const u8) ![]const u8 {
    if (input.len == 0) return error.InvalidInput;

    var encoded = std.ArrayList(u8).init(std.heap.page_allocator);
    defer encoded.deinit();

    var i: usize = 0;
    while (i < input.len) {
        // First six bits of first byte
        const first = input[i] >> 2;
        try encoded.append(table[first]);

        if (i + 1 < input.len) {
            // Remaning two bits of first byte and first four bits of second byte
            const second = (input[i] & 0b00000011) << 4 | (input[i + 1] & 0b11110000) >> 4;
            try encoded.append(table[second]);
        }

        if (i + 2 < input.len) {
            // Remaning four bits of second byte and first two bits of third byte
            const third = (input[i + 1] & 0b00001111) << 2 | (input[i + 2] & 0b11000000) >> 6;
            // Remaning six bits of third byte
            const fourth = input[i + 2] & 0b00111111;
            try encoded.append(table[third]);
            try encoded.append(table[fourth]);
        }

        i += 3;
    }

    switch (input.len % 3) {
        // Eg. 1%3 == 1, 11111111 -> 111111 11, we have two bits left
        1 => {
            // Last two bits of the last byte
            const final = table[(input[input.len - 1] & 0b00000011) << 4];
            try encoded.append(final);
            try encoded.appendNTimes('=', 2);
        },
        // Eg. 2%3 == 2, 11111111 11111111 -> 111111 111111 1111, we have four bits left
        2 => {
            // Last four bits of the last byte
            const final = table[(input[input.len - 1] & 0b00001111) << 2];
            try encoded.append(final);
            try encoded.append('=');
        },
        else => {},
    }

    return encoded.toOwnedSlice();
}
