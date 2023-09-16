const std = @import("std");

pub fn encode(input: []const u8) ![]const u8 {
    if (input.len == 0) return error.InvalidInput;

    var encoded = std.ArrayList(u8).init(std.heap.page_allocator);
    defer encoded.deinit();

    const table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
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
